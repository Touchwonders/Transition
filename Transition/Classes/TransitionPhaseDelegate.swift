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
 *  Any viewController participating in the transition can conform to TransitionPhaseDelegate
 *  in order to get notified about the start and end of the transition. Note that the passed
 *  fromViewController and toViewController originate from the transitionContext and thus might
 *  differ from the viewController that initiated the transition (depending on transition type).
 *  See: UITransitionContextFromViewControllerKey and UITransitionContextToViewControllerKey,
 *  and UIViewControllerTransitioningDelegate animationController(forPresented:presenting:source:)
 */
public protocol TransitionPhaseDelegate : class {
    
    func willTransition(from fromViewController: UIViewController, to toViewController: UIViewController, with sharedElement: SharedElement?) /* optional */
    
    func didTransition(from fromViewController: UIViewController, to toViewController: UIViewController, with sharedElement: SharedElement?)  /* optional */
    
    func cancelledTransition(from fromViewController: UIViewController, to toViewController: UIViewController, with sharedElement: SharedElement?)  /* optional */
}


//  Optional protocol functions without having to use @objc:
public extension TransitionPhaseDelegate {
    
    func willTransition(from fromViewController: UIViewController, to toViewController: UIViewController, with sharedElement: SharedElement?) {
        //  This default implementation allows you to optionally implement yours.
    }
    
    func didTransition(from fromViewController: UIViewController, to toViewController: UIViewController, with sharedElement: SharedElement?) {
        //  This default implementation allows you to optionally implement yours.
    }
    
    func cancelledTransition(from fromViewController: UIViewController, to toViewController: UIViewController, with sharedElement: SharedElement?) {
        //  This default implementation allows you to optionally implement yours.
    }
}
