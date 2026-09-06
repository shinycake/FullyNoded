import Foundation
import SwiftUI

// Canonical redesign model API — all screens must use these names only.

@Observable
final class FNAppModel {
    var useGlassShell: Bool
    var selectedTab: FNTab = .home
    var wallet: FNWalletSnapshot
    var transactions: [FNTransaction]
    var node: FNNodeStatus
    var receiveAddress: String
    var sendDraft: FNSendDraft

    init(
        useGlassShell: Bool = FNLaunchFlags.useGlassShell,
        wallet: FNWalletSnapshot = .demo,
        transactions: [FNTransaction] = FNTransaction.demoList,
        node: FNNodeStatus = .demo,
        receiveAddress: String = FNLaunchFlags.demoReceiveAddress,
        sendDraft: FNSendDraft = .empty
    ) {
        self.useGlassShell = useGlassShell
        self.wallet = wallet
        self.transactions = transactions
        self.node = node
        self.receiveAddress = receiveAddress
        self.sendDraft = sendDraft
    }

    static let shared = FNAppModel()
}

enum FNTab: Hashable, CaseIterable, Identifiable {
    case home, activity, send, receive, settings
    var id: Self { self }

    var title: String {
        switch self {
        case .home: return "Home"
        case .activity: return "Activity"
        case .send: return "Send"
        case .receive: return "Receive"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .activity: return "list.bullet"
        case .send: return "arrow.up"
        case .receive: return "arrow.down"
        case .settings: return "gearshape"
        }
    }
}

struct FNWalletSnapshot: Hashable {
    var name: String
    var balanceBTC: Double
    var balanceFiat: Double
    var fiatCode: String
    var pendingBTC: Double
    var typeLabel: String

    var balanceBTCString: String { String(format: "%.8f", balanceBTC) }

    var balanceFiatString: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = fiatCode
        return f.string(from: NSNumber(value: balanceFiat)) ?? "$0"
    }

    static let demo = FNWalletSnapshot(
        name: "Primary",
        balanceBTC: 1.28473910,
        balanceFiat: 118_942.55,
        fiatCode: "USD",
        pendingBTC: 0.00210000,
        typeLabel: "Descriptor · SegWit"
    )
}

struct FNTransaction: Identifiable, Hashable {
    enum Kind: String { case received, sent, selfTransfer }

    var id: String
    var kind: Kind
    var amountBTC: Double
    var fiat: Double
    var confirmations: Int
    var date: Date
    var memo: String
    var addressPreview: String

    var isConfirmed: Bool { confirmations >= 1 }

    var amountSigned: String {
        (kind == .sent ? "−" : "+") + String(format: "%.8f", amountBTC)
    }

    static let demoList: [FNTransaction] = {
        let cal = Calendar.current
        let now = Date()
        return [
            FNTransaction(id: "tx1", kind: .received, amountBTC: 0.25, fiat: 23150, confirmations: 6,
                          date: cal.date(byAdding: .hour, value: -2, to: now)!,
                          memo: "Cold storage top-up", addressPreview: "bc1q…0wlh"),
            FNTransaction(id: "tx2", kind: .sent, amountBTC: 0.01542, fiat: 1427.33, confirmations: 12,
                          date: cal.date(byAdding: .day, value: -1, to: now)!,
                          memo: "Hardware wallet batch", addressPreview: "bc1p…k9m2"),
            FNTransaction(id: "tx3", kind: .received, amountBTC: 0.00421, fiat: 389.7, confirmations: 0,
                          date: cal.date(byAdding: .day, value: -2, to: now)!,
                          memo: "Pending channel open", addressPreview: "bc1q…a7fe"),
            FNTransaction(id: "tx4", kind: .sent, amountBTC: 0.1, fiat: 9260, confirmations: 48,
                          date: cal.date(byAdding: .day, value: -5, to: now)!,
                          memo: "Multisig rebalance", addressPreview: "bc1q…r4n1"),
            FNTransaction(id: "tx5", kind: .selfTransfer, amountBTC: 0.05, fiat: 4630, confirmations: 120,
                          date: cal.date(byAdding: .day, value: -12, to: now)!,
                          memo: "Consolidate UTXOs", addressPreview: "bc1q…self")
        ]
    }()
}

struct FNNodeStatus: Hashable {
    var name: String
    var hostPreview: String
    var isTor: Bool
    var isConnected: Bool
    var blockHeight: Int
    var peers: Int
    var version: String
    var network: String

    static let demo = FNNodeStatus(
        name: "Home Node",
        hostPreview: "abc…onion",
        isTor: true,
        isConnected: true,
        blockHeight: 865_421,
        peers: 12,
        version: "Bitcoin Core 28.0",
        network: "main"
    )
}

struct FNSendDraft: Hashable {
    var address: String
    var amountBTC: String
    var feeRate: Int
    var memo: String
    static let empty = FNSendDraft(address: "", amountBTC: "", feeRate: 8, memo: "")
}

enum FNLaunchFlags {
    /// Default OFF — production boots classic UIKit. Glass is gallery + explicit opt-in only.
    static var useGlassShellByDefault: Bool { false }

    /// Well-known BIP173 example used only in demo/gallery UI — never treat as a live wallet address.
    static let demoReceiveAddress = "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh"

    static var useGlassShell: Bool {
        get {
            if UserDefaults.standard.object(forKey: "fnUseGlassShell") == nil {
                return useGlassShellByDefault
            }
            return UserDefaults.standard.bool(forKey: "fnUseGlassShell")
        }
        set { UserDefaults.standard.set(newValue, forKey: "fnUseGlassShell") }
    }
}
