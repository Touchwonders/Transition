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
 *  The ShapeSourceViewController presents four ShapeViews (plus, minus, divide, multiply).
 *  Each ShapeView can be dragged up and then dropped in the appearing DropTargetView(Controller).
 */
class ShapeSourceViewController: UIViewController {

    @IBOutlet var shapeViews: [ShapeView]!
    
    private(set) var transitionController: TransitionController!
    private(set) var interactionController: ShapeInteractionController!
    
    /// We keep a reference to the instantiated dropTargetViewController so that we can ask
    /// for its translationFactor (the fraction of its height it should be translated in order
    /// to position its dropTarget at the dropPoint).
    fileprivate weak var dropTargetViewController: DropTargetViewController?
    
    /// The dropPoint is the point in the view at which the dropTarget should center.
    fileprivate var dropPoint: CGPoint {
        return CGPoint(x: view.bounds.midX, y: view.bounds.height * 0.55)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shapeViews.forEach {
//            $0.backgroundColor = color($0.tag)
            $0.isUserInteractionEnabled = false
            $0.image = Shape(rawValue: $0.tag)!.selectedImage
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        /// Only when our view has a .window, it can be used as operationController in a TransitionController.
        /// The window will be used to install the gestureRecognizer, such that after modal presentation it
        /// can still be used to detect gestures that should lead to dismissing.
        if interactionController == nil {
            self.interactionController = ShapeInteractionController(forViewController: self, shapeViews: shapeViews, dropPoint: dropPoint)
            self.transitionController = TransitionController(forInteractiveModalPresentationsFrom: self, transitionsSource: self, interactionController: interactionController)
        }
        hintShapeViews()
    }
    
    fileprivate func hintShapeViews() {
        shapeViews.forEach {
            let hintAnimation = CABasicAnimation(keyPath: "transform.scale")
            hintAnimation.fromValue = 1.0
            hintAnimation.toValue =  1.1
            hintAnimation.autoreverses = true
            hintAnimation.duration = 0.15
            hintAnimation.beginTime = CACurrentMediaTime() + (CFTimeInterval($0.tag) * 0.05)
            $0.layer.add(hintAnimation, forKey: nil)
        }
    }
}


extension ShapeSourceViewController : TransitionsSource {
    
    /// Provide the Transition for presentation / dismissal
    func transitionFor(operationContext: TransitionOperationContext, interactionController: TransitionInteractionController?) -> Transition {
        
        /// The dropTargetViewAnimation should move the dropTargetView exactly to the point at which the dropTarget
        /// centers at the requested dropPoint. It uses a closure to request the translation factor when needed,
        /// so that the dropTargetViewController is loaded and is given its correct dimensions to derive the translation factor.
        let dropTargetViewAnimation = DropTargetViewAnimation(for: operationContext.operation, translationFactor: { [weak self] in
            guard let strongSelf = self else { return 0.0 }
            return strongSelf.dropTargetViewController?.translationFactorFor(dropPoint: strongSelf.dropPoint) ?? 0.0
        })
        
        guard let interactionController = interactionController else {
            /// The sharedElement part of the transition describes how the shared element should move and animate.
            /// Not providing it is optional, but not possible for this particular example because the transition can
            /// only be initiated by interacting with a ShapeView.
            fatalError("This transition cannot be performed without a shared element")
        }
        let shapeInteractionAnimation = ShapeInteractionAnimation(interactionController: interactionController)
        return Transition(duration: 0.3, animation: dropTargetViewAnimation, sharedElement: shapeInteractionAnimation)
    }
    
}


extension ShapeSourceViewController : InteractiveModalTransitionOperationDelegate {
    
    /// The `OperationDelegate` for modal transitions is always the `operationController` (in modal transition speak: the `sourceViewController`, the viewController that initiates the transition).
    /// It should provide the viewController that should be presented (the `presentedViewController`). The `TransitionController` will eventually call `present(_:animated:completion:)`
    /// on the `operationController`, but not before correctly configuring the `presentedViewController` (setting the transitioningDelegate and modalPresentationStyle).
    func viewControllerForInteractiveModalPresentation(by sourceViewController: UIViewController, gestureRecognizer: UIGestureRecognizer) -> UIViewController {
        let dropTargetViewController = DropTargetViewController.fromStoryboard(self.storyboard)
        self.dropTargetViewController = dropTargetViewController
        return dropTargetViewController
    }
}



extension ShapeSourceViewController : TransitionPhaseDelegate {
    
    func didTransition(from fromViewController: UIViewController, to toViewController: UIViewController, with sharedElement: SharedElement?) {
        if toViewController == self {
            hintShapeViews()
        }
    }
}
