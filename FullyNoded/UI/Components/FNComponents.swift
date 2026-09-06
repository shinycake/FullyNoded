import SwiftUI
import UIKit

struct FNQRPlaceholder: View {
    let payload: String
    var cell: CGFloat = 9

    var body: some View {
        let cells = Self.pattern(from: payload)
        VStack(spacing: 1.5) {
            ForEach(0..<21, id: \.self) { row in
                HStack(spacing: 1.5) {
                    ForEach(0..<21, id: \.self) { col in
                        Rectangle()
                            .fill(cells[row][col] ? Color.primary : Color.clear)
                            .frame(width: cell, height: cell)
                    }
                }
            }
        }
        .padding(18)
        .background(Color(uiColor: .systemBackground), in: RoundedRectangle(cornerRadius: FNTheme.radiusM, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: FNTheme.radiusM, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .accessibilityLabel("Receive QR code")
        .accessibilityValue(payload)
    }

    private static func pattern(from seed: String) -> [[Bool]] {
        var grid = Array(repeating: Array(repeating: false, count: 21), count: 21)
        for origin in [(0, 0), (0, 14), (14, 0)] {
            for r in 0..<7 {
                for c in 0..<7 {
                    let onBorder = r == 0 || r == 6 || c == 0 || c == 6
                    let inCenter = (2...4).contains(r) && (2...4).contains(c)
                    grid[origin.0 + r][origin.1 + c] = onBorder || inCenter
                }
            }
        }
        var hash: UInt64 = 5381
        for b in seed.utf8 { hash = ((hash << 5) &+ hash) &+ UInt64(b) }
        for r in 0..<21 {
            for c in 0..<21 {
                if grid[r][c] { continue }
                if r == 6 || c == 6 { grid[r][c] = (r + c) % 2 == 0; continue }
                hash = hash &* 6364136223846793005 &+ 1
                grid[r][c] = (hash % 3) != 0
            }
        }
        return grid
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
