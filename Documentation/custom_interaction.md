# Adding Custom Interaction

Now you've seen how easy it is to build a custom view controller transition animation, let's dive in further and add some custom interaction.

Transition offers you two approaches:

1. **DIY**: implement an object that conforms to the `TransitionInteractionController` protocol
2. **Drop-in**: use Transition's built-in `PanInteractionController` for basic pan-gesture interaction

Want to take it easy? just [skip to **2.**](#2-paninteractioncontroller)

Either way, with custom interaction comes the requirement for an [`InteractiveTransitionOperationDelegate`](#the-interactivetransitionoperationdelegate).

---

## 1. TransitionInteractionController

The requirements are quite straightforward:

1. What gesture should drive the interaction?
2. What kind of operation *(navigation push / pop, modal present / dismiss, tabbar index change)* should initiate when the gesture is recognized?
3. What is the progress of the transition based on the change of the recognized gesture?
4. When the gesture ends, should the transition complete or cancel?


#### 1. What gesture should drive the interaction?
We start by creating an object that conforms to `TransitionInteractionController`.
You'll be required to implement several functions, but everything starts with the `gestureRecognizer`. We will use a `UIPanGestureRecognizer`, which you can easily expose as follows:

```swift
private let panGestureRecognizer = UIPanGestureRecognizer()
public var gestureRecognizer: UIGestureRecognizer { return panGestureRecognizer }
```

The first line instantiates our `panGestureRecognizer` for internal use in our object, the second one is in accordance with the `TransitionInteractionController` protocol.

#### 2. What kind of operation should initiate when the gesture is recognized?

The `TransitionController` will register as target of your gestureRecognizer. When the gesture is recognized, it'll ask your `TransitionInteractionController` which `TransitionOperation` should be initiated based on the gesture (this can be no action at all too).

You answer by implementing:

```swift
func operationForInteractiveTransition() -> TransitionOperation
```

Our pan gesture has a translation (in: view...) that can be used to determine in which direction the gesture was made. You convert this to whatever `TransitionOperation` you prefer, for example `.navigation(.push)`, or `.none` if the gesture was in the wrong direction.

#### 3. What is the progress of the transition based on the change of the recognized gesture?

The gesture recognizer will frequently call its targets during interaction, causing your `TransitionInteractionController` to be asked to translate the current position or movement of the gesture into the progress of the transition. You do this in:

```swift
func progress(in transitionOperationContext: TransitionOperationContext) -> TransitionProgress
```

Your answer can either represent a small step relative to the last update that will be added to the current `fractionComplete` of the transition, or an overall `fractionComplete` that will be used as the new corresponding value for the transition.

#### 4. When the gesture ends, should the transition complete or cancel?

When the gesture ends, you want the transition to nicely animate towards the end, completing the transition.

However, it might be that the gesture movement was insufficient to decently complete the transition operation, or the movement went backwards halfway the transition. In such cases you might wish to reverse the transition, effectively rolling it back to the start, cancelling the transition operation.

Answer accordingly by implementing:

```swift
func completionPosition(in transitionOperationContext: TransitionOperationContext, 
                                     fractionComplete: AnimationFraction) -> UIViewAnimatingPosition
```

---

## 2. PanInteractionController

For your pleasure we have added an easy to use `TransitionInteractionController` for basic **pan** gestures, called the `PanInteractionController`. It can be used for any kind of transition (navigation, modal, tabBar).

For navigation and modal transitions, you initialize it with

```swift
PanInteractionController(forNavigationTransitionsAtEdge: TransitionScreenEdge)
```

or

```swift
PanInteractionController(forModalTransitionsAtEdge: TransitionScreenEdge)
```

respectively. The `TransitionScreenEdge` (`.top`, `.right`, `.bottom` or `.left`) designates the edge of the screen from which new viewControllers will be presented or towards which they will be dismissed. To mimic native navigationController transitions, you would set this to `.right` (at least for left-to-right languages), and for modal transitions this would be `.bottom`. However you can now set this to whatever you like!

For tabBar transitions a different initializer is available that corresponds to the direction of items on the tabBar. To initialize one, call:

```swift
PanInteractionController.forTabBarTransitions(rightToLeft: Bool = false)
```

By default this is configured for left-to-right language apps where the tabBar item indices increase from left to right.

### CompletionThreshold

The `PanInteractionController` has a built-in `completionThreshold` (default: 1/3 of the transition progress) above which the transition will complete, but below which the transition will rewind to the start and cancel the transition operation. You can set this to anything between 0 and 1.

### Flick

Another default feature is the "flick", a swift movement at the end of the gesture that has enough velocity to complete the transition in the direction of the flick (this might be towards the end but also towards the start). You can adjust the minimum velocity (expressed in points per second) for recognizing an ended pan gesture as a flick. You can also turn off this feature completely.

### Updating Progress

Depending on how you implement the `interaction` part of your `Transition` (which describes how the "Shared Element" should animate and move – [more info here](shared_element.md)) you might want the `TransitionInteractionController` to update the progress either as small step relative to the last update, or as an overall fraction complete. By default, the `PanInteractionController` updates the progress as fraction complete, but you can switch this to progress step by setting `updateProgressAsStep` to true.

---

## The InteractiveTransitionOperationDelegate

The operation resulting from your recognized gesture can be any of the following:

* Navigation push
* Navigation pop
* Modal present
* Modal dismiss
* Increase TabBar index
* Decrease TabBar index

The `TransitionController` leaves it up to you to appropriately respond to whatever applies for your configuration (you can only use a `TransitionController` and associates for a single type – navigation, modal or tabBar – at a time). 

The main reason for this is that Transition doesn't know which ViewController to instantiate when pushing or presenting. The delegate comes in three flavors:

### InteractiveNavigationTransitionOperationDelegate

```swift
      func performOperation(operation: UINavigationControllerOperation,
forInteractiveTransitionIn controller: UINavigationController, 
                    gestureRecognizer: UIGestureRecognizer)
}
```

### InteractiveTabBarTransitionOperationDelegate
    
```swift
      func performOperation(operation: UITabBarControllerOperation,
forInteractiveTransitionIn controller: UITabBarController, 
                    gestureRecognizer: UIGestureRecognizer)
}
```

### InteractiveModalTransitionOperationDelegate
    
```swift
func viewControllerForInteractiveModalPresentation(by sourceViewController: UIViewController, 
                                                         gestureRecognizer: UIGestureRecognizer) -> UIViewController
}
```

**🤔 Hey, that last one looks different!**

Yes. For navigation and tabBar, leaving the operation up to you suffices, but for modal transitions, the correct `transitioningDelegate` and `modalPresentationStyle` must be set on the correct ViewController, at the correct moment. Therefore the operationDelegate is simply asked for the ViewController that needs to be presented, and the `TransitionController` ensures it is presented correctly, with your custom transition.

---

## Adjusting the TransitionController

You'll have to pass your new-found interactionController and operationDelegate to the `TransitionController`. For our simple custom animation we used the initializer:

```swift
TransitionController(forTransitionsIn: navigationController, 
                    transitionsSource: transitionsSource)
```

To make it interactive, change to this initializer:

```swift
TransitionController(
  forInteractiveTransitionsIn navigationController: UINavigationController, 
                                 transitionsSource: TransitionsSource, 
                                 operationDelegate: InteractiveNavigationTransitionOperationDelegate,
                             interactionController: TransitionInteractionController)
```

For interactive tabBar transitions a similar initializer is available. For interactive modal transitions, the `sourceViewController` (the one on which you'd call `present(_, animated:, completion:)`) is required to also be the `InteractiveModalTransitionOperationDelegate`, so the initializer signature is slightly different.

---

Feeling lucky? Let's dive in further and add a [shared element](shared_element.md)!