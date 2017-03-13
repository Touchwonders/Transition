//
//    MIT License
//
//    Copyright (c) 2017 Touchwonders Commerce B.V.
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.


import UIKit

/**
 *  The TransitionDriver is something the app developer will not be confronted with.
 *  It is owned by the TransitionController.
 *  It takes a Transition (specification), sets up UIViewPropertyAnimators, ties it
 *  all together with gesture recognizers and makes the magic happen.
 */
internal final class TransitionDriver {
    
    let transition: Transition
    let operationContext: TransitionOperationContext
    let interactionController: TransitionInteractionController?
    
    private var layerAnimators: [AnimationLayerAnimator]!           /// This will be set after init
    private var sharedElementAnimator: UIViewPropertyAnimator? /// This might be set after init, depending on the presence of both an interactive element and a specification
    
    
    var context: UIViewControllerContextTransitioning {
        return operationContext.context
    }
    var operation: TransitionOperation {
        return operationContext.operation
    }
    var canBeInteractive : Bool {
        return interactionController != nil
    }
    
    
    private let effectiveDuration: TimeInterval
    
    private let completionCoordinator = TransitionCompletionCoordinator()
    
    // We add an invisible view with which something is done (an empty animation block would result in the completion being called immediately).
    // It is used in the progressLayerAnimator.
    private let progressAnimationView = UIView(frame: .zero)
    // Using this animator we have a guaranteed full-AnimationRange layer from which at any moment the overall fractionComplete can be derived.
    private var progressLayerAnimator: AnimationLayerAnimator!
    
