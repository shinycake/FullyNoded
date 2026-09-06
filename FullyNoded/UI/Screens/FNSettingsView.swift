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
                        Label("Liquid Glass UI", systemImage: "rectangle.on.rectangle.angled")
                    }
                    .tint(FNTheme.accent)
                } footer: {
                    Text("On by default. Turn off and relaunch to use the classic UIKit interface.")
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

                Section("Security") {
                    Label("App Lock", systemImage: "lock.fill")
                    Label("Tor V3 Auth", systemImage: "key.fill")
                    Label("Signers", systemImage: "signature")
                }

                Section("Wallet") {
                    LabeledContent("Active", value: model.wallet.name)
                    LabeledContent("Currency", value: model.wallet.fiatCode)
                    LabeledContent("Type", value: model.wallet.typeLabel)
                }

                Section("About") {
                    LabeledContent("Interface", value: "SwiftUI redesign")
                    LabeledContent("Minimum iOS", value: "18.0")
                    LabeledContent("Liquid Glass", value: "iOS 26+")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview("Settings") { FNSettingsView(model: FNAppModel()) }
