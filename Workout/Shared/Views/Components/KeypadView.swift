import SwiftUI

struct KeypadView: View {
    let field: CurrentSet.InputField
    let onNumberTap: (String) -> Void
    let onDeleteTap: () -> Void
    let onNext: () -> Void
    let onCancel: () -> Void
    let namespace: Namespace.ID
    
    private let numbers = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"]
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(numbers.flatMap { $0 }, id: \.self) { number in
                    Button(action: {
                        if number == "⌫" {
                            onDeleteTap()
                        } else if number == "." && field == .reps {
                            return
                        } else {
                            onNumberTap(number)
                        }
                    }) {
                        Text(number)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                    }
                    .disabled(number == "." && field == .reps)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            HStack {
                Color.clear.frame(width: 44, height: 44)
                Spacer()
                
                GeoButtonView(
                    type: .text("Next"),
                    variant: .white,
                    width: 110,
                    action: onNext,
                    geoID: "left",
                    namespace: namespace
                )
                
                Spacer()
                GeoButtonView(
                    type: .icon("timer"),
                    variant: .white,
                    action: onCancel,
                    geoID: "right",
                    namespace: namespace
                )
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 28)
        }
    }
}

#Preview {
    @Previewable @Namespace var namespace
    
    KeypadView(
        field: .weight,
        onNumberTap: { number in
            print("Number tapped: \(number)")
        },
        onDeleteTap: {
            print("Delete tapped")
        },
        onNext: {
            print("Next tapped")
        },
        onCancel: {
            print("Cancel tapped")
        },
        namespace: namespace
    )
    .padding()
    .background(.black)
}
