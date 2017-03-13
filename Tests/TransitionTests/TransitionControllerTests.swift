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


import XCTest
@testable import TransitionPlus
@testable import TestProject


class TransitionControllerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private var transitionController: TransitionController!
    
    private var navigationController: UINavigationController!
    private var transitionsSource: TransitionsSource!
    private var operationDelegate: InteractiveTransitionOperationDelegate!
    private var interactionController: TestInteractionController!
    
    
    func transitionControllerForNavigationTransitions(interactive: Bool = false, perform: ((UINavigationControllerOperation, UINavigationController, UIGestureRecognizer) -> ())? = nil) -> TransitionController {
        navigationController = UINavigationController(rootViewController: UIViewController())
        transitionsSource = TestTransitionsSource(transition: .simple)
        
        if interactive {
            let navigationOperationDelegate = NavigationOperationDelegate(perform: perform)
            operationDelegate = navigationOperationDelegate
            interactionController = TestInteractionController()
            return TransitionController(forInteractiveTransitionsIn: navigationController, transitionsSource: transitionsSource, operationDelegate: navigationOperationDelegate, interactionController: interactionController)
        } else {
            return TransitionController(forTransitionsIn: navigationController, transitionsSource: transitionsSource)
        }
    }
    
    
    func testDependenciesForNonInteractiveNavigationTransitions() {
        let transitionController = transitionControllerForNavigationTransitions()
        
        XCTAssertNotNil(transitionController.operationController)
        XCTAssert(transitionController.operationController === navigationController)
        
        XCTAssertNotNil(transitionController.transitionsSource)
        XCTAssert(transitionController.transitionsSource === transitionsSource)
        
        XCTAssertNil(transitionController.operationDelegate)
        XCTAssertNil(transitionController.interactionController)
    }
    
    func testDependenciesForInteractiveNavigationTransitions() {
        let transitionController = transitionControllerForNavigationTransitions(interactive: true)
        
        XCTAssertNotNil(transitionController.operationController)
        XCTAssert(transitionController.operationController === navigationController)
        
        XCTAssertNotNil(transitionController.transitionsSource)
        XCTAssert(transitionController.transitionsSource === transitionsSource)
        
        XCTAssertNotNil(transitionController.operationDelegate)
        XCTAssert(transitionController.operationDelegate === operationDelegate)
        
        XCTAssertNotNil(transitionController.interactionController)
        XCTAssert(transitionController.interactionController === interactionController)
    }
    
    
    func testCanBeInteractive() {
        let transitionController1 = transitionControllerForNavigationTransitions()
        XCTAssertFalse(transitionController1.canBeInteractive)
        
        let transitionController2 = transitionControllerForNavigationTransitions(interactive: true)
        XCTAssertTrue(transitionController2.canBeInteractive)
    }
    
    
    func testOperation() {
        let callExpectation = expectation(description: "Operation is called")
        let operationExpectation = expectation(description: "Operation matches expectation")
        
        let targetOperation = TransitionOperation.navigation(.push)
        
        transitionController = transitionControllerForNavigationTransitions(interactive: true) { (operation, controller, gr) in
            callExpectation.fulfill()
            if operation == (targetOperation.value as! UINavigationControllerOperation) {
                operationExpectation.fulfill()
            }
        }
        
        interactionController.transitionOperation = targetOperation
        //  For some reason this doesn't do anything...
        navigationController.pushViewController(UIViewController(), animated: true)
        
        waitForExpectations(timeout: 5) { (error) in
            print(error?.localizedDescription)
        }
    }
    
}
