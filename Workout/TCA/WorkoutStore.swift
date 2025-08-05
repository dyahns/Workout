import SwiftUI
import Foundation

// MARK: - TCA-like Store Implementation

@MainActor
class WorkoutStore: ObservableObject {
    @Published private(set) var state: State
    
    init() {
        self.state = State()
    }
    
    nonisolated func send(_ action: Action) {
        Task { @MainActor in
            let oldState = state
            state = reducer(state: &state, action: action)
            
            // Handle side effects based on state changes
            if oldState.workoutState != state.workoutState {
                handleStateEffects(state.workoutState)
            }
        }
    }
    
    private func reducer(state: inout State, action: Action) -> State {
        switch action {
        // MARK: - Workout Actions
        case .startWorkout:
            if let newWorkoutState = state.workoutState.progress(with: .startWorkout) {
                state.workoutState = newWorkoutState
            }
            
        case .finishWorkout:
            if let newWorkoutState = state.workoutState.progress(with: .finishWorkout(completedSets: state.sets)) {
                state.workoutState = newWorkoutState
            }
            
        case .toggleTimer:
            if let newWorkoutState = state.workoutState.progress(with: .toggleTimer) {
                state.workoutState = newWorkoutState
            }
            
        case .submitInput:
            if let newWorkoutState = state.workoutState.progress(with: .submitInput) {
                state.workoutState = newWorkoutState
            }
            
        case .cancelRestSelection:
            if let newWorkoutState = state.workoutState.progress(with: .cancelRestSelection) {
                state.workoutState = newWorkoutState
            }
            
        case .selectRest(let duration):
            if let newWorkoutState = state.workoutState.progress(with: .selectRest(duration: duration)) {
                state.workoutState = newWorkoutState
            }
            
        case .finishRest:
            if let newWorkoutState = state.workoutState.progress(with: .finishRest) {
                state.workoutState = newWorkoutState
            }
            
        case .resetWorkout:
            if let newWorkoutState = state.workoutState.progress(with: .resetWorkout) {
                state.workoutState = newWorkoutState
            }
            
        // MARK: - Keypad Actions
        case .keypadInput(let number):
            guard let currentInput = state.currentInput, currentInput != "0" else {
                state.currentInput = number
                state = updateCurrentSet(state: state)
                return state
            }
            state.currentInput = "\(currentInput)\(number)"
            state = updateCurrentSet(state: state)
            
        case .keypadBackspace:
            guard let currentInput = state.currentInput, currentInput.count > 1 else {
                state.currentInput = nil
                state = updateCurrentSet(state: state)
                return state
            }
            state.currentInput = String(currentInput.dropLast())
            state = updateCurrentSet(state: state)
            
        // MARK: - Timer Actions
        case .setTimerTick(let timeString):
            state.currentSetTime = timeString
            
        case .restTimerTick(let remaining):
            state.restRemaining = remaining
            if remaining <= 0 {
                send(.finishRest)
            }
            
        // MARK: - UI Actions
        case .showSummary(let show):
            state.showSummary = show
            
        case .setCompletedSets(let sets):
            state.completedSets = sets
        }
        
        return state
    }
    
    private func updateCurrentSet(state: State) -> State {
        var newState = state
        let currentSet = state.workoutState.currentSet
        guard let setIndex = currentSet.id,
              let inputField = currentSet.input,
              setIndex < newState.sets.count else { return newState }
        
        switch inputField {
        case .weight:
            newState.sets[setIndex].weight = Float(state.currentInput ?? "")
        case .reps:
            newState.sets[setIndex].reps = Int(state.currentInput ?? "")
        }
        
        return newState
    }
    
    // MARK: - Side Effects
    
    private var setTimer: Timer?
    private var restTimer: Timer?
    private var setStartTime: Date?
    private var setElapsedTime: TimeInterval?
    
    private func handleStateEffects(_ workoutState: WorkoutState) {
        switch workoutState {
        case .notStarted:
            resetEffects()
        case .active(let currentSet):
            activeEffects(currentSet: currentSet)
        case .keypad(let currentSet, let input):
            keypadEffects(currentSet: currentSet, input: input)
        case .restSelection(_):
            break
        case .resting(let currentSet, let duration):
            restingEffects(currentSet: currentSet, duration: duration)
        case .completed(let completedSets):
            completedEffects(sets: completedSets.filter({ $0.isCompleted }))
        }
    }
    
