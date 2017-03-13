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
 *  A type representing the kinds of transition operations that can be performed
 *  in its associated controller type (e.g. a UINavigationControllerOperation (.push / .pop)
 *  for controller of type UINavigationController).
 */
public protocol TransitionOperationType {}



extension UINavigationControllerOperation: TransitionOperationType {}

/**
 *  A transition operation that can be performed on a UITabBarController.
 */
public enum UITabBarControllerOperation {
    case none, increaseIndex, decreaseIndex
}

extension UITabBarControllerOperation: TransitionOperationType {}


extension UITabBarController {
    /**
     *  Adjust the selectedIndex by either increasing or decreasing it.
     *  The resulting selected index is automatically kept within bounds [0..<viewControllers.count]
     */
    public func perform(operation: UITabBarControllerOperation) {
        switch operation {
        case .increaseIndex:
            self.selectedIndex = self.selectedIndex + 1
        case .decreaseIndex:
            self.selectedIndex = self.selectedIndex - 1
        default: break
        }
    }
}


public enum UIViewControllerModalOperation {
    case none, present, dismiss
}

extension UIViewControllerModalOperation: TransitionOperationType {}

/**
 *  A convenience for determining the type of operation, 
 *  as well as more generic properties such as presenting / dismissing
 *  (applicable for both navigation and modal transitions).
 */
public enum TransitionOperation {
    case none
    case navigation(UINavigationControllerOperation)
    case modal(UIViewControllerModalOperation)
    case tabBar(UITabBarControllerOperation)
    
    public init<T>(_ operation: T) where T: TransitionOperationType {
        switch operation {
        case let operation as UINavigationControllerOperation:
            self = .navigation(operation)
        case let operation as UIViewControllerModalOperation:
            self = .modal(operation)
        case let operation as UITabBarControllerOperation:
            self = .tabBar(operation)
        default: self = .none
        }
    }
    
    /// Returns true if the operation presents a new viewController (can be .navigation.push or .modal.present)
    public var isPresenting: Bool {
        switch self {
        case .navigation(let operation): return operation == .push
        case .modal(let operation): return operation == .present
        default: return false
        }
    }
    
    /// Returns true if the operation dismisses an earlier presented viewController (can be .navigation.pop or .modal.dismiss)
    public var isDismissing: Bool {
        switch self {
        case .navigation(let operation): return operation == .pop
        case .modal(let operation): return operation == .dismiss
        default: return false
        }
    }
    
    public var isNone: Bool {
        switch self {
        case .none: return true
        case .navigation(let operation): return operation == .none
        case .modal(let operation): return operation == .none
        case .tabBar(let operation): return operation == .none
        }
    }
    
    var value: TransitionOperationType? {
        switch self {
        case .none: return nil
        case .navigation(let operation): return operation
        case .modal(let operation): return operation
        case .tabBar(let operation): return operation
        }
    }
}

extension TransitionOperation : Equatable {}
public func ==(lhs: TransitionOperation, rhs: TransitionOperation) -> Bool {
    switch (lhs, rhs) {
    case (.none, .none): return true
    case (.navigation(let lhsOp), .navigation(let rhsOp)): return lhsOp == rhsOp
    case (.modal(let lhsOp), .modal(let rhsOp)): return lhsOp == rhsOp
    case (.tabBar(let lhsOp), .tabBar(let rhsOp)): return lhsOp == rhsOp
    default: return false
    }
}
