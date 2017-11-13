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


/**
 *  This ViewController provides a dropTarget view (a "hole" in which to drop a ShapeView).
 *  The view initially is only partially presented, but once the ShapeView is dropped,
 *  it will further animate until fully visible, showing the shape counters at the top of
 *  the view. The associated counter for the dropped shape will be incremented.
 */
class DropTargetViewController: UIViewController {
    
    //  The hole in which to drop ShapeViews. This is used to calculate the
    //  initial visible portion of the view.
    @IBOutlet weak var dropTarget: UIView!
    @IBOutlet weak var dragUpLabel: UILabel!
    
    @IBOutlet var counterImageViews: [UIImageView]!
    @IBOutlet var counters: [UILabel]!
    
    
    class func fromStoryboard(_ storyboard: UIStoryboard? = nil) -> DropTargetViewController {
        return (storyboard ?? UIStoryboard(name: "Main", bundle: nil)).instantiateViewController(withIdentifier: "DropTargetViewController") as! DropTargetViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dropTarget.layer.cornerRadius = dropTarget.bounds.midY
        dropTarget.layer.borderColor = UIColor.white.cgColor
        dropTarget.layer.borderWidth = 4.0
        
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 24.0
        view.layer.shadowOffset = CGSize(width: 0.0, height: 12.0)
        
        counterImageViews.forEach { $0.image = Shape(rawValue: $0.tag)!.image }
        updateCounters()
    }
    
    /// Initial presentation of this view will only present the view enough to
    /// exactly position the dropTarget at the requested dropPoint.
    func translationFactorFor(dropPoint: CGPoint) -> CGFloat {
        view.layoutIfNeeded()
        return 1.0 - ((dropPoint.y + (view.bounds.height - dropTarget.center.y)) / view.bounds.height)
    }
    
    
    /// Set all counters (labels) to the approriate count
    fileprivate func updateCounters() {
        counters.forEach { counter in
            if let shape = Shape(rawValue: counter.tag) {
                counter.text = "\(ShapesModel.shared.count(for: shape))"
            }
        }
    }
    
    fileprivate func counterFor(_ shape: Shape) -> UILabel {
        return counters.first(where: { $0.tag == shape.rawValue })!
    }
}

extension DropTargetViewController : TransitionPhaseDelegate {
    
    /// The transition completed (at .end):
    func didTransition(from fromViewController: UIViewController, to toViewController: UIViewController, with sharedElement: SharedElement?) {
        if toViewController == self,
            let transitioningShapeView = sharedElement as? TransitioningShapeView,
            let originalShapeView = transitioningShapeView.originalShapeView,
            let shape = Shape(rawValue: originalShapeView.tag) {
            /// First, increment the associated counter in the ShapesModel, and update the labels accordingly:
            ShapesModel.shared.increment(shape: shape)
            updateCounters()
            
            /// Take the associated counter label and position it at the dropTarget's center.
            let counter = counterFor(shape)
            let translation = dropTarget.center - view.convert(counter.center, from: counter.superview)
            counter.transform = CGAffineTransform(translationX: translation.dx, y: translation.dy)
            counter.alpha = 0.0
            
            UIView.animate(withDuration: 0.2, animations: {
                /// Animate out the shared element - the dragged shapeView ('s transitioningView)
                transitioningShapeView.transitioningView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                transitioningShapeView.transitioningView.alpha = 0.0
                counter.alpha = 1.0
            }, completion: { _ in
                //  clean up
                transitioningShapeView.transitioningView.removeFromSuperview()
                
                UIView.animate(withDuration: 0.3, animations: {
                    /// Animate the DropTargetView to be fully visible, and move the counter label to its original position
                    self.view.transform = .identity
                    counter.transform = .identity
                }, completion: { _ in
                    /// The shapeView itself was never moved. It was however hidden so that dragging its snapshot made
                    /// it look like the shapeView was indeed moved. Now it is occluded by the DropTargetView,
                    /// set it visible again.
                    originalShapeView.alpha = 1.0
                    UIView.animate(withDuration: 0.5, animations: {
                        self.dragUpLabel.alpha = 1.0
                        self.dropTarget.alpha = 0.0
                    })
                })
            })
        }
    }
}
