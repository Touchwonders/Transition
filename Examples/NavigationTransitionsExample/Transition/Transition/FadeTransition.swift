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

class FadeTransition: TransitionAnimation {
    
    private var operation: TransitionOperation
    private var operationContext: TransitionOperationContext!
    private var context: UIViewControllerContextTransitioning!
    
    init(for operation: TransitionOperation) {
        self.operation = operation
    }
    
    func setup(in operationContext: TransitionOperationContext) {
        self.operationContext = operationContext
        context = operationContext.context
        context.containerView.backgroundColor = UIColor(red: 82.0/255.0, green: 77.0/255.0, blue: 153.0/255.0, alpha: 1.0)
        context.toView.frame = context.finalFrame(for: context.toViewController)
        if isPresenting {
            context.containerView.addSubview(context.toView)
        } else {
            context.containerView.insertSubview(context.toView, at: 0)
        }
        
        context.toView.alpha = 0
    }
    
    func completion(position: UIViewAnimatingPosition) {
        context.fromView.alpha = 1.0
        
        if position != .end {
            context.toView.removeFromSuperview()
        }
    }
    
    var layers: [AnimationLayer] {
        return [
            AnimationLayer(range: AnimationRange(start: 0.0, end: 0.2), timingParameters: AnimationTimingParameters(controlPoint1: CGPoint(x: 0.0, y: 0.0), controlPoint2: CGPoint(x: 1.0, y: 1.0)), animation: earlyFadeOut, identifier: "earlyFadeOut"),
            AnimationLayer(range: AnimationRange(start: 0.1, end: 0.4), timingParameters: AnimationTimingParameters(controlPoint1: CGPoint(x: 0.0, y: 0.0), controlPoint2: CGPoint(x: 1.0, y: 1.0)), animation: delayedFadeIn, identifier: "delayedFadeIn")
        ]
    }
    
    var isPresenting: Bool {
        return operationContext.operation.isPresenting
    }
    
    var earlyFadeOut: AnimationFunction {
        return {
            self.context.fromView.alpha = 0
        }
    }
    
    var delayedFadeIn: AnimationFunction {
        return {
            self.context.toView.alpha = 1
        }
    }
}
