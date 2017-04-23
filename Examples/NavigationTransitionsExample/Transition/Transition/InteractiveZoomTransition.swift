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

class InteractiveZoomTransition : SharedElementTransition {
    
    private struct State {
        let snapShotFrame: CGRect
        let toViewTransform: CGAffineTransform
        let fromViewTransform: CGAffineTransform
    }
    
    private weak var interactionController: TransitionInteractionController?
    private var operationContext: TransitionOperationContext!
    private var context: UIViewControllerContextTransitioning!
    
    init(interactionController: TransitionInteractionController) {
        self.interactionController = interactionController
    }
    
    var timingParameters: AnimationTimingParameters {
        return AnimationTimingParameters(mass: 0.1, stiffness: 15, damping: 2.0, initialVelocity: CGVector(dx: 0, dy: 0))
    }
    
    var snapshot: UIImageView?
    var selectedImage: UIImageView?
    private var initialState: State!
    private var targetState: State!
    
    func setup(in operationContext: TransitionOperationContext) {
        self.operationContext = operationContext
        self.context = operationContext.context
        
        guard let item = sharedElement as? ZoomTransitionItem else { return }
        guard let itemImageView = ((isPresenting ? context.toViewController : context.fromViewController) as! CollectionViewController).header?.image else { return }
        
        var frame = item.initialFrame
        frame.origin.x += 10
        frame.origin.y += 10
        
        snapshot = itemImageView.snapshot()
        
        if isPresenting, let fromViewController = context.fromViewController as? CollectionViewController, let selectedImage = fromViewController.selectedImage {
            self.selectedImage = selectedImage
        } else if !isPresenting, let toViewController = context.toViewController as? CollectionViewController, let selectedImage = toViewController.selectedImage {
            self.selectedImage = selectedImage
        }
        self.selectedImage?.isHidden = true
        
        if let snapshot = snapshot {
            snapshot.frame = frame
            context.containerView.addSubview(snapshot)
            item.imageView?.isHidden = true
        }
        
        let scale = item.targetFrame.width / item.initialFrame.width
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
        
        let origin = CGVector(dx: item.initialFrame.origin.x - context.fromView.bounds.midX, dy: item.initialFrame.origin.y - context.fromView.bounds.midY)
        let scaled = CGVector(dx: origin.dx * scale, dy: origin.dy * scale)
        let delta = CGVector(dx: origin.dx - scaled.dx, dy: origin.dy - scaled.dy)
        
        let translation = CGPoint(x: item.targetFrame.origin.x - item.initialFrame.origin.x, y: item.targetFrame.origin.y - item.initialFrame.origin.y)
        let translationTransform = CGAffineTransform(translationX: translation.x + delta.dx, y: translation.y + delta.dy)
        
        let fromViewTransform = scaleTransform.concatenating(translationTransform)
        let toViewTransform = CGAffineTransform(a: 1 / fromViewTransform.a, b: 0, c: 0, d: 1 / fromViewTransform.d, tx: -fromViewTransform.tx, ty: -fromViewTransform.ty)   //  the inverse of fromViewTransform
        
        if context.toView.transform.isIdentity {
            context.toView.transform = toViewTransform
        }
        
        initialState = State(snapShotFrame: frame, toViewTransform: toViewTransform, fromViewTransform: .identity)
        targetState = State(snapShotFrame: item.targetFrame, toViewTransform: .identity, fromViewTransform: fromViewTransform)
    }
    
    private func applyState(_ state: State) {
        snapshot?.frame = state.snapShotFrame
        context.toView.transform = state.toViewTransform
        context.fromView.transform = state.fromViewTransform
    }
    
    var isPresenting: Bool {
        return operationContext.operation.isPresenting
    }
    
    func animation() {
        if animatingPosition == .end {
            applyState(targetState)
        } else {
            applyState(initialState)
        }
    }
    
    func completion(position: UIViewAnimatingPosition) {
        guard let item = sharedElement as? ZoomTransitionItem else { return }
        context.fromView.transform = .identity
        context.toView.transform = .identity
        snapshot?.removeFromSuperview()
        item.imageView?.isHidden = false
        selectedImage?.isHidden = false
    }
    
    var animatingPosition: UIViewAnimatingPosition = .end
    var sharedElement: SharedElement? = nil
    
    func startInteraction(in context: UIViewControllerContextTransitioning, gestureRecognizer: UIGestureRecognizer) {
        let locationInContainer = gestureRecognizer.location(in: context.containerView)
        if let view = context.containerView.hitTest(locationInContainer, with: nil), view == sharedElement?.transitioningView {
            guard let item = sharedElement as? ZoomTransitionItem else { return }
            guard let snapshot = snapshot else { return }
            item.touchOffset = CGVector(dx: locationInContainer.x - snapshot.center.x, dy: locationInContainer.y - snapshot.center.y)
        }
    }
    
    public func updateInteraction(in context: UIViewControllerContextTransitioning, interactionController: TransitionInteractionController, progress: TransitionProgress) {
        guard let gesture = interactionController.gestureRecognizer as? UIPanGestureRecognizer else { return }
        guard let item = sharedElement as? ZoomTransitionItem else { return }
        
        let translationInView = gesture.translation(in: gesture.view)
        
        context.fromView.transform = CGAffineTransform(translationX: 0.0, y: max(0.0, translationInView.y))
        
        switch progress {
        case .fractionComplete(let fraction):
            let scale = item.initialFrame.width / item.targetFrame.width
            
            let origin = CGVector(dx: item.targetFrame.origin.x - context.toView.bounds.midX, dy: item.targetFrame.origin.y - context.toView.bounds.midY)
            let scaled = CGVector(dx: origin.dx * scale, dy: origin.dy * scale)
            let delta = CGVector(dx: origin.dx - scaled.dx, dy: origin.dy - scaled.dy)
            
            let translation = CGPoint(x: item.initialFrame.origin.x - item.targetFrame.origin.x, y: item.initialFrame.origin.y - item.targetFrame.origin.y)
            let translationTransform = CGAffineTransform(translationX: translation.x + delta.dx, y: translation.y + delta.dy)
            
            var transform = context.toView.transform
            transform.a = scale - (CGFloat(fraction) * (scale - 1))
            transform.d = scale - (CGFloat(fraction) * (scale - 1))
            transform.tx = translationTransform.tx - (CGFloat(fraction) * translationTransform.tx)
            transform.ty = translationTransform.ty - (CGFloat(fraction) * translationTransform.ty)
            context.toView.transform = transform
            
            guard let snapshot = snapshot else { return }
            var snapshotFrame = snapshot.frame
            snapshotFrame.size.width = item.initialFrame.width - (CGFloat(fraction) * (item.initialFrame.width - item.targetFrame.width))
            snapshotFrame.size.height = item.initialFrame.height - (CGFloat(fraction) * (item.initialFrame.height - item.targetFrame.height))
            snapshot.frame = snapshotFrame
            snapshot.center = CGPoint(x: (item.initialFrame.midX + 10) + translationInView.x, y: (item.initialFrame.midY + 10) + translationInView.y)
        default: return
        }
    }
}
