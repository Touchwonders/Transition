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
 *  The progress of a transition can either be expressed as an overall fractionComplete,
 *  or as a step relative to the previous progress. Ensure that both the interactionController
 *  and the `sharedElement` of the current Transition (can) handle the same type of progress.
 */
public enum TransitionProgress {
    /// fractionComplete expresses progress as an overall value
    case fractionComplete(AnimationFraction)
    /// step expresses progress as a value relative to the previous progress
    case step(AnimationFraction)
    
    var value: AnimationFraction {
        switch self {
        case .fractionComplete(let value): return value
        case .step(let value): return value
        }
    }
    
    var isStep: Bool {
        switch self {
        case .step(_): return true
        default: return false
        }
    }
}


/**
 *  The TransitionInteractionCoordinator knows how to interpret
 *  the gesture that drives the interaction of a transition.
 *  It informs about transition operation, progress and completion position.
 */
public protocol TransitionInteractionController : class {
    
    /// The GestureRecognizer that drives the interaction of a transition.
    var gestureRecognizer: UIGestureRecognizer { get }
    
    
    /// If the transition has an interactive element, it should be provided by this source.
    weak var sharedElementProvider: SharedElementProvider? { get }
    
    // MARK: Direction
    
    /// Based on the gesture's movement (translation, rotation or whatever applies),
    /// return what kind of transition should be initiated (if at all; return .none if no transition should be initiated).
    /// - It is your responsibility to return an appropriate type of operation 
    /// (navigation / modal / tabBar) for any associated InteractiveTransitionOperationDelegate.
    func operationForInteractiveTransition() -> TransitionOperation
    
    /// Based on the gesture's movement (directionality, velocity) and the original operation, determine whether we should complete at .end, .start or .current:
    func completionPosition(in transitionOperationContext: TransitionOperationContext, fractionComplete: AnimationFraction) -> UIViewAnimatingPosition
    
    // MARK: Progress
    
    /// Progress is not returned as an overall fractionComplete, but rather
    /// as a step-by-step progress.
    func progress(in transitionOperationContext: TransitionOperationContext) -> TransitionProgress
    
    
    // Optional:
    
    /// For deriving stepped progress, you might need to reset the GestureRecognizer's
    /// property that was used to calculate the progress.
    /// For instance: taking a pan gesture's translation for calculating the progress,
    /// and setting it to CGPoint.zero afterwards to reset it for the next call.
    /// Expect `progress(in:)` to be called only once every time the gestureRecognizer updates,
    /// followed by a single call to resetProgressIfNeeded().
    /// The reset step is explicitly separated to avoid unexpected behaviour
    /// if the gestureRecognizer is inspected inbetween the `progress(in:)` call and `resetProgressIfNeeded()`.
    func resetProgressIfNeeded(in transitionOperationContext: TransitionOperationContext) /* optional */
    
    /// interactionStarted() and interactionEnded() can be used to do context-specific setup and cleanup
    /// for calculating the progress. 
    /// Note that the interaction can start as an interruption of a running animation, 
    /// the interruption being recognized by a different gestureRecognizer (a long-press)
    /// than this TransitionInteractionController's gestureRecognizer.
    func interactionStarted(in transitionOperationContext: TransitionOperationContext, gestureRecognizer: UIGestureRecognizer, fractionComplete: AnimationFraction) /* optional */
    func interactionEnded(in transitionOperationContext: TransitionOperationContext, fractionComplete: AnimationFraction) /* optional */
}


//  Optional protocol functions without having to use @objc:
public extension TransitionInteractionController {
    
    func resetProgressIfNeeded(in transitionOperationContext: TransitionOperationContext) {
        //  This default implementation allows you to optionally implement yours.
    }
    
    func interactionStarted(in transitionOperationContext: TransitionOperationContext, gestureRecognizer: UIGestureRecognizer, fractionComplete: AnimationFraction) {
        //  This default implementation allows you to optionally implement yours.
    }
    
    func interactionEnded(in transitionOperationContext: TransitionOperationContext, fractionComplete: AnimationFraction) {
        //  This default implementation allows you to optionally implement yours.
    }
}