    // Returns the current overall fractionComplete of the transition
    private var totalFractionComplete: AnimationFraction {
        return AnimationFraction(progressLayerAnimator.animator.fractionComplete)
    }
    
    
    init(transition: Transition, operationContext: TransitionOperationContext, interactionController: TransitionInteractionController?) {
        self.transition = transition
        self.operationContext = operationContext
        self.interactionController = interactionController
        
        // This is only computed at the very beginning, since any interaction might influence timingCurveProviders, which could change the effective duration:
        self.effectiveDuration = transition.effectiveDuration
        
        // We add an invisible view with which something is done (an empty animation block would result in the completion being called immediately).
        // Using this animator we have a guaranteed full-AnimationRange layer from which at any moment the overall fractionComplete can be derived.
        operationContext.context.containerView.addSubview(progressAnimationView)
        let progressLayer = AnimationLayer(range: .full, timingParameters: AnimationTimingParameters(animationCurve: .linear), animation: { [weak self] in
            self?.progressAnimationView.transform = CGAffineTransform(translationX: -10, y: 0)
        })
        self.progressLayerAnimator = AnimationLayerAnimator(layer: progressLayer, animator: propertyAnimatorFor(animationLayer: progressLayer))
        completionCoordinator.add(animator: progressLayerAnimator.animator)
        progressLayerAnimator.animator.addCompletion({ [weak self] completionPosition in
            self?.progressLayerAnimator.completionPosition = completionPosition
        })
        // The animation must be set up before any interaction,
        // because any added views (to the context's containerView) should logically be positioned below
        // the interactive element.
        transition.animation.setup(in: operationContext)
        
        // See if there's an interactive transition element:
        var sharedElement: SharedElement? = nil

        if let interactionController = interactionController {
            // Get informed about interaction by registering to the interactionController's GestureRecognizer:
            let gestureRecognizer = interactionController.gestureRecognizer
            gestureRecognizer.addTarget(self, action: #selector(updateInteraction(_:)))
            
            if let sharedElementProvider = interactionController.sharedElementProvider {
                sharedElement = sharedElementProvider.sharedElementForInteractiveTransition(with: interactionController, in: operationContext)
            }
        }
        
        // The transition animation with an interactive element is optional, but if available will lead the base transtion animation, set up right after this.
        if let sharedElement = sharedElement, let sharedElementTransitionSpecification = transition.sharedElement {
            sharedElementTransitionSpecification.sharedElement = sharedElement
            // Now the interaction can be set up, adding the interactive element to the context
            transition.sharedElement?.setup(in: operationContext)
            // The animator will be set up when the interactive part should animate (i.e. it's not actively interactive).
            // Note that it is set up in two parts:
            // one configures the property animator, allowing us to determine the exact duration (see further on in this init the effectiveDuration)
            // two sets the actual animation and completion of that animator, as soon as it is required in animate()
            
            // Add a long-press gesture recognizer to allow interruption of the animation
            sharedElement.transitioningView.addGestureRecognizer(newInterruptionGestureRecognizer())
        } else if interactionController != nil {
            // There is no interactive element to attach the interruption gesture to, so attach it to the entire containerView of the transition:
            context.containerView.addGestureRecognizer(newInterruptionGestureRecognizer())
            // We do need to have an interactionController to continue after interruption
        }
        
        
        // Configure execution and completion of transition.animation
        
        layerAnimators = [progressLayerAnimator]
        
        for layer in transition.animation.layers {
            let animator = propertyAnimatorFor(animationLayer: layer)
            let layerAnimator = AnimationLayerAnimator(layer: layer, animator: animator)
            layerAnimators.append(layerAnimator)
        }
        
        completionCoordinator.completion { [weak self] in
            let completionPosition = self?.progressLayerAnimator.completionPosition ?? .end
            //  execute any specified completion
            transition.animation.completion(position: completionPosition)
            transition.sharedElement?.completion(position: completionPosition)
            
            //  delegate the completion phase
            if completionPosition == .end {
                self?.didTransition(with: sharedElement)
            } else {
                self?.cancelledTransition(with: sharedElement)
            }
            //  cleanup
            self?.removeInterruptionGestureRecognizer()
            self?.progressAnimationView.removeFromSuperview()
            
            //  inform the context we are done
            self?.context.completeTransition(completionPosition == .end)
        }
        
        willTransition(with: sharedElement)
        
        if context.isInteractive {
            // If the transition is initially interactive, make sure the interactive element (if present) is configured appropriately
            startInteraction()
        } else {
            // Begin the animation phase immediately if the transition is not initially interactive
            animate(.end)
        }
    }
    
    // MARK: Property Animators
    
    private func propertyAnimatorFor(animationLayer: AnimationLayer, durationFactor: TimeInterval = 1.0) -> UIViewPropertyAnimator {
        let duration = animationLayer.range.length * effectiveDuration * durationFactor
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: animationLayer.timingParameters.timingCurveProvider)
        animator.addAnimations(animationLayer.animation)
        return animator
    }
    
    private func propertyAnimatorForsharedElement() -> UIViewPropertyAnimator? {
        guard let specification = transition.sharedElement else { return nil }
        
        let remainingDuration = max(TimeInterval(1.0 - totalFractionComplete) * effectiveDuration, 0.0)
        
        let animator = UIViewPropertyAnimator(duration: remainingDuration, timingParameters: specification.timingParameters.timingCurveProvider)
        animator.addAnimations(specification.animation)
        return animator
    }
    
    // MARK: Animation cycle
    
