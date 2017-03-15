//
//  Router.swift
//  transtest
//
//  Created by Robert-Hein Hooijmans on 27/02/17.
//  Copyright © 2017 Robert-Hein Hooijmans. All rights reserved.
//

import UIKit

class Router {
    let navigationController: UINavigationController
    
    init() {
        navigationController = UINavigationController(rootViewController: ViewController())
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func pushNextViewController() {
        navigationController.pushViewController(ViewController(), animated: true)
    }
    
    func popViewController() {
        navigationController.popViewController(animated: true)
    }
}
