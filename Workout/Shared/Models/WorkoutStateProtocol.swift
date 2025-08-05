import Foundation

protocol WorkoutStateProtocol: ObservableObject {
    var workoutState: WorkoutState { get set }
    var sets: [WorkoutSet] { get }
    var completedSets: [WorkoutSet] { get }
    var showSummary: Bool { get set }
    
    // State machine actions
    func startWorkout()
    func finishWorkout()
    func toggleTimer()
    func submitInput()
    func cancelRestSelection()
    func selectRest(duration: TimeInterval)
    func finishRest()
    func resetWorkout()
    
    // State effects
    func activeEffects(currentSet: Int)
    func keypadEffects(currentSet: Int, input: CurrentSet.InputField)
    func restingEffects(currentSet: Int, duration: TimeInterval)
    func completedEffects(sets: [WorkoutSet])
    func resetEffects()
    
    // Active set
    var currentSetTime: String { get }
    
    // Keypad input
    func keypadInput(_ number: String)
    func keypadBackspace()
    var currentInput: String? { get }
    
    // Rest
    var restRemaining: TimeInterval { get }
    var restTotal: TimeInterval { get }
}

extension WorkoutStateProtocol {
    func startWorkout() {
        progress(with: .startWorkout)
    }
    
    func finishWorkout() {
        progress(with: .finishWorkout(completedSets: sets))
    }
    
    func toggleTimer() {
        progress(with: .toggleTimer)
    }
    
    func submitInput() {
        progress(with: .submitInput)
    }
    
    func cancelRestSelection() {
        progress(with: .cancelRestSelection)
    }
    
    func selectRest(duration: TimeInterval) {
        progress(with: .selectRest(duration: duration))
    }
    
    func finishRest() {
        progress(with: .finishRest)
    }
    
    func resetWorkout() {
        progress(with: .resetWorkout)
    }

    func progress(with action: WorkoutState.Action) {
        guard let next = workoutState.progress(with: action) else { return }
        workoutState = next
    }
    
    func stateEffects(for state: WorkoutState) {
        switch state {
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
}
