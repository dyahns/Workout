import Foundation

struct WorkoutSet: Identifiable, Equatable {
    let id = UUID()
    var weight: Float?
    var reps: Int?
    var isCompleted: Bool = false
    
    var previousWeight: Float = 15.0
    var previousReps: Int = 10
    
    var displayWeight: String? {
        weight?.formatted()
    }
    
    var displayReps: String? {
        reps?.formatted()
    }
    
    var previousWorkout: String {
        "\(previousWeight) x \(previousReps)"
    }
}
