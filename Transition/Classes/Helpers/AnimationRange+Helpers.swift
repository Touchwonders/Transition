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


import Foundation

public enum AnimationRangePosition {
    case contains, isBefore, isAfter
}

public extension AnimationRangePosition {
    public var reversed: AnimationRangePosition {
        switch self {
        case .contains: return .contains
        case .isBefore: return .isAfter
        case .isAfter: return .isBefore
        }
    }
    public func reversed(_ shouldReverse: Bool) -> AnimationRangePosition {
        return shouldReverse ? reversed : self
    }
}


public extension AnimationRange {
    
    public var length: AnimationFraction {
        return end - start
    }
    
    /// Returns true if the range contains the fraction
    public func contains(_ fraction: AnimationFraction) -> Bool {
        return position(fraction) == .contains
    }
    /// Returns true if the range is positioned before the fraction
    public func isBefore(_ fraction: AnimationFraction) -> Bool {
        return position(fraction) == .isBefore
    }
    /// Returns true if the range is positioned after the fraction
    public func isAfter(_ fraction: AnimationFraction) -> Bool {
        return position(fraction) == .isAfter
    }
    
    /// Returns the position of the range relative to the given fraction
    public func position(_ fraction: AnimationFraction) -> AnimationRangePosition {
        
        if end < fraction {
            return .isBefore
        }
        if start > fraction {
            return .isAfter
        }
        return .contains
    }
    
    /// Returns the distance (either measured from end or start, if the range is before or after respectively) relative to the fraction.
    /// Returns 0 if the range contains the fraction
    public func distance(to fraction: AnimationFraction) -> AnimationFraction {
        switch position(fraction) {
        case .isBefore: return fraction - end
        case .isAfter: return start - fraction
        case .contains: return 0.0
        }
    }
    
    /// Returns the fractionComplete for start -> end = 0 -> 1.
    /// If the position is before `fraction`, it'll return 1.
    /// If the position is after `fraction`, it'll return 0.
    /// Otherwise it maps fraction to the range.
    public func relativeFractionComplete(to fraction: AnimationFraction) -> AnimationFraction {
        switch position(fraction) {
        case .isBefore: return 1.0
        case .isAfter: return 0.0
        case .contains: return (1.0 / length) * (fraction - start)
        }
    }
    
}
