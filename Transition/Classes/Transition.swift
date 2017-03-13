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


public struct Transition {
    
    /// The overall duration of the transition.
    /// Note that this might be overridden by UISpringTimingParameters
    /// as timingParameters of either `animation` or `sharedElement`.
    public let duration: TimeInterval
    
    /// This specifies the animation between the from and to view.
    public let animation: TransitionAnimation
    
    /// This specifies the animation and/or interactive updating of a shared element between the from and to view.
    /// Not required, therefore optional.
    public let sharedElement: SharedElementTransition?
    
    
    public init(duration: TimeInterval, animation: TransitionAnimation, sharedElement: SharedElementTransition? = nil) {
        self.duration = duration
        self.animation = animation
        self.sharedElement = sharedElement
    }
}


public extension Transition {
    
    /// The effective duration is the duration, influenced by the presence of any timingParameter (in animation or interaction)
    /// that has an implicit duration due to a spring timing curve configuration.
    public var effectiveDuration: TimeInterval {
        /// First check if there's any animationLayer that has an implicit duration (due to spring timing parameters) that
        /// would effectively stretch up the total duration (i.e. lasting beyond transition.duration).
        let animationLayersDuration = animation.layers.reduce(duration) { (currentDuration, animationLayer) -> TimeInterval in
            if animationLayer.timingParameters.hasImplicitDuration {
                /// A UIViewPropertyAnimator can be used to resolve the mass-spring duration
                let effectiveLayerDuration = UIViewPropertyAnimator(duration: duration, timingParameters: animationLayer.timingParameters.timingCurveProvider).duration
                let effectiveLayerEndTime = (animationLayer.range.start * duration) + effectiveLayerDuration
                return max(currentDuration, effectiveLayerEndTime)
            }
            return currentDuration
        }
        
        /// Then, if there's a sharedElement layer, if that has an implicit duration, it'll be the definitive duration.
        /// Note that if this is shorter than animationLayersDuration, some animationLayers might finish after the sharedElement.
        /// Having implicit timing in both animationLayer and sharedElement makes it impossible to have them finish simultaneously.
        if let sharedElement = sharedElement, sharedElement.timingParameters.hasImplicitDuration {
            return UIViewPropertyAnimator(duration: animationLayersDuration, timingParameters: sharedElement.timingParameters.timingCurveProvider).duration
        }
        
        return animationLayersDuration
    }
}
