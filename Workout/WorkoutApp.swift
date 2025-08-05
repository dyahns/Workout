import SwiftUI

@main
struct MyApp: App {
    enum Architecture: String, CaseIterable {
        case mvvm = "MVVM"
        case tca = "TCA"
    }
    
    private var architecture: Architecture = .mvvm
    
    var body: some Scene {
        WindowGroup {
            switch architecture {
            case .mvvm:
                MVVMWorkoutView()
            case .tca:
                TCAWorkoutView()
            }
        }
    }
}
