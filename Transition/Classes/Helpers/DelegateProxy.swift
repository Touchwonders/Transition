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


//  Discussion: as an initial solution for sending delegate messages to multiple
//  delegates, this delegate proxy simply implements all messages and forwards them.
//  Given the context in which this is used, there only are two delegates; a primary
//  (the original delegate) and a secondary (TransitionController).
//  The primary delegate always takes precedence over the secondary.
//  A more dynamic and future-proof solution might be one such as is found in RxSwift:
//  https://github.com/ReactiveX/RxSwift/blob/master/RxCocoa/Common/DelegateProxy.swift
//  Maybe something for a future update.


import Foundation


public class DelegateProxy<DelegateType: NSObjectProtocol> : NSObject {
    private(set) internal weak var primaryDelegate: DelegateType?
    private(set) internal weak var secondaryDelegate: DelegateType?
    
    public init(primary: DelegateType, secondary: DelegateType) {
        primaryDelegate = primary
        secondaryDelegate = secondary
        super.init()
    }
    
    internal var delegates: [DelegateType] {
        return [primaryDelegate, secondaryDelegate].flatMap({$0})
    }
    
    internal func firstDelegateRespondingTo(_ selector: Selector) -> DelegateType? {
        return delegates.first { $0.responds(to: selector) }
    }
    
    override public func responds(to aSelector: Selector!) -> Bool {
        return firstDelegateRespondingTo(aSelector) != nil
    }
}
