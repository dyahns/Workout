import SwiftUI

struct ActiveStateView: View {
    let currentTime: String
    let onTimerTap: () -> Void
    let onFinish: () -> Void
    let namespace: Namespace.ID
    
    @State private var buttonsVisible = false

    var body: some View {
        StripView {
            ZStack {
                HStack {
                    if buttonsVisible {
                        GeoButtonView(
                            type: .text("Finish"),
                            variant: .green,
                            action: onFinish,
                            geoID: "left",
                            namespace: namespace
                        )
                        .transition(.scale)
                    }
                    
                    Spacer()
                    
                    if buttonsVisible {
                        GeoButtonView(
                            type: .icon("timer"),
                            variant: .white,
                            action: onTimerTap,
                            geoID: "right",
                            namespace: namespace
                        )
                        .transition(.scale)
                    }
                }
                
                if buttonsVisible {
                    Text(currentTime)
                        .frame(maxWidth: .infinity)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .transition(.scale)
                }
            }
        }
        .onAppear {
            buttonsVisible = false

            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                buttonsVisible = true
            }
        }
    }
}

#Preview {
    @Previewable @Namespace var namespace
    
    ActiveStateView(
        currentTime: "0:02",
        onTimerTap: { },
        onFinish: {
            print("Finish tapped")
        },
        namespace: namespace
    )
    .padding()
    .background(.black)
}
