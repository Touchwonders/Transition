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


public protocol SharedElementTransitionSpecification : class {
    
    /// The sharedElement is a representation of content available in both the from- and toView of the transition.
    /// This needs to be present during animation / update, but might not be available at initialization.
    var sharedElement: SharedElement? { get set }
}

/**
 *  A specification of the animation of a shared element between the transitioning views.
 */
public protocol SharedElementAnimation : SharedElementTransitionSpecification {
    
    var timingParameters: AnimationTimingParameters { get }
    
    /// Steps required to set up the animation in the given context.
    func setup(in operationContext: TransitionOperationContext)
    
    /// The animation function that will be given to a UIViewPropertyAnimator
    func animation()
    
    /// The completion function that will be called once the transition completes
    func completion(position: UIViewAnimatingPosition)
    
    /// The animation() of this specification is called after each interaction.
    /// Inbetween, the position towards which is animated, might have changed.
    /// It'll be set accordingly so that it is available for use in animation().
    var animatingPosition: UIViewAnimatingPosition { get set }
}

/**
 *  A specification of the interaction with a shared element between the transitioning views.
 */
public protocol SharedElementInteraction : SharedElementTransitionSpecification {
    
    /// Manually configure the shared element for interaction.
    /// The interaction can be started by a different gesture recognizer than that of the interactionController,
    /// namely the longPressGestureRecognizer that recognizes interruption of animation. Either that or the
    /// interactionController's gestureRecognizer is passed here.
    /// Note that once interaction is started, updateInteraction() will always be following the gestureRecognizer of the interactionController.
    func startInteraction(in context: UIViewControllerContextTransitioning, gestureRecognizer: UIGestureRecognizer)
    
    /// Manually update a single step during interactive transition.
    func updateInteraction(in context: UIViewControllerContextTransitioning, interactionController: TransitionInteractionController, progress: TransitionProgress)
}


public typealias SharedElementTransition = SharedElementAnimation & SharedElementInteraction
