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


public final class TransitionController : NSObject {
    
    
    /// The controller in which transition operations are performed (e.g. UINavigationController, UITabBarController)
    fileprivate(set) public weak var operationController: UIViewController?
    
    /// A delegate that knows how to perform an operation on the operationController (e.g. push on a UINavigationController)
    fileprivate(set) public weak var operationDelegate: InteractiveTransitionOperationDelegate?
    
    /// The controller that knows how to translate a gesture into interaction operation, progress and completionPosition
    fileprivate(set) public weak var interactionController: TransitionInteractionController?
    
    /// A source that provides specific transitions when needed
    fileprivate(set) public weak var transitionsSource: TransitionsSource?
    
    /// If you want to use a custom UIPresentationController for modal transitions, you can provide it via this source.
    public weak var modalPresentationControllerSource: ModalPresentationControllerSource?
    
    
    /// For (non-modal) interactive transitions we need to have an interactionController AND an operationDelegate
    public var canBeInteractive: Bool {
        return interactionController != nil && operationDelegate != nil
    }
    
    // PRIVATE VARIABLES
    
    /// Whether or not the transition was initiated interactively
    fileprivate var initiallyInteractive = false
    
    /// The operation determined from the interaction gesture, that might lead to...
    fileprivate var operationFromGesture: TransitionOperation = .none
    /// ...the operation that is currently executed
    fileprivate var operation: TransitionOperation = .none
    
    
    /// The driver manages the phases of the transition as well as switching between animation and interaction.
    fileprivate var transitionDriver: TransitionDriver?
    
    /// The view on which the intreactionController's gestureRecognizer is installed.
    fileprivate weak var gestureRecognizerView: UIView?
    
    /// Used to set `sourceViewController` in the TransitionOperationContext.
    /// Please see the TransitionOperationContext `.sourceViewController` documentation for additional info.
    fileprivate weak var sourceViewController: UIViewController?
    
    
    /// NAVIGATION
    //  The reason why there are two initializers per transition type, is that the
    //  operationDelegate and interactionController are optional, but can only be both nil or both specified.
    //  If they are nil, this means the transition is custom but not interactive (at least not via the TransitionController).
    
    /**
     Initialize a TransitionController for non-interactive navigation transitions.
     - parameter operationController: the UINavigationController in which the transition operations take place
     - parameter transitionsSource: the source that provides Transitions for operations in `operationController`
     */
    public convenience init(forTransitionsIn navigationController: UINavigationController, transitionsSource: TransitionsSource) {
        self.init(forTransitionsIn: navigationController, transitionsSource: transitionsSource, operationDelegate: nil, interactionController: nil)
    }
    
    /**
     Initialize a TransitionController for interactive navigation transitions.
     - parameter operationController: the UINavigationController in which the transition operations take place
     - parameter transitionsSource: the source that provides Transitions for operations in `operationController`
     - parameter operationDelegate: the object that knows how to perform a push or pop
     - parameter interactionController: the controller that manages the interaction gesture for initiating transitions and interacting with them
     */
    public convenience init(forInteractiveTransitionsIn navigationController: UINavigationController, transitionsSource: TransitionsSource, operationDelegate: InteractiveNavigationTransitionOperationDelegate, interactionController: TransitionInteractionController) {
        self.init(forTransitionsIn: navigationController, transitionsSource: transitionsSource, operationDelegate: operationDelegate, interactionController: interactionController)
    }
    
    /// TABBAR
    
    /**
     Initialize a TransitionController for non-interactive tabBar transitions.
     - parameter operationController: the UITabBarController in which the transition operations take place
     - parameter transitionsSource: the source that provides Transitions for operations in `operationController`
     */
    public convenience init(forTransitionsIn tabBarController: UITabBarController, transitionsSource: TransitionsSource) {
        self.init(forTransitionsIn: tabBarController, transitionsSource: transitionsSource, operationDelegate: nil, interactionController: nil)
    }
    
