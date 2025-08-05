import SwiftUI

struct RestSelectionView: View {
    let onSelectDuration: (TimeInterval) -> Void
    let onCancel: () -> Void
    let namespace: Namespace.ID
    
    @State private var selectedDuration: TimeInterval?
    
    private let durations: [(String, TimeInterval)] = [
        ("30 sec", 30),
        ("1 min", 60),
        ("2 min", 120),
        ("3 min", 180)
    ]
    
    var body: some View {
        StripView {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(durations, id: \.0) { duration in
                        GeoButtonView(
                            type: .text(duration.0),
                            variant: .outline,
                            width: 45,
                            action: {
                                selectedDuration = duration.1
                                onSelectDuration(duration.1)
                            },
                            geoID: "option\(duration.1)",
                            namespace: namespace
                        )
                        .matchedGeometryEffect(id: selectedDuration == duration.1 ? "text-left" : "restOption\(duration.1)" , in: namespace, properties: [.position])
                        .matchedGeometryEffect(id: selectedDuration == duration.1 ? "button-left" : "restOption\(duration.1)" , in: namespace, properties: [.position])
                    }
                }
            }
            .matchedGeometryEffect(id: selectedDuration == nil ? "text-left" : "hstack", in: namespace, properties: [.position])
            .matchedGeometryEffect(id: selectedDuration == nil ? "button-left" : "scrollview", in: namespace)
            
            GeoButtonView(
                type: .icon("xmark"),
                variant: .white,
                action: onCancel,
                geoID: "right",
                namespace: namespace
            )
        }
    }
}

#Preview {
    @Previewable @Namespace var namespace
    
    RestSelectionView(
        onSelectDuration: { duration in
            print("Selected duration: \(duration) seconds")
        },
        onCancel: {
            print("Cancel tapped")
        },
        namespace: namespace
    )
    .padding()
    .background(.black)
}
