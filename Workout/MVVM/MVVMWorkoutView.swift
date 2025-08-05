import SwiftUI

struct MVVMWorkoutView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    @Namespace private var pillNamespace
    
    var body: some View {
        WorkoutView(
            viewModel: viewModel,
            pillNamespace: pillNamespace
        )
    }
}

#Preview {
    MVVMWorkoutView()
}
