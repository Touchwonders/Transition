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


public typealias AnimationFunction = (Void) -> Void
public typealias AnimationFraction = TimeInterval

public struct AnimationRange {
    let start: AnimationFraction // A value between 0 and 1 that describes the start point of the animation relative to the time frame of the transition
    let end: AnimationFraction   // A value between 0 and 1 that describes the end point of the animation relative to the time frame of the transition
    
    public init(start: AnimationFraction, end: AnimationFraction) {
        assert(start >= 0 && start < end, "Start of range should be greater than 0 and less than end of range.")
        assert(end > start && end <= 1, "End of range should be greater than start of range and less than 1.")
        assert(start != end, "Range start and end cannot be equal.")
        
        self.start = start
        self.end = end
    }
    
    static var full: AnimationRange {
        return AnimationRange(start: 0.0, end: 1.0)
    }
}
