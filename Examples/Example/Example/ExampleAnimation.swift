//
//  ExampleAnimation.swift
//  transtest
//
//  Created by Katie Bogdanska on 27/02/17.
//  Copyright © 2017 Robert-Hein Hooijmans. All rights reserved.
//

import Transition

class ExampleAnimation: TransitionAnimation {
    
    weak var topView: UIView?
    var targetTransform: CGAffineTransform = .identity
    var targetAlpha: CGFloat = 1
    var overlay: UIView!
    
    public func setup(in operationContext: TransitionOperationContext) {
        let context = operationContext.context
        let operation = operationContext.operation
        
        topView = context.defaultViewSetup(for: operationContext.operation)
        
        overlay = UIView(frame: context.containerView.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        context.containerView.insertSubview(overlay, belowSubview: topView!)
        
        let hiddenTransform = CGAffineTransform(translationX: 0, y: context.containerView.bounds.height)
        
        if operation.isPresenting {
            topView?.transform = hiddenTransform
            overlay.alpha = 0
        } else {
            targetTransform = hiddenTransform
            targetAlpha = 0
        }
    }
    
    var layers: [AnimationLayer] {
        return [
            AnimationLayer(timingParameters: AnimationTimingParameters(dampingRatio: 0.9), animation: animation)
        ]
    }
    
    func animation() {
        topView?.transform = targetTransform
        overlay.alpha = targetAlpha
    }
    
    func completion(position: UIViewAnimatingPosition) {
        overlay.removeFromSuperview()
    }
}
