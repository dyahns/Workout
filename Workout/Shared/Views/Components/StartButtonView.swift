import SwiftUI

struct StartButtonView: View {
    let onStart: () -> Void
    let namespace: Namespace.ID
    
    var body: some View {
        StripView {
            Button(action: onStart) {
                HStack {
                    Image(systemName: "play.fill")
                        .font(.title3)
                    
                    Text("Start")
                        .font(.title3)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
            }
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.1)),
                removal: .opacity.combined(with: .scale(scale: 0.1))
            ))
        }
    }
}

#Preview {
    @Previewable @Namespace var namespace

    StartButtonView (
        onStart: {
            print("Start tapped")
        },
        namespace: namespace
    )
    .padding()
    .background(.black)
}
