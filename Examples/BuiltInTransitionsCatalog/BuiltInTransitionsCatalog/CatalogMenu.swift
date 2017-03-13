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


class CatalogMenu : UITableViewController {
    
    let panInteractionController = PanInteractionController(forNavigationTransitionsAtEdge: .right)
    var transitionController: TransitionController?
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitionController = TransitionController(forInteractiveTransitionsIn: navigationController!, transitionsSource: self, operationDelegate: self, interactionController: panInteractionController)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectedIndex = nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Catalog.numberOfItems.rawValue
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CatalogMenuCell", for: indexPath) as! CatalogMenuCell
        cell.transitionTitle.text = Catalog(rawValue: indexPath.row)?.title
        cell.backgroundColor = color(indexPath.row)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        pushAwesomeness()
    }
    
    func pushAwesomeness() {
        guard let awesomeViewController = storyboard?.instantiateViewController(withIdentifier: "AwesomeViewController") as? AwesomeViewController, let selectedIndex = selectedIndex else { return }
        awesomeViewController.catalogItem = Catalog(rawValue: selectedIndex)!
        awesomeViewController.colorIndex = selectedIndex
        navigationController?.pushViewController(awesomeViewController, animated: true)
    }
}

extension CatalogMenu : TransitionsSource {
    
    func transitionFor(operationContext: TransitionOperationContext, interactionController: TransitionInteractionController?) -> Transition {
        guard let selectedIndex = selectedIndex, let transitionType = Catalog(rawValue: selectedIndex) else {
            fatalError("No transition found")
        }
        return Transition(duration: 0.5, animation: transitionType.transitionAnimation)
    }
}

extension CatalogMenu : InteractiveNavigationTransitionOperationDelegate {
    
    func performOperation(operation: UINavigationControllerOperation, forInteractiveTransitionIn controller: UINavigationController, gestureRecognizer: UIGestureRecognizer) {
        switch operation {
        case .push:
            if selectedIndex == nil {
                if let selectedCell = tableView.visibleCells.first(where: { cell in
                    let frame = view.convert(cell.frame, from: cell.superview)
                    return frame.contains(gestureRecognizer.location(in: view))
                }) {
                    selectedIndex = tableView.indexPath(for: selectedCell)?.row
                }
            }
            pushAwesomeness()
            
        case .pop:
            let _ = navigationController?.popViewController(animated: true)
        default: break
        }
        
    }
}


class CatalogMenuCell : UITableViewCell {
    @IBOutlet weak var transitionTitle: UILabel!
}
