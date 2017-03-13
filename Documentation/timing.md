# A Note On Timing

### Duration
The **duration** of a transition is used in the *animation phase(s)* of a transition. This can be the entire length of the transition if the transition is initiated programmatically and there's no interruption / interaction. It can also be after interaction ends, animating towards either end or start (completion or cancellation).

### AnimationRange
The transition can have one or more animation layers, each with an `AnimationRange`, indicating the relative start and end time of a layer to the total duration of the transition.
For example, an `AnimationRange(start: 0, end: 0,5)` with a transition duration of 3 seconds will start at 0 seconds and end after 1.5 seconds.

A `Transition`'s `sharedElement` describes how the shared element should move during interaction, but also how it should animate during animation phases. If the `sharedElement` is specified, it will have an implicit `AnimationRange` of 0 to 1 (the `AnimationRange.full` range).

The reason for having an AnimationRange relative to the transition duration is because this duration can be influenced by timing arameters.

### AnimationTimingParameters

Timing parameters describe a timing curve that defines the velocity at which animated properties change to their new values over the duration of the animation. This curve can either be cubic (represented by `UICubicTimingParameters`) or follow a spring behavior (represented by `UISpringTimingParameters`). On initializing a `UIViewPropertyAnimator`, these timing parameters are passed together with the required duration. The property animator will pace the animation by following the timing curve over the length of the duration.

The motion of a spring can be defined either by specifying a `dampingRatio` and `initialVelocity`, or by exactly specifying the spring's `mass`, `stiffness`, `daming` and `initialVelocity`. The former can be configured such that the spring movement settles after the duration. The latter however specifies a fully configured spring system that realistically oscillates according to physics and cannot be influenced to settle at a specific moment. As such it has an **implicit duration**.

We introduce the `AnimationTimingParameters` struct to be able to tell whether the provided timingParameters will have such an implicit duration or not, because from `UISpringTimingParameters` it cannot be derived.

### Effective duration

Any layer (animation or sharedElement) can have timing parameters that have an implicit duration. The presence thereof will influence the **effective duration** of the transition.

* The effective duration is initially expected to be the duration specified in your `Transition`.

* Then, we inspect all animation layers specified in the transition's `animation`. If any layer has an implicit duration that causes that layer to end after the original transition duration, this will extend the effective duration such that the layer ends exactly at the end of the entire transition.

* If there's a `sharedElement` specified, we set its duration to be the effective duration as we know it at this point. However, if the `sharedElement` has timing parameters with an implicit duration, *that* duration will ultimately be the effective duration of the transition.