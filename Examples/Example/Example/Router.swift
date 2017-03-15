//
//  Router.swift
//  transtest
//
//  Created by Katie Bogdanska on 27/02/17.
//  Copyright © 2017 Robert-Hein Hooijmans. All rights reserved.
//

import UIKit
import Transition

class Router {
    let navigationController: UINavigationController
    var transitionController: TransitionController!
    let source: ExampleSource
    let interactionController: PanInteractionController
    
    init() {
        source = ExampleSource()
        
        navigationController = UINavigationController(rootViewController: ViewController())
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        
        interactionController = PanInteractionController(forNavigationTransitionsAtEdge: .bottom)
        
        transitionController = TransitionController(forInteractiveTransitionsIn: navigationController, transitionsSource: source, operationDelegate: self, interactionController: interactionController)
    }
    
    func pushNextViewController() {
        navigationController.pushViewController(ViewController(), animated: true)
    }
    
    func popViewController() {
        navigationController.popViewController(animated: true)
    }
}

extension Router: InteractiveNavigationTransitionOperationDelegate {
    
    func performOperation(operation: UINavigationControllerOperation, forInteractiveTransitionIn controller: UINavigationController, gestureRecognizer: UIGestureRecognizer) {
        switch operation {
        case .push:
            pushNextViewController()
        case .pop:
            popViewController()
        default: return
        }
    }
}