    nonisolated internal func activeEffects(currentSet: Int) {
        Task { @MainActor in
            // 1. Cancel the rest timer
            resetRestTimer()
            
            // 2. if out of sets => .completed and exit
            if currentSet >= state.sets.count {
                send(.finishWorkout)
                return
            }
            
            // 3. Start/resume the set timer
            // if resuming - adjust start time to account for elapsed time
            setStartTime = Date().addingTimeInterval(-(setElapsedTime ?? 0))
            
            setTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    if let startTime = self.setStartTime {
                        let totalElapsed = Date().timeIntervalSince(startTime)
                        self.setElapsedTime = totalElapsed
                        let timeString = self.formatTime(totalElapsed)
                        self.send(.setTimerTick(timeString))
                    }
                }
            }
        }
    }
    
    nonisolated internal func keypadEffects(currentSet: Int, input: CurrentSet.InputField) {
        Task { @MainActor in
            // 1. Stop the set timer
            setTimer?.invalidate()
            setTimer = nil
            
            // 2. bring up the keypad, prepare input
            guard currentSet < state.sets.count else { return }
            let set = state.sets[currentSet]
            let inputValue = switch input {
            case .weight: set.weight?.formatted()
            case .reps: set.reps?.formatted()
            }
            
            var newState = state
            newState.currentInput = inputValue
            state = newState
            
            // 3. autofocus on current set's input handled via WorkoutState
        }
    }
    
    nonisolated internal func restingEffects(currentSet: Int, duration: TimeInterval) {
        Task { @MainActor in
            // 1. Mark current set as complete
            if currentSet < state.sets.count {
                var newState = state
                newState.sets[currentSet].isCompleted = true
                state = newState
            }
            
            // 2. Reset the set timer
            resetSetTimer()
            
            // 3. Start the rest timer
            var newState = state
            newState.restTotal = duration
            newState.restRemaining = duration
            state = newState
            
            restTimer?.invalidate()
            restTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    let newRemaining = max(0, self.state.restRemaining - 0.1)
                    self.send(.restTimerTick(newRemaining))
                    
                    if newRemaining <= 0 {
                        self.send(.finishRest)
                        self.resetRestTimer()
                    }
                }
            }
        }
    }
    
    nonisolated internal func completedEffects(sets: [WorkoutSet]) {
        Task { @MainActor in
            // 1. reset timers
            resetTimers()
            
            // 2. register workout (optional)
            // TODO: Implement workout logging/persistence if needed
            print("Workout completed with \(sets.count) sets")
            
            // 3. bring up the summary sheet
            send(.setCompletedSets(sets))
            send(.showSummary(true))
            
            // 4. Reset workout
            send(.resetWorkout)
        }
    }
    
    nonisolated internal func resetEffects() {
        Task { @MainActor in
            var newState = state
            newState.sets = newState.sets.map {
                WorkoutSet(previousWeight: $0.weight ?? 15, previousReps: $0.reps ?? 10)
            }
            state = newState
        }
    }
    
    private func resetTimers() {
        resetSetTimer()
        resetRestTimer()
    }
    
    private func resetSetTimer() {
        setTimer?.invalidate()
        setTimer = nil
        setStartTime = nil
        setElapsedTime = nil
        // Update state to show 0:00
        send(.setTimerTick("0:00"))
    }
    
    private func resetRestTimer() {
        restTimer?.invalidate()
        restTimer = nil
        // Reset rest state
        var newState = state
        newState.restRemaining = 0
        newState.restTotal = 1
        state = newState
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    deinit {
        // Note: deinit runs in nonisolated context, but Timer.invalidate() is safe to call
        setTimer?.invalidate()
        restTimer?.invalidate()
    }
}

// MARK: - State & Actions

extension WorkoutStore {
    struct State {
        var workoutState: WorkoutState = .notStarted
        var sets: [WorkoutSet] = [
            WorkoutSet(previousWeight: 15.0, previousReps: 10),
            WorkoutSet(previousWeight: 15.0, previousReps: 10),
            WorkoutSet(previousWeight: 15.0, previousReps: 10)
        ]
        var currentSetTime: String = "0:00"
        var restRemaining: TimeInterval = 0
        var restTotal: TimeInterval = 1
        var showSummary: Bool = false
        var completedSets: [WorkoutSet] = []
        var currentInput: String?
    }
    
    enum Action {
        // Workout actions
        case startWorkout
        case finishWorkout
        case toggleTimer
        case submitInput
        case cancelRestSelection
        case selectRest(duration: TimeInterval)
        case finishRest
        case resetWorkout
        
        // Keypad actions
        case keypadInput(String)
        case keypadBackspace
        
        // Timer actions
        case setTimerTick(String)
        case restTimerTick(TimeInterval)
        
        // UI actions
        case showSummary(Bool)
        case setCompletedSets([WorkoutSet])
    }
}

// MARK: - Protocol Conformance

extension WorkoutStore: WorkoutStateProtocol {
    nonisolated var workoutState: WorkoutState {
        get { 
            MainActor.assumeIsolated { state.workoutState }
        }
        set { 
            Task { @MainActor in
                var newState = state
                newState.workoutState = newValue
                state = newState
                handleStateEffects(newValue)
            }
        }
    }
    
    nonisolated var sets: [WorkoutSet] { 
        MainActor.assumeIsolated { state.sets }
    }
    nonisolated var completedSets: [WorkoutSet] { 
        MainActor.assumeIsolated { state.completedSets }
    }
    nonisolated var showSummary: Bool {
        get { 
            MainActor.assumeIsolated { state.showSummary }
        }
        set { send(.showSummary(newValue)) }
    }
    
    nonisolated var currentSetTime: String { 
        MainActor.assumeIsolated { state.currentSetTime }
    }
    nonisolated var currentInput: String? { 
        MainActor.assumeIsolated { state.currentInput }
    }
    nonisolated var restRemaining: TimeInterval { 
        MainActor.assumeIsolated { state.restRemaining }
    }
    nonisolated var restTotal: TimeInterval { 
        MainActor.assumeIsolated { state.restTotal }
    }
    
    nonisolated func startWorkout() { send(.startWorkout) }
    nonisolated func finishWorkout() { send(.finishWorkout) }
    nonisolated func toggleTimer() { send(.toggleTimer) }
    nonisolated func submitInput() { send(.submitInput) }
    nonisolated func cancelRestSelection() { send(.cancelRestSelection) }
    nonisolated func selectRest(duration: TimeInterval) { send(.selectRest(duration: duration)) }
    nonisolated func finishRest() { send(.finishRest) }
    nonisolated func resetWorkout() { send(.resetWorkout) }
    
    nonisolated func keypadInput(_ number: String) { send(.keypadInput(number)) }
    nonisolated func keypadBackspace() { send(.keypadBackspace) }
}
