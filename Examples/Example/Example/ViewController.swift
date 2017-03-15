//
//  ViewController.swift
//  transtest
//
//  Created by Katie Bogdanska on 27/02/17.
//  Copyright © 2017 Robert-Hein Hooijmans. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Example"
        view.backgroundColor = .white
        
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("+", for: .normal)
        button.addTarget(self, action: #selector(pressed(_:)), for: .touchUpInside)
        button.backgroundColor = .blue
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 50)
            ])
    }
    
    func pressed(_ sender: Any) {
        app?.router.pushNextViewController()
    }
}
