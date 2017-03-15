//
//  ViewController.swift
//  transtest
//
//  Created by Robert-Hein Hooijmans on 27/02/17.
//  Copyright © 2017 Robert-Hein Hooijmans. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Transition"
        view.backgroundColor = .white
        
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Push VC >", for: .normal)
        button.addTarget(self, action: #selector(pressed(_:)), for: .touchUpInside)
        button.backgroundColor = UIColor(red: 82/255, green: 77/255, blue: 153/255, alpha: 1)
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let backItem = UIBarButtonItem()
        backItem.title = "Pop VC"
        navigationItem.backBarButtonItem = backItem
    }
}
