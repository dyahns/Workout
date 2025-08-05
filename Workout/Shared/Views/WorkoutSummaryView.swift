import SwiftUI

struct WorkoutSummaryView: View {
    let sets: [WorkoutSet]
    
    private var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE dd MMMM"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today \(currentDateString)")
                        .font(.subheadline)
                    
                    Text("Test Complete")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Bench Press (Dumbbell)")
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.secondary)
                            .font(.title2)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        if sets.isEmpty {
                            HStack {
                                Text("No sets completed")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .italic()
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        } else {
                            ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                                HStack(spacing: 20) {
                                    Text("\(index + 1)")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .frame(width: 20, alignment: .leading)
                                    
                                    if let weight = set.weight, let reps = set.reps {
                                        Text("\(Int(weight))kg x \(reps)")
                                            .font(.body)
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                )
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
}

#Preview("With Sets") {
    let completedSets = [
        WorkoutSet(weight: 45, reps: 10, isCompleted: true),
        WorkoutSet(weight: 45, reps: 10, isCompleted: true),
        WorkoutSet(weight: 45, reps: 10, isCompleted: true)
    ]
    
    WorkoutSummaryView(sets: completedSets)
}

#Preview("Empty Sets") {
    WorkoutSummaryView(sets: [])
}