    /**
     Initialize a TransitionController for interactive tabBar transitions.
     - parameter operationController: the UITabBarController in which the transition operations take place
     - parameter transitionsSource: the source that provides Transitions for operations in `operationController`
     - parameter operationDelegate: the object that knows how to perform a push or pop
     - parameter interactionController: the controller that manages the interaction gesture for initiating transitions and interacting with them
     */
    public convenience init(forInteractiveTransitionsIn tabBarController: UITabBarController, transitionsSource: TransitionsSource, operationDelegate: InteractiveTabBarTransitionOperationDelegate, interactionController: TransitionInteractionController) {
        self.init(forTransitionsIn: tabBarController, transitionsSource: transitionsSource, operationDelegate: operationDelegate, interactionController: interactionController)
    }
    
    
    /**
     The main intializer for navigation/tabBar transitions - not for the public.
     */
    private init(forTransitionsIn operationController: UIViewController, transitionsSource: TransitionsSource, operationDelegate: InteractiveTransitionOperationDelegate?, interactionController: TransitionInteractionController?) {
        self.operationController = operationController
        self.operationDelegate = operationDelegate
        self.interactionController = interactionController
        self.transitionsSource = transitionsSource
        super.init()
        
        if let interactionController = interactionController, canBeInteractive {
            let gestureRecognizer = interactionController.gestureRecognizer
            gestureRecognizer.addTarget(self, action: #selector(interactiveTransitionGestureChanged(gestureRecognizer:)))
            gestureRecognizer.delegate = self
            
            gestureRecognizerView = operationController.view
            gestureRecognizerView?.addGestureRecognizer(gestureRecognizer)
        }
        
        switch operationController {
        case let navigationController as UINavigationController:
            navigationController.delegate = (navigationController.delegate != nil) ? delegateProxy(with: navigationController.delegate!) : self
            
            if let interactionController = interactionController, let interactivePop = navigationController.interactivePopGestureRecognizer, canBeInteractive {
                interactionController.gestureRecognizer.require(toFail: interactivePop)
            }
        case let tabBarController as UITabBarController:
            tabBarController.delegate = (tabBarController.delegate != nil) ? delegateProxy(with: tabBarController.delegate!) : self
        default: break
        }
    }
    
    
    /// MODAL
    //  For modal transitions the source ViewController is the operationController,
    //  since it will be the one executing present(_,animated:,completion:).
    //  We keep track of the source ViewController because further on in the transitionContext,
    //  it might otherwise be unavailable;
    //  In the transitionContext, the fromViewController will be the "presenting" ViewController.
    //  As the documentation of animationController(forPresented:presenting:source:) tells us,
    //  The source is "The view controller whose present(_:animated:completion:) method was called."
    //  The presenting "[..] could be the root view controller of the window, a parent view controller 
    //  that is marked as defining the current context, or the last view controller that was presented. 
    //  This view controller may or may not be the same as the one in the source parameter."
    
    public init(forModalPresentationsFrom sourceViewController: UIViewController, transitionsSource: TransitionsSource) {
        self.operationController = sourceViewController   //  This will be used to set the sourceViewController in the transitionOperationContext
        self.transitionsSource = transitionsSource
        super.init()
    }
    
    
    public init<SourceViewController: UIViewController>(forInteractiveModalPresentationsFrom sourceViewController: SourceViewController, transitionsSource: TransitionsSource, interactionController: TransitionInteractionController) where SourceViewController: InteractiveModalTransitionOperationDelegate {
        self.operationController = sourceViewController   //  This will be used to set the sourceViewController in the transitionOperationContext
        self.operationDelegate = sourceViewController     //  This will be used to execute the present / dismiss
        self.transitionsSource = transitionsSource
        self.interactionController = interactionController
        super.init()
        
        if canBeInteractive {
            let gestureRecognizer = interactionController.gestureRecognizer
            gestureRecognizer.addTarget(self, action: #selector(interactiveTransitionGestureChanged(gestureRecognizer:)))
            gestureRecognizer.delegate = self
            
            //  The GestureRecognizer is installed on the UIWindow to ensure the modal dismissal can also be initiated interactively:
            if let window = sourceViewController.view.window {
                gestureRecognizerView = window
                window.addGestureRecognizer(gestureRecognizer)
            } else {
                print("The sourceViewController.view does not have a window on which to install the interaction gesture recognizer")
            }
        }
    }
    
    
    /// startTransition() is the signal the we should begin the transition, either animated or interactively.
    fileprivate func startTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let transitionsSource = transitionsSource else { return reset() }
        
        // make a combined transition operation context
        let transitionOperationContext = TransitionOperationContext(operation: self.operation, context: transitionContext)
        // set additional context properties:
        transitionOperationContext.sourceViewController = sourceViewController
        
        // request the appropriate transition
        let transition = transitionsSource.transitionFor(operationContext: transitionOperationContext, interactionController: interactionController)
        // initialize a driver for that transition. This will start animation if needed.
        self.transitionDriver = TransitionDriver(transition: transition, operationContext: transitionOperationContext, interactionController: interactionController)
    }
    
    /// cleanup after completing the transition.
    fileprivate func reset() {
        transitionDriver = nil
        initiallyInteractive = false
        operation = .none
        operationFromGesture = .none
        //  The sourceViewController is not reset because for modal dismissal it won't be set but might be reused.
    }
    
    
    /// The callback of the interactionController's gesture recognizer
    func interactiveTransitionGestureChanged(gestureRecognizer: UIGestureRecognizer) {
        guard let operationController = operationController,
            let operationDelegate = operationDelegate else { return }
        
        if gestureRecognizer.state == .began && transitionDriver == nil {
            if !operationFromGesture.isNone {
                initiallyInteractive = true
                
                switch (operationFromGesture, operationController, operationDelegate) {
                
                //  push / pop
                case (.navigation(let navigationOperation), let controller as UINavigationController, let delegate as InteractiveNavigationTransitionOperationDelegate):
                    delegate.performOperation(operation: navigationOperation, forInteractiveTransitionIn: controller, gestureRecognizer: gestureRecognizer)
                    
                //  increase / decrease selected index
                case (.tabBar(let tabBarOperation), let controller as UITabBarController, let delegate as InteractiveTabBarTransitionOperationDelegate):
                    delegate.performOperation(operation: tabBarOperation, forInteractiveTransitionIn: controller, gestureRecognizer: gestureRecognizer)
                    
                //  present / dismiss
                case (.modal(let modalOperation), _, let delegate as InteractiveModalTransitionOperationDelegate):
                    switch modalOperation {
                    case .present:
                        //  The TransitionController here takes care of setting up and executing the operation,
                        //  because the transitioningDelegate must be set on a newly created ViewController prior to presentation.
                        let presentedViewController = delegate.viewControllerForInteractiveModalPresentation(by: operationController, gestureRecognizer: gestureRecognizer)
                        presentedViewController.transitioningDelegate = self
                        presentedViewController.modalPresentationStyle = .custom
                        operationController.present(presentedViewController, animated: true, completion: nil)
                    case .dismiss:
                        if operationController.presentedViewController != nil {
                            operationController.dismiss(animated: true, completion: nil)
                        }
                    case .none: break
                    }
                
                default: //  shouldn't happen:
                    fatalError("Invalid combination of transition operation type and controller")
                    break
                }
            }
        }
    }
    
    
    // MARK: Delegate Proxy
    
    /// A delegate proxy is used to maintain any original delegate for the passed navigationController / tabBarController,
    /// but also making it possible for the TransitionController to register as delegate. Do mind that the original delegate
    /// will take precedence, so if that implements either animationControllerFor: or interactionControllerFor: , behaviour is unpredicable.
    
    private var navigationControllerDelegateProxy: UINavigationControllerDelegateProxy?
    private func delegateProxy(with navigationControllerDelegate: UINavigationControllerDelegate) -> UINavigationControllerDelegate {
        let proxy = UINavigationControllerDelegateProxy(primary: navigationControllerDelegate, secondary: self)
        navigationControllerDelegateProxy = proxy
        return proxy
    }
    
    fileprivate var tabBarControllerDelegateProxy: UITabBarControllerDelegateProxy?
    private func delegateProxy(with tabBarControllerDelegate: UITabBarControllerDelegate) -> UITabBarControllerDelegate {
        let proxy = UITabBarControllerDelegateProxy(primary: tabBarControllerDelegate, secondary: self)
        tabBarControllerDelegateProxy = proxy
        return proxy
    }
    
    
    deinit {
        if let interactionController = interactionController, let gestureRecognizerView = gestureRecognizerView {
            if let installedGestureRecognizers = gestureRecognizerView.gestureRecognizers, installedGestureRecognizers.contains(interactionController.gestureRecognizer) {
                gestureRecognizerView.removeGestureRecognizer(interactionController.gestureRecognizer)
            }
        }
    }
}

// MARK: Transition Animation

/**
 *  The TransitionController will provide the necessary functionality for animating the transition:
 */
extension TransitionController : UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.transitionDriver?.transition.duration ?? 0.0
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if !canBeInteractive {
            startTransition(using: transitionContext)
        }
    }
    
    public func animationEnded(_ transitionCompleted: Bool) {
        reset()
    }
    
    public func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        guard let transitionDriver = transitionDriver else {
            fatalError("No transitionDriver could be initialized. Ensure you initialize your TransitionController with strong-referenced objects.")
        }
        return transitionDriver.interruptibleAnimators.first!
    }
}

