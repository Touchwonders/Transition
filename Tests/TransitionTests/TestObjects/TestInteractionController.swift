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


import Foundation
import TransitionPlus


class TestInteractionController : TransitionInteractionController {
    
    var gestureRecognizer: UIGestureRecognizer = UIPanGestureRecognizer()
    
    weak public var interactiveElementProvider: InteractiveTransitionElementProvider? = nil
    
    
    var transitionOperation: TransitionOperation = .none
    
    public func operationForInteractiveTransition() -> TransitionOperation {
        return transitionOperation
    }
    
    
    var completionPosition: UIViewAnimatingPosition = .end
    
    public func completionPosition(in transitionOperationContext: TransitionOperationContext, fractionComplete: CGFloat) -> UIViewAnimatingPosition {
        return completionPosition
    }
    
    var progress: TransitionProgress = .fractionComplete(0.0)
    
    public func progress(in transitionOperationContext: TransitionOperationContext) -> TransitionProgress {
        return progress
    }
    
    /// For deriving stepped progress, you might need to reset the GestureRecognizer's
    /// property that was used to calculate the progress.
    /// For instance: taking a pan gesture's translation for calculating the progress,
    /// and setting it to CGPoint.zero afterwards to reset it for the next call.
    /// Expect `progress(in:)` to be called only once every time the gestureRecognizer updates,
    /// followed by a single call to resetProgressIfNeeded().
    /// The reset step is explicitly separated to avoid unexpected behaviour
    /// if the gestureRecognizer is inspected inbetween the `progress(in:)` call and `resetProgressIfNeeded()`.
    public func resetProgressIfNeeded(in transitionOperationContext: TransitionOperationContext) {
        
    }
    
    /// interactionStarted() and interactionEnded() can be used to do context-specific setup and cleanup
    /// for calculating the progress.
    /// Note that the interaction can start as an interruption of a running animation,
    /// the interruption being recognized by a different gestureRecognizer (a long-press)
    /// than this TransitionInteractionController's gestureRecognizer.
    public func interactionStarted(in transitionOperationContext: TransitionOperationContext, gestureRecognizer: UIGestureRecognizer) {
    
    }
    
    public func interactionEnded(in transitionOperationContext: TransitionOperationContext) {
        
    }
}
