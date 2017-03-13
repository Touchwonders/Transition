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


open class PanInteractionController : TransitionInteractionController {

    
    ///	Initializes an interaction controller configured to push when panning from edge, and pop when panning towards edge.
    public convenience init(forNavigationTransitionsAtEdge edge: TransitionScreenEdge) {
        self.init(transitionEdges: TransitionEdges(forNavigationTransitionsAtEdge: edge))
    }
    
    ///	Initializes an interaction controller configured to present when panning from edge, and dismiss when panning towards edge.
    public convenience init(forModalTransitionsAtEdge edge: TransitionScreenEdge) {
        self.init(transitionEdges: TransitionEdges(forModalTransitionsAtEdge: edge))
    }
    
    //	Initializes an interaction controller configured to increase tab bar index when panning left, and decrease when panning right.
    public static func forTabBarTransitions(rightToLeft: Bool = false) -> PanInteractionController {
        return PanInteractionController(transitionEdges: TransitionEdges.forTabBarTransitions(rightToLeft: rightToLeft))
    }
    
    
    public init(transitionEdges: TransitionEdges) {
        self.transitionEdges = transitionEdges
        panGestureRecognizer.maximumNumberOfTouches = 1
    }
    
    let transitionEdges: TransitionEdges
    
    
    ///  Indicates whether the progress should be updated as relative step or as overall fractionComplete (default).
    open var updateProgressAsStep: Bool = false
    
    ///  The threshold below which ending interaction will cancel the transition
    open var completionThreshold: AnimationFraction = 1.0 / 3.0
    
    ///  A flick allows the user to make a flick gesture towards the end or start of a transition. 
    ///  The speed of this flick might cause a gesture that ended below the completionThreshold to complete the transition nonetheless.
    open var allowFlick: Bool = true
    
    ///  The minimum pan velocity (expressed in points per second) in order to recognize it as a flick
    open var minimumFlickVelocity: CGFloat = 1200
    
    ///  A multiplier used in determining the required pan distance to complete the transition.
    ///  The default 1.0 indicates that the full length of the axis (horizontal or vertical) is used for transition progress.
    ///  Setting the `panDistanceMultiplier` to 0.5 would mean only half of that distance needs to be panned to fully transition.
    open var panDistanceMultiplier: CGFloat = 1.0 {
        didSet {
            assert(panDistanceMultiplier > 0.0, "PanInteractionController.panDistanceMultiplier should be a value higher than 0.")
        }
    }
    
    
    open let panGestureRecognizer = UIPanGestureRecognizer()
    open var gestureRecognizer: UIGestureRecognizer { return panGestureRecognizer }
    
    weak open var sharedElementProvider: SharedElementProvider? = nil
    
    // MARK: Direction
    
    open func operationForInteractiveTransition() -> TransitionOperation {
        let translation = panGestureRecognizer.translation(in: panGestureRecognizer.view)
        let edge = TransitionScreenEdge(vector: CGVector(dx: translation.x, dy: translation.y))
        return transitionEdges.operationFor(screenEdge: edge)
    }
    
    open func completionPosition(in transitionOperationContext: TransitionOperationContext, fractionComplete: AnimationFraction) -> UIViewAnimatingPosition {
        if allowFlick {
            let velocity = panGestureRecognizer.velocity(in: transitionOperationContext.context.containerView)
            let magnitude = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
            //  Can it be regarded as flick?
            if magnitude >= minimumFlickVelocity {
                let flickEdge = TransitionScreenEdge(vector: CGVector(dx: velocity.x, dy: velocity.y))
                let screenEdge = transitionEdges.screenEdgeFor(operation: transitionOperationContext.operation)
                if let screenEdge = screenEdge, flickEdge.axis == screenEdge.axis {
                    //  We managed to determine a single edge towards which was swiped, initiating the operation.
                    //  We also assured that the flick is on the same axis.
                    //  If the direction is the same, complete to the end, otherwise roll back to start.
                    return flickEdge == screenEdge ? .end : .start
                }
            }
        }
        
        if fractionComplete > completionThreshold {
            return .end
        }
        return .start
    }
    
    // MARK: Progress
    
    private var fractionCompleteAtStart: AnimationFraction = 0.0
    
    open func interactionStarted(in transitionOperationContext: TransitionOperationContext, gestureRecognizer: UIGestureRecognizer, fractionComplete: AnimationFraction) {
        fractionCompleteAtStart = fractionComplete
    }
    
    open func progress(in transitionOperationContext: TransitionOperationContext) -> TransitionProgress {
        guard let screenEdge = transitionEdges.screenEdgeFor(operation: transitionOperationContext.operation) else { return updateProgressAsStep ? .step(0) : .fractionComplete(fractionCompleteAtStart) }
        
        let containerView = transitionOperationContext.context.containerView
        let translation = panGestureRecognizer.translation(in: containerView)
        
        let axisSize = ((screenEdge.axis == .horizontal) ? containerView.bounds.width : containerView.bounds.height) * panDistanceMultiplier
        let translationOverAxis = (screenEdge.axis == .horizontal) ? translation.x : translation.y
        let directionalFactor: CGFloat = (screenEdge == .left || screenEdge == .top) ? -1.0 : 1.0
        
        let progress = AnimationFraction(directionalFactor * translationOverAxis / axisSize)
        
        return updateProgressAsStep ? .step(progress) : .fractionComplete(fractionCompleteAtStart + progress)
    }
    
    open func resetProgressIfNeeded(in transitionOperationContext: TransitionOperationContext) {
        if updateProgressAsStep {
            panGestureRecognizer.setTranslation(.zero, in: transitionOperationContext.context.containerView)
        }
    }
}
