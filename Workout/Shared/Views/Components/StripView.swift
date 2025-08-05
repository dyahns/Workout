import SwiftUI

struct StripView<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        HStack(spacing: 12) {
            content
        }
        .padding(.horizontal, 10)
        .frame(height: 56)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StripView {
        Text("Stripe View")
            .foregroundStyle(.white)
    }
    .padding()
    .background(.black)
}