    func animate(_ toPosition: UIViewAnimatingPosition) {
        if let existingSharedElementAnimator = self.sharedElementAnimator {
            //  The following will ensure that the completion is called (which only contains a DispatchGroup.leave set by the completionCoordinator)
            existingSharedElementAnimator.stopAnimation(false)
            existingSharedElementAnimator.finishAnimation(at: .current)
        }
        // Create the animator for the interactive element only when it is needed, and every time we should animate.
        // This effectively allows multiple animators to be stacked on the interactive element, smoothing out sharp changes in successive interaction gestures.
        if let specification = transition.sharedElement,
            let sharedElementAnimator = propertyAnimatorForsharedElement() {
            specification.animatingPosition = toPosition
            completionCoordinator.add(animator: sharedElementAnimator)
            sharedElementAnimator.startAnimation()
            self.sharedElementAnimator = sharedElementAnimator
        }
        
        let isReversed = toPosition == .start
        
        // The durationFactor dictates how fast the animators should animate. If we're halfway, then they should animate twice as fast (durationFactor: 0.5).
        var durationFactor = isReversed ? totalFractionComplete : 1.0 - totalFractionComplete
        // If the remaining animation duration should be coupled to the sharedElementAnimator, compute it as a ratio:
        if let sharedElementAnimator = sharedElementAnimator {
            durationFactor = sharedElementAnimator.duration / effectiveDuration
        }
        
        
        for layerAnimator in layerAnimators {
            let animator: UIViewPropertyAnimator = layerAnimator.animator
            animator.isReversed = isReversed
            
            let layerPosition = layerAnimator.effectiveRange.position(totalFractionComplete).reversed(isReversed)
            
            switch layerPosition {
            case .isBefore: break   //  We are beyond the range of this layer, so it shouldn't continue or start after a delay.
            case .contains:
                if animator.state == .inactive {
                    //  this only happens when the animation is started programmatically. FractionComplete will be 0, durationFactor will be 1.
                    animator.addAnimations(layerAnimator.layer.animation)
                    animator.startAnimation()
                } else {
                    animator.continueAnimation(withTimingParameters: nil, durationFactor: CGFloat(durationFactor))
                }
            case .isAfter:
                let delay = layerAnimator.effectiveRange.distance(to: totalFractionComplete) * effectiveDuration
                //  The layer should animate after a specific delay.
                if animator.state == .inactive && durationFactor == 1.0 {
                    //  this only happens when the animation is started programmatically. FractionComplete will be 0, durationFactor will be 1.
                    animator.addAnimations(layerAnimator.layer.animation)
                    animator.startAnimation(afterDelay: delay)
                } else {
                    //  We need to adjust the duration and the delay of the animation. This can only be done by instantiating a new property animator.
                    let delay = delay * durationFactor
                    
                    //  The following ensures the completion coordinator isn't waiting on the animator that will be removed.
                    animator.stopAnimation(false)
                    animator.finishAnimation(at: .current)
                    
                    //  Create a new animator
                    let animator = propertyAnimatorFor(animationLayer: layerAnimator.layer, durationFactor: durationFactor)
                    completionCoordinator.add(animator: animator)
                    //  Set it as the new animator for this layer
                    layerAnimator.animator = animator
                    
                    animator.startAnimation(afterDelay: delay)
                }
            }
        }
    }
    
    private func pauseAnimation() {
        // Stop (without finishing) the property animator used for transition item frame changes
        sharedElementAnimator?.stopAnimation(true)
        
        // Pause the transition animator
        layerAnimators.forEach { $0.animator.pauseAnimation() }
        
        // Inform the transition context that we have paused
        context.pauseInteractiveTransition()
    }
    
    // MARK: Interaction cycle
    
    var isInteractive: Bool {
        return context.isInteractive
    }
    
    private func startInteraction(with gestureRecognizer: UIGestureRecognizer? = nil) {
        guard let interactionController = interactionController else { return }
        if let specification = transition.sharedElement {
            specification.startInteraction(in: context, gestureRecognizer: gestureRecognizer ?? interactionController.gestureRecognizer)
        }
        interactionController.interactionStarted(in: operationContext, gestureRecognizer: gestureRecognizer ?? interactionController.gestureRecognizer, fractionComplete: totalFractionComplete)
    }
    
