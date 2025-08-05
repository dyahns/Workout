import SwiftUI

struct RestCountdownView: View {
    let timeRemaining: TimeInterval
    let timeTotal: TimeInterval
    let onSkip: () -> Void
    let namespace: Namespace.ID
    
    var body: some View {
        StripView {
            GeoButtonView(
                type: .text(formatTime(timeRemaining)),
                variant: .outline,
                width: 40,
                action: nil,
                geoID: "left",
                namespace: namespace
            )
  
            ProgressView(value: timeTotal - timeRemaining, total: timeTotal)
                .frame(maxWidth: .infinity)
  
            GeoButtonView(
                type: .text("Skip"),
                variant: .white,
                action: onSkip,
                geoID: "right",
                namespace: namespace
            )
        }
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    @Previewable @Namespace var namespace
    
    RestCountdownView(
        timeRemaining: .leastNormalMagnitude / 2,
        timeTotal: .leastNormalMagnitude,
        onSkip: {
            print("Skip tapped")
        },
        namespace: namespace
    )
    .padding()
    .background(.black)
}
