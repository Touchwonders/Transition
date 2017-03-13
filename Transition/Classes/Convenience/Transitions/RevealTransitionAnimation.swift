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


open class RevealTransitionAnimation : EdgeTransitionAnimation {
    
    private weak var topView: UIView?
    private weak var bottomView: UIView?
    
    private var targetTransform: CGAffineTransform = .identity
    
    open override func setup(in operationContext: TransitionOperationContext) {
        let context = operationContext.context
        
        guard let topView = context.defaultViewSetup(for: operationContext.operation),
            let transitionEdge = transitionScreenEdgeFor(operation: operationContext.operation)
            else { return }
        
        /// By default, the toView is installed above the fromView, returning the toView as the topView.
        /// For this transtion, we require the fromView to be positioned above the toView.
        let bottomView = (topView == context.toView) ? context.fromView : context.toView
        context.containerView.bringSubview(toFront: bottomView!)
        self.topView = bottomView
        self.bottomView = topView
        
        let isDismissing = operationContext.operation.isDismissing
        
        let effectiveTransitionEdge = isDismissing ? transitionEdge.opposite : transitionEdge
        
        let hiddenTransform = transformForTranslatingViewTo(edge: effectiveTransitionEdge, outside: context.containerView.bounds)
        
        let initialTransform = isDismissing ? hiddenTransform : .identity
        targetTransform = isDismissing ? .identity : hiddenTransform
        
        self.topView?.transform = initialTransform
    }
    
    open override var layers: [AnimationLayer] {
        return [AnimationLayer(timingParameters: AnimationTimingParameters(animationCurve: animationCurve), animation: animate)]
    }
    
    open func animate() {
        topView?.transform = targetTransform
    }
    
    open override func completion(position: UIViewAnimatingPosition) {
        if position != .end {
            bottomView?.removeFromSuperview()
        }
        topView?.transform = .identity
    }
}
