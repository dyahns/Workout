import SwiftUI

class WorkoutViewModel: ObservableObject {
    @Published var workoutState: WorkoutState = .notStarted {
        didSet {
            stateEffects(for: workoutState)
        }
    }
    
    // start with 3x10x15
    @Published var sets: [WorkoutSet] = [
        WorkoutSet(previousWeight: 15.0, previousReps: 10),
        WorkoutSet(previousWeight: 15.0, previousReps: 10),
        WorkoutSet(previousWeight: 15.0, previousReps: 10)
    ]

    @Published var currentSetTime: String = "0:00"
    @Published var restRemaining: TimeInterval = 0
    @Published var restTotal: TimeInterval = 1

    @Published var showSummary: Bool = false
    var completedSets: [WorkoutSet] = []

    internal var currentInput: String? {
        didSet {
            updateCurrentSet()
        }
    }

    private var setTimer: Timer?
    private var restTimer: Timer?
    private var setStartTime: Date?
    private var setElapsedTime: TimeInterval?
    
    init() {
        resetEffects()
    }
    
    deinit {
        resetTimers()
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
        currentSetTime = "0:00"
    }

    private func resetRestTimer() {
        restTimer?.invalidate()
        restTimer = nil
        restRemaining = 0
        restTotal = 1
    }
    
    // MARK: - Keypad input
    
    func keypadInput(_ number: String) {
        guard let currentInput, currentInput != "0" else {
            self.currentInput = number
            return
        }
        
        self.currentInput = "\(currentInput)\(number)"
    }
    
    func keypadBackspace() {
        guard let currentInput, currentInput.count > 1 else {
            self.currentInput = nil
            return
        }
        
        self.currentInput?.removeLast()
    }
    
    // MARK: - Set Updates
    
    func updateCurrentSet() {
        let currentSet = workoutState.currentSet
        guard let setIndex = currentSet.id,
              let inputField = currentSet.input,
              setIndex < sets.count else { return }
        
        switch inputField {
        case .weight:
            sets[setIndex].weight = Float(currentInput ?? "")
        case .reps:
            sets[setIndex].reps = Int(currentInput ?? "")
        }
    }
    
    // MARK: - Timer Updates
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

extension WorkoutViewModel: WorkoutStateProtocol {
    func activeEffects(currentSet: Int) {
        // 1. Cancel the rest timer
        resetRestTimer()

        // 2. if out of sets => .completed and exit
        if currentSet >= sets.count {
            finishWorkout()
            return
        }

        // 3. Start/resume the set timer
        // if resuming - adjust start time to account for elapsed time
        setStartTime = Date().addingTimeInterval(-(setElapsedTime ?? 0))
        
        setTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let startTime = self.setStartTime {
                let totalElapsed = Date().timeIntervalSince(startTime)
                self.setElapsedTime = totalElapsed
                self.currentSetTime = self.formatTime(totalElapsed)
            }
        }
    }
    
    func keypadEffects(currentSet: Int, input: CurrentSet.InputField) {
        // 1. Stop the set timer
        setTimer?.invalidate()
        setTimer = nil
        
        // 2. bring up the keypad, prepare input
        let set = sets[currentSet]
        currentInput = switch input {
            case .weight: set.weight?.formatted()
            case .reps: set.reps?.formatted()
        }
        
        // 3. autofocus on current set's input handled via WorkoutState
    }
    
    func restingEffects(currentSet: Int, duration: TimeInterval) {
        // 1. Mark current set as complete
        if currentSet < sets.count {
            sets[currentSet].isCompleted = true
        }
        
        // 2. Reset the set timer
        resetSetTimer()
        
        // 3. Start the rest timer
        restTotal = duration
        restRemaining = duration
        
        restTimer?.invalidate()
        restTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.restRemaining = max(0, self.restRemaining - 0.1)
            
            if self.restRemaining <= 0 {
                self.finishRest()
                self.resetRestTimer()
            }
        }
    }
    
    func completedEffects(sets: [WorkoutSet]) {
        // 1. reset timers
        resetTimers()
        
        // 2. register workout (optional)
        // TODO: Implement workout logging/persistence if needed
        print("Workout completed with \(sets.count) sets")
        
        // 3. bring up the summary sheet
        completedSets = sets
        showSummary = true
        
        // 4. Reset workout
        resetWorkout()
    }
    
    func resetEffects() {
        sets = sets.map {
            WorkoutSet(previousWeight: $0.weight ?? 15, previousReps: $0.reps ?? 10)
        }
    }
}
