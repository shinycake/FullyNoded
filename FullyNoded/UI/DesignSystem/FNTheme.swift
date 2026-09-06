import SwiftUI

/// First-party tokens. Prefer semantic colors in views; accent is the only brand tint.
enum FNTheme {
    /// Prefer the app tint (system orange) so glass screens match UIKit chrome.
    static let accent = Color.accentColor
    static let radiusM: CGFloat = 14
}

extension Font {
    static func fnBalance(_ style: Font.TextStyle = .largeTitle) -> Font {
        .system(style, design: .rounded).weight(.semibold).monospacedDigit()
    }

    static func fnMono(_ style: Font.TextStyle = .body) -> Font {
        .system(style, design: .monospaced)
    }
}
