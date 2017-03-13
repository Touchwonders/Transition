# Adding A Shared Element

Your transition already has a custom animation and custom interaction. What can we add more?

A "shared element". By this we mean a single view that represents content present in both ViewControllers in the transition (the "`from`" and "`to`"). An example might be a photo that is selected from a collectionView, transitioning to a detailView for that specific photo.

### The SharedElementTransition

Commonly this shared element will follow the interaction gesture, moving around in the transitionContext's containerView. During animation phase(s) it should animate towards its target position / size. Therefore there are two parts – animation and interaction – that together form the specification of your shared element's transition:

`SharedElementAnimation` + `SharedElementInteraction` = `SharedElementTransition`

We'll get to the specifics of these, but first:

### The SharedElement

In both parts you'll have access to a `SharedElement` object. This object provides the `transitioningView` that can be put in the transitionContext's containerView. It is advised that this is not the actual view from either your from- or toView, but rather a snapshot that can safely be discarded after transition. The `SharedElement` is a protocol that allows you to encapsulate any other information you might require for properly implementing the animation / updating of the element's movement. Also think about whether or not the snapshot should change scale during transition; you might want to use a UIImageView as `transitioningView`.

### The SharedElementAnimation

In this part of the `SharedElementTransition` you specify how the `SharedElement`'s `transitioningView` should animate. Important to know is that animation of the shared element is set up every time after interaction (and on programmatic initiation at which we'll begin the transition in animation phase). It will be set up for a specific `UIViewAnimatingPosition` (either `.end` or `.start`) based on the current completion position derived from the interaction gesture (or `.end` when no interaction has occcured yet). This position will be available to you via the `animatingPosition` property, such that you can adjust the `sharedElement` to move to either its final or original frame (or adjust it in any other way appropriate for your transition).

### The SharedElementInteraction

In this part of the `SharedElementTransition` you specify how the `SharedElement`'s `transitioningView` should update (move / scale / ...) during interaction. You are given the opportunity to perform initial steps prior to updating by implementing:

```swift
func startInteraction(in context: UIViewControllerContextTransitioning, 
               gestureRecognizer: UIGestureRecognizer)
```

Note that the gestureRecognizer passed here is not necessarily the gestureRecognizer of your `TransitionInteractionController`. Under the hood a long-press gesture recognizer is installed in your transitioning context, such that interruption can be detected. From that point on your interaction gesture might take over, but to ensure you have the right `location(in: view...)` available at `startInteraction`, the long-press gesture recognizer will be passed if that initiated the interaction.

During interaction the following function will be called frequently, allowing you to update your `transitioningView`:

```swift
func updateInteraction(in context: UIViewControllerContextTransitioning, 
            interactionController: TransitionInteractionController, 
                         progress: TransitionProgress)
```

You might recall from implementing the `TransitionInteractionController` ([this guide](custom_interaction.md)) that `TransitionProgress` can either be a relative step compared to the last update, or an overall fractionComplete. Ensure that both your `TransitionInteractionController` and `SharedElementInteraction` talk the same language.

### The SharedElementProvider

We still need a means to obtain the `sharedElement`. Since it is often tightly coupled to the interaction gesture (for instance because of hit-testing), the `TransitionInteractionController` includes a property on which you can set the `sharedElementProvider`.

The `SharedElementProvider` is a protocol requiring a single function to be implemented:

```swift
    func sharedElementForInteractiveTransition(
                    with interactionController: TransitionInteractionController, 
                           in operationContext: TransitionOperationContext) -> SharedElement?
```

And that's it!