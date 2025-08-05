import SwiftUI

struct AnimatedPillView<ViewModel: WorkoutStateProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    let namespace: Namespace.ID
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                if case .notStarted = viewModel.workoutState {
                    StartButtonView(
                        onStart: viewModel.startWorkout,
                        namespace: namespace
                    )
                }
                
                if case .active = viewModel.workoutState {
                    ActiveStateView(
                        currentTime: viewModel.currentSetTime,
                        onTimerTap: viewModel.toggleTimer,
                        onFinish: viewModel.finishWorkout,
                        namespace: namespace
                    )
                }
                
                if case .keypad(_, let input) = viewModel.workoutState {
                    KeypadView(
                        field: input,
                        onNumberTap: viewModel.keypadInput,
                        onDeleteTap: viewModel.keypadBackspace,
                        onNext: viewModel.submitInput,
                        onCancel: viewModel.toggleTimer,
                        namespace: namespace
                    )
                }
                
                if case .restSelection = viewModel.workoutState {
                    RestSelectionView(
                        onSelectDuration: viewModel.selectRest,
                        onCancel: viewModel.cancelRestSelection,
                        namespace: namespace
                    )
                }
                
                if case .resting = viewModel.workoutState {
                    RestCountdownView(
                        timeRemaining: viewModel.restRemaining,
                        timeTotal: viewModel.restTotal,
                        onSkip: viewModel.finishRest,
                        namespace: namespace
                    )
                }
                
                if case .completed = viewModel.workoutState {
                    EmptyView()
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.black)
            )
            .animation(.spring(response: 0.7, dampingFraction: 0.7), value: viewModel.workoutState)
        }
    }
}

#Preview {
    @Previewable @Namespace var namespace
    AnimatedPillView(viewModel: WorkoutViewModel(), namespace: namespace)
        .padding()
}
