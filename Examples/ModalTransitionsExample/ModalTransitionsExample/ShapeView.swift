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
import Transition


class ShapeView : UIImageView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        self.contentMode = .center
        self.layer.cornerRadius = bounds.midX
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor(white: 0.0, alpha: 0.15).cgColor
        self.layer.shouldRasterize = true
    }
    
    var transitioningShapeView: TransitioningShapeView {
        return TransitioningShapeView(for: self)
    }
}


/// The TransitioningShapeView serves as a transitioning context
/// specific for a single ShapeView. It provides the transitioningView,
/// which is a snapshot of the original ShapeView.
/// The object also contains a number of geometric properties used for
/// computing the correct movement and progression of the transition.
class TransitioningShapeView : NSObject, SharedElement {
    
    private(set) weak var originalShapeView: ShapeView?
    let transitioningView: UIView
    
    var touchOffset: CGVector = .zero
    var initialFrame: CGRect = .zero
    var targetFrame: CGRect = .zero
    
    init(for shapeView: ShapeView) {
        originalShapeView = shapeView
        transitioningView = shapeView.snapshotView(afterScreenUpdates: true)!
    }
}
