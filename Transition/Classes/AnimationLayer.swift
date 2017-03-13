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


/**
 *  The AnimationLayer is a set of specifications for an animation.
 *  The developer will be prompt to give a collection of these animation layers that combined will be the total transition.
 */
public struct AnimationLayer {
    let range: AnimationRange
    let timingParameters: AnimationTimingParameters
    let animation: AnimationFunction
    
    public init(range: AnimationRange = .full, timingParameters: AnimationTimingParameters, animation: @escaping AnimationFunction) {
        self.range = range
        self.timingParameters = timingParameters
        self.animation = animation
    }
}


/**
 *  The AnimationLayerAnimator is an internal helper object that associates an AnimationLayer (the specification of an animation)
 *  with a UIViewPropertyAnimator (the implementation of that animation).
 */
internal class AnimationLayerAnimator {
    
    internal let layer: AnimationLayer
    internal var animator: UIViewPropertyAnimator!
    
    /// If the layer's timingParameters have an implicit duration, the .end of the range can only
    /// be computed as fraction once we have the effective total animation duration.
    internal var effectiveRange: AnimationRange
    
    /// This will be set to the value passed in the animator's completion.
    internal var completionPosition: UIViewAnimatingPosition = .end
    
    internal init(layer: AnimationLayer, animator: UIViewPropertyAnimator) {
        self.layer = layer
        self.animator = animator
        effectiveRange = layer.range
    }
}
