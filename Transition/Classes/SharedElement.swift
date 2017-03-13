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
 *  A container that represents an element that is shared between the from- and toView in the transition.
 *  It exposes a transitioningView, but can contain any additional information for computing that view's movement between the two views.
 */
public protocol SharedElement {
    
    /// The view that will be used during the interactive transition (most likely a temporary view such as a snapshot).
    var transitioningView : UIView { get }
}

/**
 *  The TransitionInteractionController has a property `.sharedElementProvider` which you can set.
 */
public protocol SharedElementProvider : class {
    
    /// Return the element that should be animated / interacted with between the two transitioning views.
    /// This can either represent the view which selection triggered the transition,
    /// or if the transition was triggered by an interaction gesture, the logical view for that gesture
    /// (derivable using the gesture recognizer that is accessible from the provided interactionController).
    func sharedElementForInteractiveTransition(with interactionController: TransitionInteractionController, in operationContext: TransitionOperationContext) -> SharedElement?
}
