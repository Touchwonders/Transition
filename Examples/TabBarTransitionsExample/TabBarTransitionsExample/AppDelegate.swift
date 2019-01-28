//
//    MIT License
//
//    Copyright (c) 2017 Touchwonders B.V.
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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var transitionController: TabBarTransitions!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let tabBarController = UITabBarController()
        tabBarController.tabBar.backgroundImage = UIImage(named: "background")
        tabBarController.viewControllers = [
            ViewController(with: .circle),
            ViewController(with: .triangle),
            ViewController(with: .square)
        ]
        
        transitionController = TabBarTransitions(in: tabBarController)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        for item in tabBarController.tabBar.items! {
            item.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        }
        
        return true
    }
}
