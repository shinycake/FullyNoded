import SwiftUI
import UIKit
import CoreImage.CIFilterBuiltins

/// Real QR via Core Image. Demo payloads should be watermarked by the caller.
struct FNQRCodeView: View {
    let payload: String
    var cell: CGFloat = 9

    var body: some View {
        Group {
            if let image = Self.makeQRImage(from: payload) {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: cell * 21 + 36, height: cell * 21 + 36)
                    .padding(4)
                    .background(Color(uiColor: .systemBackground), in: RoundedRectangle(cornerRadius: FNTheme.radiusM, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: FNTheme.radiusM, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                    )
            } else {
                Image(systemName: "qrcode")
                    .font(.system(size: 64))
                    .foregroundStyle(.secondary)
                    .frame(width: cell * 21 + 36, height: cell * 21 + 36)
            }
        }
        .accessibilityLabel("QR code")
        .accessibilityValue(payload)
    }

    private static func makeQRImage(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage else { return nil }
        let scaled = output.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        guard let cg = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cg)
    }
}

struct FNDemoBanner: View {
    var text: String = "Demo data — not your wallet"

    var body: some View {
        Label(text, systemImage: "exclamationmark.triangle.fill")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.orange)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel(text)
    }
}

struct FNTransactionRow: View {
    let tx: FNTransaction

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 28, alignment: .center)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(tx.memo)
                    .font(.body)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 2) {
                Text(tx.amountSigned)
                    .font(.fnMono(.subheadline))
                    .foregroundStyle(tx.kind == .sent ? Color.primary : Color.green)
                Text(tx.date, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(tx.memo), \(tx.amountSigned) bitcoin")
    }

    private var subtitle: String {
        let conf = tx.isConfirmed ? "\(tx.confirmations) confirmations" : "Unconfirmed"
        return "\(tx.addressPreview) · \(conf)"
    }

    private var icon: String {
        switch tx.kind {
        case .received: return "arrow.down.left"
        case .sent: return "arrow.up.right"
        case .selfTransfer: return "arrow.triangle.2.circlepath"
        }
    }

    private var tint: Color {
        switch tx.kind {
        case .received: return .green
        case .sent: return .secondary
        case .selfTransfer: return .blue
        }
    }
}
