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
        navigationController.navigationBar.tintColor = UIColor(red: 82/255, green: 77/255, blue: 153/255, alpha: 1)
    }
    
    func pushNextViewController() {
        navigationController.pushViewController(ViewController(), animated: true)
    }
    
    func popViewController() {
        navigationController.popViewController(animated: true)
    }
}
