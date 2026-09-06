import SwiftUI
import UIKit

/// Selective Liquid Glass for floating controls / rare chrome — not full-screen frost.

struct FNSelectiveGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = FNTheme.radiusM

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            #if compiler(>=6.2)
            content.glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            #else
            content.background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            #endif
        } else {
            content.background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

extension View {
    func fnSelectiveGlass(cornerRadius: CGFloat = FNTheme.radiusM) -> some View {
        modifier(FNSelectiveGlassModifier(cornerRadius: cornerRadius))
    }

    @ViewBuilder
    func fnGlassButton(prominent: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
            #if compiler(>=6.2)
            if prominent { self.buttonStyle(.glassProminent) }
            else { self.buttonStyle(.glass) }
            #else
            self.buttonStyle(FNCapsuleButtonStyle(prominent: prominent))
            #endif
        } else {
            self.buttonStyle(FNCapsuleButtonStyle(prominent: prominent))
        }
    }
}

struct FNCapsuleButtonStyle: ButtonStyle {
    var prominent: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .foregroundStyle(prominent ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
            .background {
                Capsule(style: .continuous)
                    .fill(prominent ? AnyShapeStyle(FNTheme.accent) : AnyShapeStyle(Color(uiColor: .tertiarySystemFill)))
            }
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