    @objc func updateInteraction(_ gestureRecognizer: UIGestureRecognizer) {
        guard let interactionController = interactionController else { return }
        switch gestureRecognizer.state {
        case .began, .changed:
            let progress = interactionController.progress(in: operationContext)
            
            // Calculate the new fractionComplete
            let currentFractionComplete = progress.isStep ? (totalFractionComplete + progress.value) : progress.value
            
            for layerAnimator in layerAnimators {
                let relativeFractionComplete = layerAnimator.effectiveRange.relativeFractionComplete(to: currentFractionComplete)
                // Update the transition animator's fractionCompete to scrub it's animations
                layerAnimator.animator.fractionComplete = CGFloat(relativeFractionComplete)
            }
            
            // Inform the transition context of the updated percent complete
            context.updateInteractiveTransition(CGFloat(currentFractionComplete))
            
            // Update the interactive element, if available
            if let specification = transition.sharedElement {
                specification.updateInteraction(in: context, interactionController: interactionController, progress: progress)
            }
            
            // Reset the gesture recognizer's progress so that we get a step-by-step value each time updateInteraction() is called
            interactionController.resetProgressIfNeeded(in: operationContext)
            
        case .ended, .cancelled:
            // End the interactive phase of the transition
            endInteraction()
        default: break
        }
    }
    
    func endInteraction() {
        // Ensure the context is currently interactive
        guard context.isInteractive, let interactionController = interactionController else { return }
        
        // Inform the transition context of whether we are finishing or cancelling the transition
        let completionPosition = interactionController.completionPosition(in: operationContext, fractionComplete: totalFractionComplete)
        if completionPosition == .end {
            context.finishInteractiveTransition()
        } else {
            context.cancelInteractiveTransition()
        }
        
        interactionController.interactionEnded(in: operationContext, fractionComplete: totalFractionComplete)
        
        // Begin the animation phase of the transition to either the start or finsh position
        animate(completionPosition)
    }
    
    // MARK: Transition Interruption
    
    var interruptibleAnimators: [UIViewImplicitlyAnimating] {
        return layerAnimators.map { $0.animator }
    }
    
    
    private func newInterruptionGestureRecognizer() -> UIGestureRecognizer {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(interruptionGestureStateChanged(_ :)))
        longPressGestureRecognizer.minimumPressDuration = 0.0
        installedInterruptionGestureRecognizer = longPressGestureRecognizer
        return longPressGestureRecognizer
    }
    
    //  Keep a reference to the interruption GestureRecognizer such that we can properly clean up afterwards.
    private weak var installedInterruptionGestureRecognizer: UIGestureRecognizer?
    
    
    @objc func interruptionGestureStateChanged(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            pauseAnimation()
            startInteraction(with: gestureRecognizer)
        case .ended, .cancelled:
            endInteraction()
        default: break
        }
    }
    
    private func removeInterruptionGestureRecognizer() {
        if let installedInterruptionGestureRecognizer = installedInterruptionGestureRecognizer {
            installedInterruptionGestureRecognizer.view?.removeGestureRecognizer(installedInterruptionGestureRecognizer)
        }
    }
}

// MARK: Transition phase delegation methods

fileprivate extension TransitionDriver {
    
    private var uniqueTransitionPhaseDelegates: [TransitionPhaseDelegate] {
        let uniqueParticipatingViewControllers = Array(Set([context.fromViewController, context.toViewController, operationContext.sourceViewController].flatMap { $0 }))
        return uniqueParticipatingViewControllers.flatMap { $0 as? TransitionPhaseDelegate }
    }
    
    fileprivate func willTransition(with sharedElement: SharedElement?) {
        guard let fromViewController = context.fromViewController, let toViewController = context.toViewController else { return }
        uniqueTransitionPhaseDelegates.forEach { $0.willTransition(from: fromViewController, to: toViewController, with: sharedElement) }
    }
    
    fileprivate func didTransition(with sharedElement: SharedElement?) {
        guard let fromViewController = context.fromViewController, let toViewController = context.toViewController else { return }
        uniqueTransitionPhaseDelegates.forEach { $0.didTransition(from: fromViewController, to: toViewController, with: sharedElement) }
    }
    
    fileprivate func cancelledTransition(with sharedElement: SharedElement?) {
        guard let fromViewController = context.fromViewController, let toViewController = context.toViewController else { return }
        uniqueTransitionPhaseDelegates.forEach { $0.cancelledTransition(from: fromViewController, to: toViewController, with: sharedElement) }
    }
}
