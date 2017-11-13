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


import Transition


/**
 *  This is our animation: a single animation layer that, based on the direction of the operation (present/dismiss)
 *  will set the appropriate transform on the top view.
 */
class SimpleAnimation : TransitionAnimation {
    
    private weak var topView: UIView?
    private var targetTransform: CGAffineTransform = .identity
    
    func setup(in operationContext: TransitionOperationContext) {
        let context = operationContext.context
        let isPresenting = operationContext.operation.isPresenting
        
        //  We have to add the toView to the transitionContext, at the appropriate index:
        if isPresenting {
            context.containerView.addSubview(context.toView)
        } else if context.toView.superview == nil {
            context.containerView.insertSubview(context.toView, belowSubview: context.fromView)
        }
        context.toView.frame = context.finalFrame(for: context.toViewController)
        
        //  We only animate the view that will be on top:
        topView = isPresenting ? context.toView : context.fromView
        
        let hiddenTransform = CGAffineTransform(translationX: 0, y: -context.containerView.bounds.height)
        
        topView?.transform = isPresenting ? hiddenTransform : .identity
        targetTransform = isPresenting ? .identity : hiddenTransform
    }
    
    var layers: [AnimationLayer] {
        return [AnimationLayer(timingParameters: AnimationTimingParameters(animationCurve: .easeOut), animation: animate)]
    }
    
    func animate() {
        topView?.transform = targetTransform
    }
    
    func completion(position: UIViewAnimatingPosition) {}
}
