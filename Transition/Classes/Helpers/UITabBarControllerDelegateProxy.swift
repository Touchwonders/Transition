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


public class UITabBarControllerDelegateProxy : DelegateProxy<UITabBarControllerDelegate>, UITabBarControllerDelegate {
    
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return firstDelegateRespondingTo(#selector(tabBarController(_:shouldSelect:)))?.tabBarController?(tabBarController, shouldSelect: viewController) ?? false
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        delegates.forEach { $0.tabBarController?(tabBarController, didSelect: viewController) }
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, willBeginCustomizing viewControllers: [UIViewController]) {
        delegates.forEach { $0.tabBarController?(tabBarController, willBeginCustomizing: viewControllers) }
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, willEndCustomizing viewControllers: [UIViewController], changed: Bool) {
        delegates.forEach { $0.tabBarController?(tabBarController, willEndCustomizing: viewControllers, changed: changed) }
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, didEndCustomizing viewControllers: [UIViewController], changed: Bool) {
        delegates.forEach { $0.tabBarController?(tabBarController, didEndCustomizing: viewControllers, changed: changed) }
    }
    
    public func tabBarControllerSupportedInterfaceOrientations(_ tabBarController: UITabBarController) -> UIInterfaceOrientationMask {
        return firstDelegateRespondingTo(#selector(tabBarControllerSupportedInterfaceOrientations(_:)))?.tabBarControllerSupportedInterfaceOrientations?(tabBarController) ?? UIInterfaceOrientationMask()
    }
    
    public func tabBarControllerPreferredInterfaceOrientationForPresentation(_ tabBarController: UITabBarController) -> UIInterfaceOrientation {
        return firstDelegateRespondingTo(#selector(tabBarControllerPreferredInterfaceOrientationForPresentation(_:)))?.tabBarControllerPreferredInterfaceOrientationForPresentation?(tabBarController) ?? .unknown
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return firstDelegateRespondingTo(#selector(tabBarController(_:interactionControllerFor:)))?.tabBarController?(tabBarController, interactionControllerFor: animationController)
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return firstDelegateRespondingTo(#selector(tabBarController(_:animationControllerForTransitionFrom:to:)))?.tabBarController?(tabBarController, animationControllerForTransitionFrom: fromVC, to: toVC)
    }
    
}
