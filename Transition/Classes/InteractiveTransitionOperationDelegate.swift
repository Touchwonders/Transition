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
 *  The InteractiveTransitionOperationDelegate is used for delegating the execution
 *  of an operation on either a UINavigationController or UITabBarController, as
 *  a direct result of an interactiveTransition's gesture initiating this operation.
 *  For modal transitions, on `.present` it is used to request the "presented" viewController.
 */
public protocol InteractiveTransitionOperationDelegate: class {}


public protocol InteractiveNavigationTransitionOperationDelegate : InteractiveTransitionOperationDelegate {
    
    /// An interactive transition gesture should lead to either a push or pop. Make it happen.
    /// The gestureRecognizer is passed as additional context for the operation and can be used
    /// on .push to determine what kind of ViewController should be pushed.
    func performOperation(operation: UINavigationControllerOperation, forInteractiveTransitionIn controller: UINavigationController, gestureRecognizer: UIGestureRecognizer)
}


public protocol InteractiveTabBarTransitionOperationDelegate : InteractiveTransitionOperationDelegate {
    
    /// An interactive transition gesture should lead to either an increase or decrease of the selected tab index. Make it happen.
    /// The gestureRecognizer is passed as additional context for the operation.
    func performOperation(operation: UITabBarControllerOperation, forInteractiveTransitionIn controller: UITabBarController, gestureRecognizer: UIGestureRecognizer)
}


public protocol InteractiveModalTransitionOperationDelegate : InteractiveTransitionOperationDelegate {
    
    /// An interactive transition gesture triggered the modal presentation of a viewController.
    /// This method should return that viewController, but not take action to present it (that will
    /// be taken care of by the TransitionController).
    /// The gestureRecognizer is passed as additional context for the operation and can be used
    /// to determine what kind of ViewController should be presented.
    func viewControllerForInteractiveModalPresentation(by sourceViewController: UIViewController, gestureRecognizer: UIGestureRecognizer) -> UIViewController
}
