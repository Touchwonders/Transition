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


/// This helper struct allows us to identify timingParameters that
/// have an implicit duration (specific spring timing parameters)
public struct AnimationTimingParameters {
    
    /// A UITimingCurveProvider (either UICubicTimingParameters or UISpringTimingParameters)
    /// instantiated using the parameters given on init.
    public let timingCurveProvider: UITimingCurveProvider
    
    /// Returns true if the UITimingCurveProvider has an implicit duration.
    /// This is true for UISpringTimingParameters initialized via the
    /// init(mass:, stiffness:, damping:, initialVelocity:)
    public let hasImplicitDuration: Bool
    
    
    public init(animationCurve curve: UIViewAnimationCurve) {
        timingCurveProvider = UICubicTimingParameters(animationCurve: curve)
        hasImplicitDuration = false
    }
    
    public init(controlPoint1 point1: CGPoint, controlPoint2 point2: CGPoint) {
        timingCurveProvider = UICubicTimingParameters(controlPoint1: point1, controlPoint2: point2)
        hasImplicitDuration = false
    }

    public init(dampingRatio ratio: CGFloat, initialVelocity velocity: CGVector = .zero) {
        timingCurveProvider = UISpringTimingParameters(dampingRatio: ratio, initialVelocity: velocity)
        hasImplicitDuration = false
    }
    
    // This allows you to specify the spring constants for the underlying
    // CASpringAnimation directly. The duration is computed assuming a small settling oscillation.
    public init(mass: CGFloat, stiffness: CGFloat, damping: CGFloat, initialVelocity velocity: CGVector) {
        timingCurveProvider = UISpringTimingParameters(mass: mass, stiffness: stiffness, damping: damping, initialVelocity: velocity)
        hasImplicitDuration = true
    }
}
