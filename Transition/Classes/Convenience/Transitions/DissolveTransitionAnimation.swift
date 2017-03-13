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


open class DissolveTransitionAnimation : TransitionAnimation {
    
    public init() {}
    
    open var animationCurve: UIViewAnimationCurve = .easeInOut
    
    private weak var topView: UIView?
    private var targetAlpha: CGFloat = 0.0
    
    open func setup(in operationContext: TransitionOperationContext) {
        let context = operationContext.context
        
        guard let topView = context.defaultViewSetup(for: operationContext.operation) else { return }
        
        self.topView = topView
        
        let isDismissing = operationContext.operation.isDismissing
        let initialAlpha: CGFloat = isDismissing ? 1.0 : 0.0
        self.targetAlpha = 1.0 - initialAlpha
        
        self.topView?.alpha = initialAlpha
    }
    
    open var layers: [AnimationLayer] {
        return [AnimationLayer(timingParameters: AnimationTimingParameters(animationCurve: animationCurve), animation: animate)]
    }
    
    open func animate() {
        topView?.alpha = targetAlpha
    }
    
    open func completion(position: UIViewAnimatingPosition) {
        if position != .end {
            topView?.removeFromSuperview()
        }
    }
}
