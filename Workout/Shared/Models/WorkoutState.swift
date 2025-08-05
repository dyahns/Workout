import Foundation

enum WorkoutState: Equatable {
    case notStarted
    case active(currentSet: Int)
    case keypad(currentSet: Int, input: CurrentSet.InputField)
    case restSelection(currentSet: Int)
    case resting(currentSet: Int, restDuration: TimeInterval)
    case completed(completedSets: [WorkoutSet])
}

extension WorkoutState {
    func progress(with action: Action) -> Self? {
        switch (self, action) {
        // MARK: .notStarted
        case (.notStarted, .startWorkout):
            return .active(currentSet: 0)
            
        // MARK: .active
        case (.active(let setIndex), .toggleTimer):
            return .keypad(currentSet: setIndex, input: .weight)
            
        case (.active, .finishWorkout(let sets)):
            return .completed(completedSets: sets)
            
        // MARK: .keypad
        case (.keypad(let setIndex, _), .toggleTimer):
            return .active(currentSet: setIndex)
            
        case (.keypad(let setIndex, let input), .submitInput):
            switch input {
            case .weight:
                return .keypad(currentSet: setIndex, input: .reps)
            case .reps:
                return .restSelection(currentSet: setIndex)
            }
            
        // MARK: .restSelection
        case (.restSelection(let setIndex), .cancelRestSelection):
            return .keypad(currentSet: setIndex, input: .weight)
            
        case (.restSelection(let setIndex), .selectRest(let duration)):
            return .resting(currentSet: setIndex, restDuration: duration)
            
        // MARK: .resting
        case (.resting(let setIndex, _), .finishRest):
            return .active(currentSet: setIndex + 1)
            
        // MARK: .completed
        case (.completed(_), .resetWorkout):
            return .notStarted
            

        // MARK: Invalid Transitions
        default:
            print("⚠️ Invalid transition: \(self.description()) => \(action.description())")
            return nil
        }
    }

}

extension WorkoutState {
    var currentSet: CurrentSet {
        let index: Int? = switch self {
        case .active(let index), .keypad(let index, _), .restSelection(let index), .resting(let index, _): index
        default: nil
        }
        
        let input: CurrentSet.InputField? = switch self {
        case .keypad(_, let input): input
        default: nil
        }
        
        return .init(id: index, input: input)
    }
}

extension WorkoutState {
    enum Action {
        case startWorkout
        case finishWorkout(completedSets: [WorkoutSet])
        case toggleTimer
        case submitInput
        case cancelRestSelection
        case selectRest(duration: TimeInterval)
        case finishRest
        case resetWorkout
        
        func description() -> String {
            switch self {
            case .startWorkout:
                return "Start Workout"
            case .toggleTimer:
                return "Toggle Timer"
            case .submitInput:
                return "Next Button"
            case .cancelRestSelection:
                return "Cancel from Rest Selection"
            case .selectRest(let duration):
                return "Select Rest (\(Int(duration))s)"
            case .finishRest:
                return "Finish Rest"
            case .finishWorkout:
                return "Finish Workout"
            case .resetWorkout:
                return "Reset Workout"
            }
        }
    }
}

extension WorkoutState {
    func description() -> String {
        switch self {
        case .notStarted:
            return "Not Started"
        case .active(let set):
            return "Active (Set \(set + 1))"
        case .keypad(let set, let input):
            return "Keypad (Set \(set + 1), \(input))"
        case .restSelection(let set):
            return "Rest Selection (Set \(set + 1))"
        case .resting(let set, let duration):
            return "Resting (Set \(set + 1), duration \(Int(duration))s)"
        case .completed:
            return "Completed"
        }
    }
}
