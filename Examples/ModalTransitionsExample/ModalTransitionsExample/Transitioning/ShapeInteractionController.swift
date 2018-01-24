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


/**
 *  The TransitionInteractionController manages a single gestureRecognizer
 *  and knows how to determine from a gesture what kind of transition operation
 *  should be initiated, what the progress during interaction is, and how
 *  the operation should complete.
 *
 *  The ShapeInteractionController covers interaction with a ShapeView, as well as
 *  the dismissing gesture for the DropTargetView.
 */
class ShapeInteractionController : NSObject, TransitionInteractionController {

    /// The TransitionInteractionController requires a `gestureRecognizer` (see further on).
    /// We know that the gestureRecognizer is a panGestureRecognizer:
    let panGestureRecognizer: UIPanGestureRecognizer
    
    /// We keep a reference to the sourceViewController to be able to
    /// know if there's already a presentedViewController and determine
    /// if the gesture should lead to present or dismiss.
    private(set) weak var sourceViewController: UIViewController?
    
    /// This is the point at which a ShapeView should be dropped. We need it for
    /// computing the fractionComplete of the transition.
    let dropPoint: CGPoint
    
    /// The initialTouchPoint is used to determine the total movement (distance to dropPoint)
    /// that needs to be made towards completing the transition.
    fileprivate var initialTouchPoint: CGPoint = .zero
    
