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
import Transition


class ShapeTransitionAnimation : TransitionAnimation {
    
    /// The operation will be useful later on to add some directionality in the transition animation
    let operation: TransitionOperation
    
    private weak var topView: UIView?
    private var targetEffect: UIVisualEffect?
    private var visualEffectView: UIVisualEffectView!
    
    let rightToLeft: Bool
    
    init(for operation: TransitionOperation, rightToLeft: Bool = false) {
        self.operation = operation
        self.rightToLeft = rightToLeft
    }
    
    /// We have a single animation layer (with full range, set by default).

    var layers: [AnimationLayer] {
        return [AnimationLayer(timingParameters: AnimationTimingParameters(animationCurve: .easeOut), animation: self.animation)]
    }

    
    /// We're about to animate. Set up any initial view state (alpha / transform etc.) and
    /// add the toView and any additional chrome views to the transition context's containerView.
    func setup(in operationContext: TransitionOperationContext) {
        let transitionContext = operationContext.context
        // Ensure the toView has the correct size and position
        transitionContext.toView.frame = transitionContext.finalFrame(for: transitionContext.toViewController)
        
        // Create a visual effect view and animate the effect in the transition animator
        targetEffect = UIBlurEffect(style: .dark)
        visualEffectView = UIVisualEffectView(effect: nil)
        visualEffectView.frame = transitionContext.containerView.bounds
        visualEffectView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        transitionContext.containerView.addSubview(visualEffectView)
        
        topView = transitionContext.toView
        transitionContext.containerView.addSubview(transitionContext.toView)
        
        let directional: CGFloat = (operation.isIncreasingIndex != rightToLeft) ? 1.0 : -1.0    // isIncreasingIndex XOR rightToLeft
        topView?.transform = CGAffineTransform(translationX: directional * transitionContext.containerView.bounds.width * 1.2, y: 0).scaledBy(x: 1.2, y: 1.2).rotated(by: directional * 0.05 * .pi)
    }
    
    /// The animation function that will be given to a UIViewPropertyAnimator.
    /// You should therefore regard this as the body of an animation, so do not
    /// perform any UIView.animate(withDuration: , animations: ) stuff here!
    func animation() {
        topView?.transform = .identity
        visualEffectView.effect = targetEffect
    }
    
    /// The completion function that will be given to a UIViewPropertyAnimator.
    /// Perform any required cleanup here, such as removing chrome views.
    /// You might also need to reset the toView if the transition was cancelled (i.e. position != .end)
    func completion(position: UIViewAnimatingPosition) {
        topView?.transform = .identity
        visualEffectView.removeFromSuperview()
        visualEffectView = nil
    }
    
}
