import SwiftUI

struct SetRowView: View {
    let index: Int
    let set: WorkoutSet
    let currentSet: CurrentSet
    let input: String?
    let widths: SetListView.SetColumnWidths
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(index + 1)")
                .foregroundStyle(isActive ? .green : .secondary)
                .font(.body)
                .fontWeight(isActive ? .bold : .medium)
                .frame(minWidth: widths.0)
            
            Text(set.previousWorkout)
                .font(.body)
                .foregroundColor(.secondary)
                .frame(minWidth: widths.1)
            
            displayView(
                type: .weight,
                text: displayWeight,
                isSet: set.weight != nil
            )
            
            displayView(
                type: .reps,
                text: displayReps,
                isSet: set.reps != nil
            )
            
            Image(systemName: set.isCompleted ? "checkmark.square.fill" : "square")
                .foregroundColor(.secondary)
                .font(.title3)
                .frame(minWidth: widths.4)
        }
        .padding(.horizontal, 20)
        .frame(height: 44)
    }
    
    private var displayWeight: String {
        let input = isInFocus(input: .weight) ? self.input : nil
        return input ?? (set.displayWeight ?? "-")
    }

    private var displayReps: String {
        let input = isInFocus(input: .reps) ? self.input : nil
        return input ?? (set.displayReps ?? "-")
    }

    private var isActive: Bool {
        currentSet.id == index
    }

    private func isInFocus(input: CurrentSet.InputField) -> Bool {
        currentSet.id == index && currentSet.input == input
    }
    
    private func displayView(type: CurrentSet.InputField, text: String, isSet: Bool) -> some View {
        Text(text)
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(textColor(isSet: isSet))
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor(isSet: isSet))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                borderColor(
                                    isSet: isSet,
                                    isInFocus: isInFocus(input: type)
                                ),
                                lineWidth: 1
                            )
                    )
            )
    }
    
    private func textColor(isSet: Bool) -> Color {
        isSet ? .primary : .secondary
    }
    
    private func backgroundColor(isSet: Bool) -> Color {
        isSet ? Color(.systemBackground) : Color(.systemGray6)
    }
    
    private func borderColor(isSet: Bool, isInFocus: Bool) -> Color {
        isInFocus ? .blue :
        (isSet ? Color(.systemGray4) : Color(.systemGray5))
    }
}

#Preview {
    let widths: SetListView.SetColumnWidths = (30, 70, 70, 70, 28)
    
    VStack(spacing: 8) {
        // Completed set
        SetRowView(
            index: 0,
            set: WorkoutSet(weight: 45, reps: 10, isCompleted: true),
            currentSet: CurrentSet(id: 1, input: nil),
            input: nil,
            widths: widths
        )

        // Active set
        SetRowView(
            index: 1,
            set: WorkoutSet(weight: 45, reps: 12),
            currentSet: CurrentSet(id: 1, input: .weight),
            input: "20.",
            widths: widths
        )
        
        // Empty set
        SetRowView(
            index: 2,
            set: WorkoutSet(),
            currentSet: CurrentSet(id: 1, input: nil),
            input: nil,
            widths: widths
        )
        
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
