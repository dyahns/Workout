import SwiftUI

enum Variant {
    case green
    case white
    case outline
}

struct GeoButtonView: View {
    enum CapType {
        case icon(String)
        case text(String)
    }
    
    let type: CapType
    let variant: Variant
    var width: CGFloat? = .leastNonzeroMagnitude
    let action: (() -> Void)?
    let geoID: String
    let namespace: Namespace.ID
    
    private var fgColor: Color {
        switch variant {
        case .green, .outline: .white
        case .white: .black
        }
    }
    
    private var bgColor: Color {
        switch variant {
        case .green: .green
        case .outline: .black
        case .white: .white
        }
    }
    
    var body: some View {
        switch type {
        case .icon(let name):
            Button(action: { action?() }) {
                Image(systemName: name)
                    .matchedGeometryEffect(id: "text-\(geoID)", in: namespace, properties: [.position])
                    .font(.title2)
                    .foregroundColor(fgColor)
            }
            .frame(width: 40, height: 40)
            .background(for: variant, geoID: geoID, in: namespace)
            
        case .text(let caption):
            Button(action: { action?() }) {
                Text(caption)
                    .matchedGeometryEffect(id: "text-\(geoID)", in: namespace, properties: [.position])
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(fgColor)
            }
            .disabled(action == nil)
            .frame(minWidth: width)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(for: variant, geoID: geoID, in: namespace)
        }
    }
}

extension View {
    func background(for variant: Variant, geoID: String, in namespace: Namespace.ID) -> some View {
        self.background(
            Group {
                switch variant {
                case .green:
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.green)
                case .white:
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                case .outline:
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.5), lineWidth: 2)
                }
            }
            .matchedGeometryEffect(id: "button-\(geoID)", in: namespace)
        )
    }
}

#Preview {
    @Previewable @Namespace var namespace

    VStack {
        GeoButtonView(type: .text("Finish"), variant: .green, action: {}, geoID: "1", namespace: namespace)
        GeoButtonView(type: .icon("timer"), variant: .white, action: {}, geoID: "2", namespace: namespace)
        GeoButtonView(type: .text("0:00"), variant: .outline, action: {}, geoID: "3", namespace: namespace)
        GeoButtonView(type: .text("Skip"), variant: .white, action: {}, geoID: "4", namespace: namespace)
    }
    .padding()
    .background(.gray)
}
