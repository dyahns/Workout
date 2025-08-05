import SwiftUI

struct SetListView: View {
    let sets: [WorkoutSet]
    let currentSet: CurrentSet
    let input: String?
    let onTap: () -> Void
    
    typealias SetColumnWidths = (CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)
    let widths: SetColumnWidths = (30, 70, 70, 70, 28)
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                headerView(title: "Set", minWidth: widths.0)
                headerView(title: "Previous", minWidth: widths.1)
                headerView(title: "Kg", minWidth: widths.2).frame(maxWidth: .infinity)
                headerView(title: "Reps", minWidth: widths.3).frame(maxWidth: .infinity)

                Spacer()
                    .frame(width: CGFloat(widths.4))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            
            ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                SetRowView(
                    index: index,
                    set: set,
                    currentSet: currentSet,
                    input: input,
                    widths: widths
                )
            }
        }
        .onTapGesture {
            onTap()
        }
    }
    
    private func headerView(title: String, minWidth: CGFloat) -> some View {
        Text(title)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .frame(minWidth: minWidth, alignment: .center)
    }
}

#Preview {
    let sets = [
        WorkoutSet(weight: 100, reps: 10, isCompleted: true),
        WorkoutSet(weight: 100, reps: 10),
        WorkoutSet()
    ]
    
    SetListView(
        sets: sets,
        currentSet: CurrentSet(id: 1, input: .reps),
        input: "2",
        onTap: {}
    )
    .padding()
    .background(Color.secondary.opacity(0.1))
}
