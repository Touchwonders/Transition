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


/// This class abstracts away the use of a dispatch group
/// that allows us to call a single completion once all animators
/// have completed.
internal class TransitionCompletionCoordinator {
    
    let group = DispatchGroup()
    
    private var completionWorkItem: DispatchWorkItem?
    private var completion: (() -> ())?
    
    
    func add(animator: UIViewPropertyAnimator) {
        group.enter()
        animator.addCompletion { [weak self] _ in
            self?.group.leave()
        }
        updateCompletionIfNeeded()
    }
    
    func completion(_ work: @escaping () -> ()) {
        self.completion = work
        updateCompletionIfNeeded()
    }
    
    private func updateCompletionIfNeeded() {
        if let completion = completion {
            //  Any existing item was scheduled for execution after anything that entered the group thusfar.
            //  When something new enters, we cancel the currently scheduled workItem and create a new completion workItem.
            self.completionWorkItem?.cancel()
            
            let completionWorkItem = DispatchWorkItem(qos: .userInitiated, block: completion)
            group.notify(queue: DispatchQueue.main, work: completionWorkItem)
            self.completionWorkItem = completionWorkItem
        }
    }
    
}
