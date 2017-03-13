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


public class TransitionOperationContext {
    
    public let operation: TransitionOperation
    public let context: UIViewControllerContextTransitioning
    
    
    public init(operation: TransitionOperation, context: UIViewControllerContextTransitioning) {
        self.operation = operation
        self.context = context
    }
    
    public convenience init<T: TransitionOperationType>(operation: T, context: UIViewControllerContextTransitioning) {
        self.init(operation: TransitionOperation(operation), context: context)
    }
    
    
    
    /**
     *  The `sourceViewController` provides additional context next to the context's from- and toViewController.
     *  It represents the viewController that initiated the transition.
     *  It is added because the `fromViewController` might be different from what you would expect:
     *  - For navigation transitions, the fromViewController will be the same as the sourceViewController.
     *  - For tabBar transitions, the fromViewController is the viewController that represents the current tab in the tabBar.
     *   It might be the sourceViewController, but can e.g. also be a navigationController of which the sourceViewController is a child.
     *  - For modal transitions, the fromViewController is the presentingViewController, i.e. it "could be the root
     *  view controller of the window, a parent view controller that is marked as defining the current context, 
     *  or the last view controller that was presented. This view controller may or may not be the same as the one in the source parameter."
    */
    internal(set) var sourceViewController: UIViewController?
}