// MARK: Transition Interaction

/**
 *  The TransitionController is set as delegate of the interactionController's gesture recognizer
 */
extension TransitionController : UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return canBeInteractive
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let interactionController = interactionController else {
            return false
        }
        
        if let transitionDriver = transitionDriver {
            return transitionDriver.isInteractive
        }
        
        //  we store the operation for use in the gestureRecognizer's callback,
        //  because if the gesture .began, its translation (or whatever applies) will be set to .zero
        operationFromGesture = interactionController.operationForInteractiveTransition()
        return !operationFromGesture.isNone
    }
}

/**
 *  The TransitionController will provide the necessary functionality for the interaction that drives the transition animation:
 */
extension TransitionController : UIViewControllerInteractiveTransitioning {
    
    public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        startTransition(using: transitionContext)
    }
    
    public var wantsInteractiveStart: Bool {
        return initiallyInteractive
    }
}

// MARK: UINavigationController Transitions

extension TransitionController : UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.sourceViewController = fromVC
        self.operation = .navigation(operation)
        return self
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return canBeInteractive ? self : nil
    }
    
}

// MARK: UITabBarController Transitions

extension TransitionController : UITabBarControllerDelegate {
    
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return transitionDriver == nil
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let viewControllers = tabBarController.viewControllers,
            let fromIndex = viewControllers.index(of: fromVC),
            let toIndex = viewControllers.index(of: toVC) else { return nil }
        
        self.sourceViewController = fromVC
        self.operation = .tabBar(fromIndex < toIndex ? .increaseIndex : .decreaseIndex)
        return self
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return canBeInteractive ? self : nil
    }
}

// MARK: Modal UIViewController Transitions

extension TransitionController : UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.sourceViewController = source
        self.operation = .modal(.present)
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.operation = .modal(.dismiss)
        return self
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return canBeInteractive ? self : nil
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return canBeInteractive ? self : nil
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return modalPresentationControllerSource?.modalPresentationController(for: presented, presenting: presenting)
    }
}
