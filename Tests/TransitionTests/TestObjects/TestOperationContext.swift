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


import Foundation
import TransitionPlus


extension TransitionOperationContext {
    static func testContext(forOperation: TransitionOperation) -> TransitionOperationContext {
        return TransitionOperationContext(operation: forOperation, context: TestTransitionContext())
    }
}




class TestTransitionContext : NSObject, UIViewControllerContextTransitioning {
    
    override init() {
        super.init()
    }
    
    var containerView: UIView {
        return UIView()
    }
    
    var isAnimated: Bool = true
    
    
    var isInteractive: Bool = true
    
    
    var transitionWasCancelled: Bool = false
    
    
    var presentationStyle: UIModalPresentationStyle = .custom
    
    func updateInteractiveTransition(_ percentComplete: CGFloat) {
        
    }
    
    func finishInteractiveTransition() {
        
    }
    
    func cancelInteractiveTransition() {
        
    }
    
    
    func pauseInteractiveTransition() {
        
    }
    
    
    func completeTransition(_ didComplete: Bool) {
        
    }
    
    
    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        return UIViewController()
    }
    
    
    func view(forKey key: UITransitionContextViewKey) -> UIView? {
        return UIView()
    }
    
    
    var targetTransform: CGAffineTransform = .identity
    
    
    var initialFrame: CGRect = .zero
    func initialFrame(for vc: UIViewController) -> CGRect {
        return initialFrame
    }
    
    var finalFrame: CGRect = .zero
    func finalFrame(for vc: UIViewController) -> CGRect {
        return finalFrame
    }
    
}
