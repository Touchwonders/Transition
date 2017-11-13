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


class DropTargetViewAnimation : TransitionAnimation {
    
    /// The operation will be useful later on to add directionality in the transition animation
    let operation: TransitionOperation
    let translationFactor: () -> CGFloat
    
    private weak var dropTargetView: UIView?
    private var targetTransform = CGAffineTransform.identity
    
    init(for operation: TransitionOperation, translationFactor: @escaping () -> CGFloat) {
        self.operation = operation
        self.translationFactor = translationFactor
    }
    
    
    var timingParameters: AnimationTimingParameters {
        return AnimationTimingParameters(animationCurve: operation.isDismissing ? .easeIn : .easeOut)
    }
    
    /// We have a single animation layer (with full range, set by default).

    var layers: [AnimationLayer] {
        return [AnimationLayer(timingParameters: self.timingParameters, animation: self.animation)]
    }
    
    func setup(in operationContext: TransitionOperationContext) {
        let transitionContext = operationContext.context
        /// The only thing that should move is the dropTargetView
        dropTargetView = operation.isPresenting ? transitionContext.toView : transitionContext.fromView
        
        /// The view's frame will be set such that without any transform it will be fully visible.
        /// We use a transform to determine how much it should be visible after animation (for presenting: a bit; for dismissing: not at all).
        targetTransform = CGAffineTransform(translationX: 0, y: (operation.isPresenting ? self.translationFactor() : 1.0) * -transitionContext.containerView.bounds.height)
        
        if operation.isPresenting {
            transitionContext.containerView.addSubview(transitionContext.toView)
            /// The frame alone would position the toView fullscreen. Its transform will position it completely above the screen.
            transitionContext.toView.frame = transitionContext.finalFrame(for: transitionContext.toViewController)
            dropTargetView?.transform = CGAffineTransform(translationX: 0, y: -transitionContext.containerView.bounds.height)
        }
    }
    
    func animation() {
        dropTargetView?.transform = targetTransform
    }
    
    func completion(position: UIViewAnimatingPosition) { }
}
