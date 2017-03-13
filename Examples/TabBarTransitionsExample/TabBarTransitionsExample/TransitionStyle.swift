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

// MARK: Shapes

enum Shape: Int {
    case plus, minus, divide, multiply
    
    static var all: [Shape] {
        return [.plus, .minus, .divide, .multiply]
    }
    
    func image(size: CGSize) -> UIImage {
        return shapeImage(self, size: size)!
    }
}

func shapeImage(_ shape: Shape, size: CGSize) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    if let ctx = UIGraphicsGetCurrentContext() {
        
        ctx.saveGState()
        
        let lineWidth: CGFloat = 4.0
        var inset = lineWidth / 2.0
        
        if shape == .divide || shape == .multiply {
            inset = (sqrt(size.width * size.width + size.height * size.height) - size.width) / 2.0
        }
        
        ctx.addPath(shapePath(shape, size: size, inset: inset))
        ctx.setLineWidth(lineWidth)
        ctx.setLineCap(.round)
        ctx.drawPath(using: .stroke)
        
        ctx.restoreGState()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.withRenderingMode(.alwaysTemplate)
    }
    return nil
}

func shapePath(_ shape: Shape, size: CGSize, inset: CGFloat) -> CGPath {
    let path = CGMutablePath()
    let r = CGRect(origin: .zero, size: size).insetBy(dx: inset, dy: inset)
    switch shape {
    case .plus:
        path.move(to: CGPoint(x: r.minX, y: r.midY))
        path.addLine(to: CGPoint(x: r.maxX, y: r.midY))
        path.move(to: CGPoint(x: r.midX, y: r.minY))
        path.addLine(to: CGPoint(x: r.midX, y: r.maxY))
    case .minus:
        path.move(to: CGPoint(x: r.minX, y: r.midY))
        path.addLine(to: CGPoint(x: r.maxX, y: r.midY))
    case .divide:
        path.move(to: CGPoint(x: r.minX, y: r.maxY))
        path.addLine(to: CGPoint(x: r.maxX, y: r.minY))
    case .multiply:
        path.move(to: CGPoint(x: r.minY, y: r.maxY))
        path.addLine(to: CGPoint(x: r.maxX, y: r.minY))
        path.move(to: CGPoint(x: r.minX, y: r.minY))
        path.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
    }
    return path.copy()!
}

// MARK: Colors

func grayscale(_ index: Int) -> UIColor {
    let tints = [UIColor(hue:0, saturation:0, brightness:0.203, alpha:1),
                 UIColor(hue:0, saturation:0, brightness:0.254, alpha:1),
                 UIColor(hue:0, saturation:0, brightness:0.501, alpha:1),
                 UIColor(hue:0, saturation:0, brightness:0.752, alpha:1)]
    return tints[index % tints.count]
}

func color(_ index: Int) -> UIColor {
    let colors = [UIColor(hue:0.589, saturation:0.809, brightness:0.843, alpha:1),
                  UIColor(hue:0.588, saturation:0.804, brightness:0.341, alpha:1),
                  UIColor(hue:0.588, saturation:0.807, brightness:0.592, alpha:1),
                  UIColor(hue:0.588, saturation:0.809, brightness:0.741, alpha:1)]
    return colors[index % colors.count]
}
