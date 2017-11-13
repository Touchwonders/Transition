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

final class InteractiveZoomTransitionController: InteractiveNavigationTransitionOperationDelegate, TransitionInteractionController {
    public let navigationController: UINavigationController
    public let gestureRecognizer: UIGestureRecognizer
    private var transitionController: TransitionController!
    
    fileprivate var initialTouchPoint: CGPoint = .zero
    fileprivate var lastFractionComplete: AnimationFraction = 0.0
    
    fileprivate var item: ZoomTransitionItem?
    
    init(with navigationController: UINavigationController) {
        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.maximumNumberOfTouches = 1
        self.gestureRecognizer = panGestureRecognizer
        self.navigationController = navigationController
        
        self.transitionController = TransitionController(forInteractiveTransitionsIn: navigationController, transitionsSource: self, operationDelegate: self, interactionController: self)
    }
    
    var sharedElementProvider: SharedElementProvider? {
        return self
    }
    
    func interactionStarted(in operationContext: TransitionOperationContext, gestureRecognizer: UIGestureRecognizer, fractionComplete: AnimationFraction) {
        lastFractionComplete = fractionComplete
        if operationContext.operation.isDismissing {
            initialTouchPoint = gestureRecognizer.location(in: operationContext.context.containerView)
        }
    }
}

extension InteractiveZoomTransitionController : SharedElementProvider {
    
    func sharedElementForInteractiveTransition(with interactionController: TransitionInteractionController, in operationContext: TransitionOperationContext) -> SharedElement? {
        guard let toViewController = operationContext.context.toViewController as? CollectionViewController else { return nil }
        guard let fromViewController = operationContext.context.fromViewController as? CollectionViewController else { return nil }
        guard let header = operationContext.operation.isPresenting ? toViewController.header : fromViewController.header else { return nil }
        
        let isPresenting = operationContext.operation.isPresenting
        
        let initialFrame: CGRect
        let targetFrame: CGRect
        
        if isPresenting {
            initialFrame = fromViewController.targetFrame
            targetFrame = CGRect(origin: CGPoint(x: CollectionViewController.margin, y: CollectionViewController.margin), size: header.image.frame.size)
        } else {
            initialFrame = CGRect(origin: CGPoint(x: CollectionViewController.margin, y: CollectionViewController.margin), size: header.image.frame.size)
            targetFrame = toViewController.targetFrame
        }
        
        let imageView = header.image
        
        item = ZoomTransitionItem(initialFrame: initialFrame, targetFrame: targetFrame, imageView: imageView)
        
        return item
    }
}

extension InteractiveZoomTransitionController {
    
    func performOperation(operation: UINavigationControllerOperation, forInteractiveTransitionIn controller: UINavigationController, gestureRecognizer: UIGestureRecognizer) {
        switch operation {
        case .pop:
            navigationController.popViewController(animated: true)
        default: return
        }
    }
}

extension InteractiveZoomTransitionController {
    
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer {
        return gestureRecognizer as! UIPanGestureRecognizer
    }
    
    func operationForInteractiveTransition() -> TransitionOperation {
        let translation = panGestureRecognizer.translation(in: gestureRecognizer.view)
        
        let translationIsVertical = (translation.y > 0) && (abs(translation.y) > abs(translation.x))
        if translationIsVertical && (navigationController.viewControllers.count > 1) {
            if let topViewController = navigationController.topViewController as? CollectionViewController {
                if let hitView = topViewController.view.hitTest(gestureRecognizer.location(in: topViewController.view), with: nil),
                let header = topViewController.header, hitView == header.container {
                    return .navigation(.pop)
                }
            }
        }
        return .none
    }
    
    func completionPosition(in operationContext: TransitionOperationContext, fractionComplete: AnimationFraction) -> UIViewAnimatingPosition {
        let completionThreshold: AnimationFraction = 0.33
        let flickMagnitude: CGFloat = 1200 //pts/sec
        let velocity = panGestureRecognizer.velocity(in: operationContext.context.containerView).vector
        let isFlick = (velocity.magnitude > flickMagnitude)
        let isFlickDown = isFlick && (velocity.dy > 0.0)
        let isFlickUp = isFlick && (velocity.dy < 0.0)
        
        let isPresenting = operationContext.operation.isPresenting
        let isDismissing = operationContext.operation.isDismissing
        
        if (isPresenting && isFlickUp) || (isDismissing && isFlickDown) {
            return .end
        } else if (isPresenting && isFlickDown) || (isDismissing && isFlickUp) {
            return .start
        } else if fractionComplete > completionThreshold {
            return .end
        }
        
        return .start
    }
    
    public func progress(in operationContext: TransitionOperationContext) -> TransitionProgress {
        let containerView = operationContext.context.containerView
        let currentLocation = panGestureRecognizer.location(in: containerView)
        let targetLocation = CGPoint(x: containerView.bounds.midX, y: containerView.bounds.maxY)
        let initialDistance = CGVector(dx: targetLocation.x - initialTouchPoint.x, dy: targetLocation.y - initialTouchPoint.y).magnitude
        let currentDistance = CGVector(dx: targetLocation.x - currentLocation.x, dy: targetLocation.y - currentLocation.y).magnitude
        
        let fraction = 1.0 - min(1.0, max(0.0, (currentDistance / initialDistance)))
        lastFractionComplete = AnimationFraction(fraction)
        
        return .fractionComplete(lastFractionComplete)
    }
    
    func progressStep(in operationContext: TransitionOperationContext) -> CGFloat {
        return (operationContext.operation.isPresenting ? -1.0 : 1.0) * panGestureRecognizer.translation(in: operationContext.context.containerView).y / operationContext.context.containerView.bounds.midY
    }
    
    func resetProgress(in operationContext: TransitionOperationContext) {
        panGestureRecognizer.setTranslation(CGPoint.zero, in: operationContext.context.containerView)
    }
}

extension InteractiveZoomTransitionController : TransitionsSource {
    
    func transitionFor(operationContext: TransitionOperationContext, interactionController: TransitionInteractionController?) -> Transition {
        let fadeTransition = FadeTransition(for: operationContext.operation)
        let interactiveZoomTransition = interactionController.flatMap { InteractiveZoomTransition(interactionController: $0) }
        return Transition(duration: 0.8, animation: fadeTransition, sharedElement: interactiveZoomTransition)
    }
}
