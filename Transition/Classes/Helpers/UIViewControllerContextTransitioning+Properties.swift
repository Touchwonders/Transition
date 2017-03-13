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


public extension UIViewControllerContextTransitioning {
    
    /**
     Identifies the view controller that is visible at the beginning of the transition
     (and at the end of a canceled transition). This view controller is typically the 
     one presenting the "to” view controller or is the one being replaced by the "to” 
     view controller.
    */
    public var fromViewController: UIViewController! {
        return self.viewController(forKey: .from)
    }
    
    /**
     Identifies the view controller that is visible at the end of a completed transition.
     This view controller is the one being presented.
    */
    public var toViewController: UIViewController! {
        return self.viewController(forKey: .to)
    }
    
    
    /**
     Identifies the view that is shown at the beginning of the transition (and at the end
     of a canceled transition). This view is typically the presenting view controller’s view.
    */
    public var fromView: UIView! {
        return self.view(forKey: .from)
    }
    
    /**
     Identifies the view that is shown at the end of a completed transition. This view is 
     typically the presented view controller’s view but may also be an ancestor of that view.
    */
    public var toView: UIView! {
        return self.view(forKey: .to)
    }
}


public extension UIViewControllerContextTransitioning {
    
    /**
        This installs the to and from view when necessary, based on the operation.
        It returns the top-most view which is either the fromView or toView.
     */
    public func defaultViewSetup(for operation: TransitionOperation) -> UIView? {
        switch operation {
        case .navigation(let navigationOperation):  return defaultViewSetup(for: navigationOperation)
        case .modal(let modalOperation):            return defaultViewSetup(for: modalOperation)
        case .tabBar(let tabBarOperation):          return defaultViewSetup(for: tabBarOperation)
        default: return nil
        }
    }
    
    public func defaultViewSetup(for navigationOperation: UINavigationControllerOperation) -> UIView? {
        switch navigationOperation {
        case .push:
            containerView.addSubview(toView)
        case .pop:
            if toView.superview == nil {
                containerView.insertSubview(toView, belowSubview: fromView)
            }
        default: return nil
        }
        toView.frame = finalFrame(for: toViewController)
        return navigationOperation == .push ? toView : fromView
    }
    
    public func defaultViewSetup(for modalOperation: UIViewControllerModalOperation) -> UIView? {
        switch modalOperation {
        case .present:
            containerView.addSubview(toView)
        case .dismiss:
            if toView.superview == nil {
                containerView.insertSubview(toView, belowSubview: fromView)
            }
        default: return nil
        }
        toView.frame = finalFrame(for: toViewController)
        return modalOperation == .present ? toView : fromView
    }
    
    public func defaultViewSetup(for tabBarOperation: UITabBarControllerOperation) -> UIView? {
        guard tabBarOperation != .none else { return nil }
        containerView.addSubview(toView)
        toView.frame = finalFrame(for: toViewController)
        return toView
    }
}