    /// The fractionComplete is stored to determine the completionPosition when
    /// the interactive gesture ends and we should animate to either .end or .start.
    fileprivate var lastFractionComplete: AnimationFraction = 0.0
    
    
    /// We need all shapeViews in order to do hit testing, leading to...
    let shapeViews: [ShapeView]
    /// ...a selected ShapeView. Its transitioningShapeView will be the sharedElement of the transition.
    var transitioningShapeView: TransitioningShapeView?
    
    
    init(forViewController sourceViewController: UIViewController, shapeViews: [ShapeView], dropPoint: CGPoint) {
        self.panGestureRecognizer = UIPanGestureRecognizer()
        self.sourceViewController = sourceViewController
        self.shapeViews = shapeViews
        self.dropPoint = dropPoint
        super.init()
        
        panGestureRecognizer.maximumNumberOfTouches = 1
        panGestureRecognizer.addTarget(self, action: #selector(gestureStateChanged(_:)))
    }
    
    /// We register for the gesture to set the touch offset on the selected shape every time 
    /// that shapeView is touched (might be multiple times during transition).
    @objc func gestureStateChanged(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began, let transitioningShapeView = transitioningShapeView, let view = gestureRecognizer.view {
            let gestureLocationInView = gestureRecognizer.location(in: view)
            transitioningShapeView.touchOffset = gestureLocationInView - view.convert(transitioningShapeView.transitioningView.center, from: transitioningShapeView.transitioningView.superview)
        }
    }
    
    // MARK: TransitionInteractionController
    
    ///  This is the general gestureRecognizer property from the TransitionInteractionController protocol
    var gestureRecognizer: UIGestureRecognizer {
        return panGestureRecognizer
    }
    
    ///  The ShapeInteractionController already implements hit-testing on ShapeViews so it is
    ///  only logical it is also the sharedElementProvider
    var sharedElementProvider: SharedElementProvider? {
        return self
    }

    ///  Based on the gesture's movement and the type of transition it is concerned with,
    ///  Return the appropriate transition operation, or .none if the movement is insufficient.
    func operationForInteractiveTransition() -> TransitionOperation {
        guard let sourceViewController = sourceViewController else { return .modal(.none) }
        
        let translation = panGestureRecognizer.translation(in: panGestureRecognizer.view)
        let translationIsVertical = abs(translation.y) > abs(translation.x)
        
        /// Only begin a transition if the movement is vertical.
        if translationIsVertical && translation.y < 0 {
            
            /// Only begin presenting if there isn't a presented ViewController already; otherwise begin dismiss.
            if sourceViewController.presentedViewController == nil {
                /// A `present` can only be done if there's a selected shapeView.
                if currrentlyHitShapeView() != nil {
                    return .modal(.present)
                }
            } else {
                /// Any gesture upwards will suffice for dismissing:
                return .modal(.dismiss)
            }
        }
        
        return .modal(.none)
    }
    
    ///  The gesture ended, but the transition not yet. Based on the progress and movement / velocity of the gesture,
    ///  determine if the transition should continue to the end, or rewind to start (cancelling the transition).
    func completionPosition(in operationContext: TransitionOperationContext, fractionComplete: AnimationFraction) -> UIViewAnimatingPosition {
        if operationContext.operation.isPresenting && transitioningShapeView == nil { return .start }
        let completionThreshold: AnimationFraction = 1.0 / 3.0
        let flickMagnitude: CGFloat = 1200 //pts/sec
        let velocity = panGestureRecognizer.velocity(in: operationContext.context.containerView).vector
        let isFlick = (velocity.magnitude > flickMagnitude)
        let isFlickUp = isFlick && velocity.dy < 0.0
        if isFlickUp || lastFractionComplete > completionThreshold {
            return .end
        }
        return .start
    }
    
    func progress(in operationContext: TransitionOperationContext) -> TransitionProgress {
        let containerView = operationContext.context.containerView
        var currentLocation = panGestureRecognizer.location(in: containerView)
        
        
        if operationContext.operation.isPresenting {
            guard let transitioningShapeView = transitioningShapeView else { return .fractionComplete(1.0) }
            /// For presenting, we want to use the distance between the selected ShapeView's center and the dropPoint as total distance.
            let offsetDropPoint = CGPoint(x: dropPoint.x + transitioningShapeView.touchOffset.dx, y: dropPoint.y + transitioningShapeView.touchOffset.dy)
            /// Do not use any movement above the dropPoint:
            currentLocation.y = max(currentLocation.y, offsetDropPoint.y)
            
            /// Only take into account the vertical distance (including the horizontal axis will make the transition a bit weird):
            let totalDistance = offsetDropPoint.y - initialTouchPoint.y
            let currentDistance = offsetDropPoint.y - currentLocation.y
            
            let currentFractionComplete = AnimationFraction(1.0 - (currentDistance / totalDistance))
            lastFractionComplete = currentFractionComplete
            return .fractionComplete(currentFractionComplete)
        } else {
            /// Any movement upwards should progress the transition
            let currentFractionComplete = AnimationFraction((initialTouchPoint.y - currentLocation.y) / containerView.bounds.height)
            lastFractionComplete = currentFractionComplete
            return .fractionComplete(currentFractionComplete)
        }
    }
    
    func interactionStarted(in operationContext: TransitionOperationContext, gestureRecognizer: UIGestureRecognizer) {
        lastFractionComplete = 0.0
        /// For presenting, the initialTouchPoint is set when providing the sharedElementForInteractiveTransition (see below).
        /// For dismissing, this is not called (the sharedElement is only used when presenting) but we still need the initialTouchPoint.
        if operationContext.operation.isDismissing {
            initialTouchPoint = gestureRecognizer.location(in: operationContext.context.containerView)
        }
    }
    
    fileprivate func currrentlyHitShapeView() -> ShapeView? {
        guard let view = gestureRecognizer.view else { return nil }
        let gestureLocationInView = gestureRecognizer.location(in: view)
        return shapeViews.filter { $0.superview!.convert($0.frame, to: view).contains(gestureLocationInView) }.first
    }
}



extension ShapeInteractionController : SharedElementProvider {
    
    func sharedElementForInteractiveTransition(with interactionController: TransitionInteractionController, in operationContext: TransitionOperationContext) -> SharedElement? {
        /// Only provide a shared element when we are presenting and there is an actual hitView (selected shape) for the gesture.
        guard operationContext.operation.isPresenting,
            let selectedShape = currrentlyHitShapeView() else {
            self.transitioningShapeView = nil
            return nil
        }
        let view = operationContext.context.containerView
        
        /// Get a TransitioningShapeView for the selected ShapeView:
        let transitioningShapeView = selectedShape.transitioningShapeView
        self.transitioningShapeView = transitioningShapeView
        
        transitioningShapeView.initialFrame = view.convert(selectedShape.frame, from: selectedShape.superview)
        transitioningShapeView.targetFrame = CGRect(origin: CGPoint(x: dropPoint.x - selectedShape.bounds.midX, y: dropPoint.y - selectedShape.bounds.midY), size: selectedShape.bounds.size)
        initialTouchPoint = gestureRecognizer.location(in: view)    /// At which point do we begin?
        transitioningShapeView.touchOffset = initialTouchPoint - view.convert(selectedShape.center, from: selectedShape.superview)  /// Also save that point relative to the shape's center.
        return transitioningShapeView
    }
}
