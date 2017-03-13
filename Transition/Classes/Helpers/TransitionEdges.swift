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


public enum TransitionScreenEdge {
    case top, right, bottom, left
    
    public init(vector: CGVector) {
        self = abs(vector.dx) > abs(vector.dy) ? (vector.dx > 0 ? .right : .left) : (vector.dy > 0 ? .bottom : .top)
    }
    
    public enum Axis {
        case horizontal, vertical
    }
    
    public var axis: Axis {
        switch self {
        case .top, .bottom: return .vertical
        case .right, .left: return .horizontal
        }
    }
    
    public var opposite: TransitionScreenEdge {
        switch self {
        case .top: return .bottom
        case .right: return .left
        case .bottom: return .top
        case .left: return .right
        }
    }
}


public struct TransitionEdges {
    
    public init(forNavigationTransitionsAtEdge edge: TransitionScreenEdge) {
        switch edge {
        case .top:    self.init(topOperation: .navigation(.pop), rightOperation: .navigation(.none), bottomOperation: .navigation(.push), leftOperation: .navigation(.none))
        case .right:  self.init(topOperation: .navigation(.none), rightOperation: .navigation(.pop), bottomOperation: .navigation(.none), leftOperation: .navigation(.push))
        case .bottom: self.init(topOperation: .navigation(.push), rightOperation: .navigation(.none), bottomOperation: .navigation(.pop), leftOperation: .navigation(.none))
        case .left:   self.init(topOperation: .navigation(.none), rightOperation: .navigation(.push), bottomOperation: .navigation(.none), leftOperation: .navigation(.pop))
        }
    }
    
    public init(forModalTransitionsAtEdge edge: TransitionScreenEdge) {
        switch edge {
        case .top:    self.init(topOperation: .modal(.dismiss), rightOperation: .modal(.none), bottomOperation: .modal(.present), leftOperation: .modal(.none))
        case .right:  self.init(topOperation: .modal(.none), rightOperation: .modal(.dismiss), bottomOperation: .modal(.none), leftOperation: .modal(.present))
        case .bottom: self.init(topOperation: .modal(.present), rightOperation: .modal(.none), bottomOperation: .modal(.dismiss), leftOperation: .modal(.none))
        case .left:   self.init(topOperation: .modal(.none), rightOperation: .modal(.present), bottomOperation: .modal(.none), leftOperation: .modal(.dismiss))
        }
    }
    
    public static func forTabBarTransitions(rightToLeft: Bool = false) -> TransitionEdges {
        return TransitionEdges(topOperation: .tabBar(.none),
                               rightOperation: .tabBar(rightToLeft ? .increaseIndex : .decreaseIndex),
                               bottomOperation: .tabBar(.none),
                               leftOperation: .tabBar(rightToLeft ? .decreaseIndex : .increaseIndex))
    }
    
    //	The default initializer is not publicly available, because the framework cannot properly handle different types of transitions (yet).
    //  You either set everything up for navigation, for modal or for tabBar.
    internal init(topOperation: TransitionOperation = .none,
                  rightOperation: TransitionOperation = .none,
                  bottomOperation: TransitionOperation = .none,
                  leftOperation: TransitionOperation = .none) {
        self.topOperation = topOperation
        self.rightOperation = rightOperation
        self.bottomOperation = bottomOperation
        self.leftOperation = leftOperation
        
        assert(allOperationsAreUnique, "TransitionEdges cannot have the same TransitionOperation assigned to multiple screen edges.")
    }
    
    
    //	The effective operations coupled to pan directions:
    public var topOperation: TransitionOperation
    public var rightOperation: TransitionOperation
    public var bottomOperation: TransitionOperation
    public var leftOperation: TransitionOperation
    
    public func operationFor(screenEdge: TransitionScreenEdge) -> TransitionOperation {
        switch screenEdge {
        case .top:      return topOperation
        case .right:    return rightOperation
        case .bottom:   return bottomOperation
        case .left:     return leftOperation
        }
    }
    
    public func screenEdgeFor(operation: TransitionOperation) -> TransitionScreenEdge? {
        return allScreenEdgeOperations.filter { $0.0 == operation }.map { $0.1 }.first
    }
    
    
    fileprivate typealias TransitionScreenEdgeOperation = (TransitionOperation, TransitionScreenEdge)
    fileprivate var allScreenEdgeOperations: [TransitionScreenEdgeOperation] {
        return [(topOperation, .top), (rightOperation, .right), (bottomOperation, .bottom), (leftOperation, .left)]
    }
    
    fileprivate var allOperationsAreUnique: Bool {
        let nonNoneOperations = allScreenEdgeOperations.filter { $0.0.isNone == false }.map { $0.0 }
        var uniqueOperations = [TransitionOperation]()
        for operation in nonNoneOperations {
            if uniqueOperations.contains(operation) {
                return false
            }
            uniqueOperations.append(operation)
        }
        return true
    }
}
