import SwiftUI

struct WorkoutView<ViewModel: WorkoutStateProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    let pillNamespace: Namespace.ID
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                VStack(spacing: 20) {
                    Text("Bench Press (Dumbbell)")
                        .fontWeight(.medium)
                        .padding(.top, 10)
                    
                    SetListView(
                        sets: viewModel.sets,
                        currentSet: viewModel.workoutState.currentSet,
                        input: viewModel.currentInput,
                        onTap: viewModel.toggleTimer
                    )
                }
                .frame(alignment: .top)
                .padding(.vertical, 16)
                .padding(.horizontal, 4)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                )
                .padding(.horizontal, 20)

                Spacer()
                
                AnimatedPillView(
                    viewModel: viewModel,
                    namespace: pillNamespace
                )
                .padding(.horizontal, 20)
            }
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $viewModel.showSummary) {
            WorkoutSummaryView(sets: viewModel.completedSets)
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    @Previewable @Namespace var namespace
    WorkoutView(viewModel: WorkoutViewModel(), pillNamespace: namespace)
}
