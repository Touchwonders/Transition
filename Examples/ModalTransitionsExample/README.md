# ModalTransitionsExample

This is a small example project demonstrating how to implement interactive custom **modal** ViewController transitions.

Please run ```pod install``` first.

---

The example begins with the `ShapeSourceViewController`, showing four `ShapeView`s that can be dragged. If dragged upwards, the `DropTargetViewController`'s view will appear, showing a drop target (a hole) in which the dragged `ShapeView` can be dropped. Once dropped, the `DropTargetViewController`'s view will move to fullscreen, showing a number of counters, one for each available shape, and the counter associated with the dropped `ShapeView` will be incremented.

This example showcases the use of an "interactive element", a view that can be moved from one viewController to another (here from the source to the presented). The `ShapeViews` in the `ShapeSourceViewController` can provide an object that serves as interactive element: a `TransitioningShapeView` that conforms to `SharedElement`. Note that it is not the actual `ShapeView` but a snapshot that will be placed in the transitionContext and moved during transition.

---

The two most important objects in this example are:

* the **`ShapeInteractionController`** (a `TransitionInteractionController`)
* the **`ShapeInteractionAnimation`** (a `SharedElementAnimation`)

The `ShapeInteractionController` manages the translation of a pan gesture into the appropriate transition operation (present / dismiss / none) and progress of the transition. To be able to determine if the gesture begins at a `ShapeView` (initiating dragging), it needs to hit-test all `ShapeViews`. As such, it is also the logical object to be the `SharedElementProvider`, providing the selected `ShapeView`'s `TransitioningShapeView` that will be used during transition.

The `ShapeInteractionAnimation` describes the movement of that `TransitioningShapeView` (passed to it via its `sharedElement` property) during animation and interaction phases.

To be able to move a `ShapeView`s snapshot between its initial and target position (taking into account the initial touch offset of the gesture relative to the `ShapeView`'s center), the `ShapeInteractionController` sets the appropriate values on the `TransitioningShapeView`.
