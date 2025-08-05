import SwiftUI

struct TCAWorkoutView: View {
    @StateObject private var store = WorkoutStore()
    @Namespace private var pillNamespace
    
    var body: some View {
        WorkoutView(
            viewModel: store,
            pillNamespace: pillNamespace
        )
    }
}

#Preview {
    TCAWorkoutView()
}
