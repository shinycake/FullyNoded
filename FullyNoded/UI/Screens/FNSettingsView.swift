import SwiftUI

struct FNSettingsView: View {
    @Bindable var model: FNAppModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: Binding(
                        get: { model.useGlassShell },
                        set: {
                            model.useGlassShell = $0
                            FNLaunchFlags.useGlassShell = $0
                        }
                    )) {
                        Label("Liquid Glass UI (opt-in)", systemImage: "rectangle.on.rectangle.angled")
                    }
                    .tint(FNTheme.accent)
                } footer: {
                    Text("Off by default. Turn on and relaunch to try the SwiftUI design spike. The FNGlassGallery target always shows this UI with demo data. Classic UIKit remains the production shell.")
                }

                Section {
                    FNDemoBanner()
                }

                Section("Node") {
                    LabeledContent {
                        Text(model.node.isConnected ? "Connected" : "Offline")
                            .foregroundStyle(model.node.isConnected ? Color.green : Color.secondary)
                    } label: {
                        Label(model.node.name, systemImage: "server.rack")
                    }
                    LabeledContent("Host", value: model.node.hostPreview)
                    LabeledContent("Network", value: model.node.network.capitalized)
                    LabeledContent("Peers", value: "\(model.node.peers)")
                    LabeledContent("Version", value: model.node.version)
                }

                Section {
                    demoSecurityRow("App Lock", systemImage: "lock.fill")
                    demoSecurityRow("Tor V3 Auth", systemImage: "key.fill")
                    demoSecurityRow("Signers", systemImage: "signature")
                } header: {
                    Text("Security")
                } footer: {
                    Text("Demo placeholders — not linked to classic Security Center / Tor auth / Signers yet.")
                }

                Section("Wallet") {
                    LabeledContent("Active", value: model.wallet.name)
                    LabeledContent("Currency", value: model.wallet.fiatCode)
                    LabeledContent("Type", value: model.wallet.typeLabel)
                }

                Section("About") {
                    LabeledContent("Interface", value: "SwiftUI design spike")
                    LabeledContent("Default shell", value: "Classic UIKit")
                    LabeledContent("Minimum iOS", value: "18.0")
                    LabeledContent("Liquid Glass APIs", value: "iOS 26+ (gated)")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    /// Non-navigable placeholder — no chevron, no Button wrapping.
    private func demoSecurityRow(_ title: String, systemImage: String) -> some View {
        HStack {
            Label(title, systemImage: systemImage)
            Spacer()
            Text("Demo")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), demo placeholder, not navigable")
    }
}

#Preview("Settings") { FNSettingsView(model: FNAppModel()) }
