# TabBarTransitionsExample

This is a small example project demonstrating how to implement interactive custom ViewController transitions for a **`UITabBarController`**.

Please run ```pod install``` first.

---

The example populates a `UITabBarController` with four instances of `ViewController`, each getting a different shape assigned so that you can visually differentiate the views.

Upon launch, a convenience object `TabBarTransitions` is created that takes care of instantiating the `TransitionController` for the `UITabBarController`. It uses `TabBarInteraction` as the `TransitionInteractionController`, providing a pan gesture to move between tabs.

All transitions are defined as `ShapeTransitionAnimation`s, which move in the next view from the side (which side depends on the relative index), adding a blur view during transition.

There is no interactive "element" – a view that is interactively moved between the from- and toView during transition.
