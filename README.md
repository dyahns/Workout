### Animations

Challenges: 
1. separate but synced animation of button shapes and captions.
2.  SwiftUI rendering engine is too sensitive to view hierarchies and easily falls back to cross-fading element instead of morphing from one to another.

Solution: 
matchedGeometryEffect. Covers most of animation logic with custom intervention in rest selection. Plus standard state based animations.

### App Flow 

- Lack of specs, open to interpretation;
- the flow can be potentially redefined later

Solution: State machine in Shared/Models/WorkoutState.swift


### Architecture considerations

#### MVVM

1. standard, small app, does the job
2. Workout stage, etc. are a shared state
3. The state machine contract can be broken by setting workoutState directly. 
4. Side effects mixed with business logic.


#### Alternative architectures

Exploring alternative architectures is possible thanks to: 
- shared views/presentation layer, 
- shared state machine 
- app logic contracted via a common protocol.

Easy switch between two architectures.
Looks the same from user's perspective.


#### TCA

1. Clear separation of concerns and Unidirectional Data Flow: Actions → Reducer → State → View. Unidirectional Action-based flow reduces maintenance costs as state changes are traceable, debugging is clearer and state snapshotting is possible.
2. Pure Functions: Reducer is predictable and testable. Actions are well defined, state access is isolated.
3. Side-effects like timers are decoupled from pure state logic.
4. Composition: Actions and reducers can be easily composed.
5. Minor challenge of reconciling the @MainActor isolation in TCA implementation with non-isolated protocol. Would be even more straightforward in a single-architecture case.
