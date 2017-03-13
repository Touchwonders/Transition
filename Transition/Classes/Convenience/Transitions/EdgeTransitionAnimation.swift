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


/// This is the base class for several built-in TransitionAnimations.
/// On itself it does nothing.
open class EdgeTransitionAnimation : TransitionAnimation {
    
    public convenience init(forNavigationTransitionsAtEdge edge: TransitionScreenEdge) {
        self.init(transitionEdges: TransitionEdges(forNavigationTransitionsAtEdge: edge))
    }
    
    public convenience init(forModalTransitionsAtEdge edge: TransitionScreenEdge) {
        self.init(transitionEdges: TransitionEdges(forModalTransitionsAtEdge: edge))
    }
    
    public static func forTabBarTransitions(rightToLeft: Bool = false) -> EdgeTransitionAnimation {
        return EdgeTransitionAnimation(transitionEdges: TransitionEdges.forTabBarTransitions(rightToLeft: rightToLeft))
    }
    
    
    public init(transitionEdges: TransitionEdges) {
        self.transitionEdges = transitionEdges
    }
    
    open let transitionEdges: TransitionEdges
    
    
    open func setup(in operationContext: TransitionOperationContext) {
        /// This should be implemented by a subclass
    }
    
    
    open var layers: [AnimationLayer] {
        return []
    }
    
    open func completion(position: UIViewAnimatingPosition) {
        /// This should be implemented by a subclass
    }
    
    open var animationCurve: UIViewAnimationCurve = .easeInOut
    
    /// Convenience functions
    
    open func transitionScreenEdgeFor(operation: TransitionOperation) -> TransitionScreenEdge? {
        /// The transitionEdges represent the edges towards which is animated.
        /// The opposite edge is the edge from which is animated.
        return transitionEdges.screenEdgeFor(operation: operation)?.opposite
    }
    
    open func transformForTranslatingViewTo(edge: TransitionScreenEdge, outside frame: CGRect) -> CGAffineTransform {
        switch edge {
        case .top:      return CGAffineTransform(translationX: 0.0, y: -frame.height)
        case .right:    return CGAffineTransform(translationX: frame.width, y: 0.0)
        case .bottom:   return CGAffineTransform(translationX: 0.0, y: frame.height)
        case .left:     return CGAffineTransform(translationX: -frame.width, y: 0.0)
        }
    }
}
