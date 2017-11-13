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
import Transition

class ZoomTransitionItem: NSObject, SharedElement {
    var initialFrame: CGRect
    var targetFrame: CGRect
    
    /// SharedElement:
    var transitioningView: UIView
    
    var image: UIImage? {
        get {
            return imageView?.image
        } set {
            imageView?.image = newValue
        }
    }
    
    weak var imageView: UIImageView?
    
    var touchOffset: CGVector = .zero
    
    init(initialFrame: CGRect, targetFrame: CGRect, imageView: UIImageView) {
        self.initialFrame = initialFrame
        self.targetFrame = targetFrame
        self.imageView = imageView
        
        self.transitioningView = imageView.snapshot()
        super.init()
    }
}
