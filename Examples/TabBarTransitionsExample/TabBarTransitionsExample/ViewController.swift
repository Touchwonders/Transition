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

class ViewController: UIViewController {
    
    class func fromStoryboard(withShape shape: Shape) -> ViewController {
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        newViewController.shape = shape
        newViewController.tabBarItem = UITabBarItem(title: nil, image: shape.image(size: CGSize(width: 22.0, height: 22.0)), tag: shape.rawValue)
        newViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 5.0, left: 0.0, bottom: -5.0, right: 0.0)
        return newViewController
    }
    
    var shape: Shape = .plus {
        didSet {
            tabView.shape = shape
        }
    }
    
    var tabView: TabView {
        return self.view as! TabView
    }
    
    @IBOutlet weak var logoMask: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewColor = color(shape.rawValue)
        
        self.view.backgroundColor = viewColor
        
        logoMask.image = logoMask.image?.withRenderingMode(.alwaysTemplate)
        logoMask.tintColor = viewColor
    }
}

class TabView: UIView {
    var shape: Shape = .plus
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.saveGState()
        
        let idealSize: CGFloat = 14.0
        let effectiveSize = rect.width / floor(rect.width / idealSize)
        let drawSize = CGSize(width: effectiveSize, height: effectiveSize)
        
        let path = shapePath(shape, size: CGSize(width: floor(drawSize.width), height: floor(drawSize.height)), inset: 3.0)
        
        var currentCtmTranslation = CGVector(dx: 0.0, dy: 0.0)
        var offset = CGVector(dx: 0.0, dy: 0.0)
        
        while offset.dy < rect.height {
            while offset.dx < rect.width {
                let drawOffset = CGVector(dx: ceil(offset.dx), dy: ceil(offset.dy))
                let translation = CGVector(dx: drawOffset.dx - currentCtmTranslation.dx, dy: drawOffset.dy - currentCtmTranslation.dy)
                ctx.translateBy(x: translation.dx, y: translation.dy)
                currentCtmTranslation = drawOffset
                ctx.addPath(path)
                offset.dx += drawSize.width
            }
            offset.dx = 0.0
            offset.dy += drawSize.height
        }
        
        ctx.setStrokeColor(UIColor(white: 0.0, alpha: 0.075).cgColor)
        ctx.setLineWidth(2.0)
        ctx.setLineCap(.round)
        
        ctx.drawPath(using: .stroke)
        
        ctx.restoreGState()
    }
}
