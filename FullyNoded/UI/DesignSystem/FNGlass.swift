import SwiftUI
import UIKit

// MARK: - Availability

enum FNGlassAvailability {
    /// Compile-time: Swift 6.2+ ships Liquid Glass symbols (Xcode 26).
    static var compilerSupportsGlass: Bool {
        #if compiler(>=6.2)
        true
        #else
        false
        #endif
    }
}

// MARK: - Container

/// Morphing / shared glass space on iOS 26; passthrough otherwise.
struct FNGlassContainer<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        if #available(iOS 26.0, *) {
            #if compiler(>=6.2)
            GlassEffectContainer { content() }
            #else
            content()
            #endif
        } else {
            content()
        }
    }
}

// MARK: - Selective glass surface

struct FNSelectiveGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = FNTheme.radiusM
    var interactive: Bool = false

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            #if compiler(>=6.2)
            if interactive {
                content.glassEffect(
                    .regular.interactive(),
                    in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                )
            } else {
                content.glassEffect(
                    .regular,
                    in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                )
            }
            #else
            materialFallback(content)
            #endif
        } else {
            materialFallback(content)
        }
    }

    @ViewBuilder
    private func materialFallback(_ content: Content) -> some View {
        content
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
            )
    }
}

extension View {
    /// Hero / chrome glass — translucent on iOS 26, material card otherwise.
    func fnSelectiveGlass(cornerRadius: CGFloat = FNTheme.radiusM, interactive: Bool = false) -> some View {
        modifier(FNSelectiveGlassModifier(cornerRadius: cornerRadius, interactive: interactive))
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

/// Padded glass card for balance / node / QR / fee heroes.
struct FNGlassCard<Content: View>: View {
    var padding: CGFloat
    var cornerRadius: CGFloat
    var interactive: Bool
    @ViewBuilder var content: () -> Content

    init(
        padding: CGFloat = 20,
        cornerRadius: CGFloat = FNTheme.radiusL,
        interactive: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.interactive = interactive
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fnSelectiveGlass(cornerRadius: cornerRadius, interactive: interactive)
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
                    .fill(prominent ? AnyShapeStyle(FNTheme.accent) : AnyShapeStyle(.regularMaterial))
            }
            .overlay {
                if !prominent {
                    Capsule(style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.1), lineWidth: 0.5)
                }
            }
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
