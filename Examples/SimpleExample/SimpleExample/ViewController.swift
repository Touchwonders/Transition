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


/**
 *  A simple viewController doing magic things
 */
class ViewController: UIViewController {
    
    var magicIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = color(magicIndex)
        title = "Awesomeness".magic(magicIndex)
    }
    
    @IBAction func toNext() {
        guard let newViewController = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController else { return }
        newViewController.magicIndex = magicIndex + 1
        navigationController?.pushViewController(newViewController, animated: true)
    }
    
}

// • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • • //

func color(_ index: Int) -> UIColor {
    let colors = [UIColor(hue:0.588, saturation:0.804, brightness:0.341, alpha:1),
                  UIColor(hue:0.589, saturation:0.809, brightness:0.843, alpha:1),
                  UIColor(hue:0.588, saturation:0.807, brightness:0.592, alpha:1),
                  UIColor(hue:0.588, saturation:0.809, brightness:0.741, alpha:1)]
    return colors[index % colors.count]
}

extension String {
    func magic(_ magicIndex: Int) -> String {
        if magicIndex < characters.count {
            let i = index(startIndex, offsetBy: magicIndex)
            return substring(to: i)
        } else {
            return padding(toLength: magicIndex, withPad: "!", startingAt: 0)
        }
    }
}
