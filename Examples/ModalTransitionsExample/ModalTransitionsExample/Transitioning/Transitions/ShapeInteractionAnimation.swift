//
//    MIT License
//
//    Copyright (c) 2017 Touchwonders B.V.
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
import Transition


class ShapeInteractionAnimation : SharedElementTransition {
    
    /// The interactionController's gesture recognizer will be used later on for calculating the appropriate velocity
    fileprivate weak var interactionController: TransitionInteractionController?
    
    /// We keep a reference to the context so that we can derive the appropriate gesture velocity in that context's view
    fileprivate weak var context: UIViewControllerContextTransitioning!
    
    init(interactionController: TransitionInteractionController) {
        self.interactionController = interactionController
    }
    
    // MARK: TransitionAnimationSpecification
    
    var timingParameters: AnimationTimingParameters {
        /// UISpringTimingParameters have a derived duration until equilibrium. If the interaction gesture had
        /// a high velocity, the timingParameters should reflect this in the excitation of the mass-spring system (`initialVelocity`).
        return AnimationTimingParameters(mass: 2, stiffness: 1500, damping: 98, initialVelocity: timingCurveVelocity())
    }
    
    func setup(in operationContext: TransitionOperationContext) {
        let transitionContext = operationContext.context
        
        guard let transitioningShapeView = sharedElement as? TransitioningShapeView, let originalShapeView = transitioningShapeView.originalShapeView else { return }
        self.context = transitionContext
        let transitioningView = transitioningShapeView.transitioningView
        transitioningView.frame = transitionContext.containerView.convert(originalShapeView.frame, from: originalShapeView.superview)
        /// We hide the original ShapeView to simulate dragging it.
        originalShapeView.alpha = 0.0
        transitionContext.containerView.addSubview(transitioningView)
    }
    
    func animation() {
        guard let shapeView = sharedElement as? TransitioningShapeView else { return }
        /// Depending on whether the interaction prior to this animation has lead to continuing towards completion or
        /// moving towards cancellation (`animatingPosition` is .end or .start respectively), animate the shapeView to
        /// its target or initial frame.
        shapeView.transitioningView.frame = (animatingPosition == .end ? shapeView.targetFrame : shapeView.initialFrame)
    }
    
    func completion(position: UIViewAnimatingPosition) {
        if position != .end {
            guard let transitioningShapeView = sharedElement as? TransitioningShapeView else { return }
            transitioningShapeView.transitioningView.removeFromSuperview()
            transitioningShapeView.originalShapeView?.alpha = 1.0
        }
    }
    
    // MARK: SharedElementAnimationSpecification
    
    var animatingPosition: UIViewAnimatingPosition = .end
    
    /// This needs to be present during animation / update, but might not be available at initialization.
    var sharedElement: SharedElement? = nil
    
    //  no initial actions needed
    func startInteraction(in context: UIViewControllerContextTransitioning, gestureRecognizer: UIGestureRecognizer) {}
    
    func updateInteraction(in context: UIViewControllerContextTransitioning, interactionController: TransitionInteractionController, progress: TransitionProgress) {
        guard let shapeView = sharedElement as? TransitioningShapeView else { return }
        ///  The selected shapeView should move with the gesture
        shapeView.transitioningView.center = interactionController.gestureRecognizer.location(in: context.containerView) - shapeView.touchOffset
    }
}


// MARK: Velocity

extension ShapeInteractionAnimation {

    fileprivate func timingCurveVelocity() -> CGVector {
        guard let panGestureRecognizer = interactionController?.gestureRecognizer as? UIPanGestureRecognizer,
              let context = context,
              let transitioningShapeView = sharedElement as? TransitioningShapeView else { return CGVector.zero }
        // Convert the gesture recognizer's velocity into the initial velocity for the animation curve
        let velocity = panGestureRecognizer.velocity(in: context.containerView)
        
        let currentFrame = transitioningShapeView.transitioningView.frame
        let targetFrame = transitioningShapeView.targetFrame
        
        let dx = abs(targetFrame.midX - currentFrame.midX)
        let dy = abs(targetFrame.midY - currentFrame.midY)
        
        guard dx > 0.0 && dy > 0.0 else {
            return CGVector.zero
        }
        
        let range = CGFloat(35.0)
        let clippedVx = clip(-range, range, velocity.x / dx)
        let clippedVy = clip(-range, range, velocity.y / dy)
        return CGVector(dx: clippedVx, dy: clippedVy)
    }
    
}
