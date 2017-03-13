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
import Transition


/**
 *  This is a helper object that manages instantiation of the TransitionController,
 *  as well as providing the required Transition (as TransitionsSource) and performing
 *  any tabBar operation that is resultant of an interactive gesture.
 */
class TabBarTransitions : NSObject {
    
    let tabBarController: UITabBarController
    let interactionController: PanInteractionController
    
    private(set) var transitionController: TransitionController!
    
    
    init(in tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
        /// Transition includes a built-in TransitionInteractionController for basic pan gestures, configurable for navigation, modal and tabBar transitions:
        interactionController = PanInteractionController.forTabBarTransitions(rightToLeft: TabBarTransitions.isRightToLeft)
        super.init()
        /// You can uncomment the following line and comment the one below that to switch between custom transitions and custom INTERACTIVE transitions.
        /// For the latter an interactionController and operationDelegate are required. The interactionController provides the gesture recognizer and logic for the interaction gesture,
        /// the operationDelegate performs any tabBar operation resulting from an interaction gesture.
//        transitionController = TransitionController(forTransitionsIn: tabBarController, transitionsSource: self)
        transitionController = TransitionController(forInteractiveTransitionsIn: tabBarController, transitionsSource: self, operationDelegate: self, interactionController: interactionController)
    }
    
    /// Support for RTL languages; this will flip the tabBar as well.
    fileprivate static var isRightToLeft: Bool {
        return UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
    }
    
}


extension TabBarTransitions : TransitionsSource {
    
    func transitionFor(operationContext: TransitionOperationContext, interactionController: TransitionInteractionController?) -> Transition {
        ///  Create an instance of our custom ShapeTransitionAnimation, which specifies the transition animation between two ViewControllers.
        let shapeTransitionAnimation = ShapeTransitionAnimation(for: operationContext.operation, rightToLeft: TabBarTransitions.isRightToLeft)
        ///  Note that we provide only the "animation" of the transition, not the "interaction".
        ///  The interaction part provides specification for animating and (based on a gesture) manually positioning
        ///  an interactive element, a view that is moved from one ViewController to another during transition.
        return Transition(duration: 0.4, animation: shapeTransitionAnimation)
    }
    
}


extension TabBarTransitions : InteractiveTabBarTransitionOperationDelegate {
    
    func performOperation(operation: UITabBarControllerOperation, forInteractiveTransitionIn controller: UITabBarController, gestureRecognizer: UIGestureRecognizer) {
        /// A gesture (swipe left / right) should result in either an increase or decrease of the selected tab index. Let's make it happen:
        tabBarController.perform(operation: operation)
    }
    
}

