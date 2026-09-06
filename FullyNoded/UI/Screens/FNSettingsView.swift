import SwiftUI

struct FNSettingsView: View {
    @Bindable var model: FNAppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                // Dense Settings groups use material plates (`useGlass: false`).
                // Multiple `.glassEffect` cards in one ScrollView still smash later
                // sections on iOS 26 even when glass is only a background plate.
                VStack(alignment: .leading, spacing: 28) {
                    FNGlassCard(interactive: true, useGlass: false) {
                        VStack(alignment: .leading, spacing: 12) {
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

                            Text("Off by default. Turn on and relaunch to try this SwiftUI spike. FNGlassGallery always shows demo glass. Classic UIKit stays the production shell.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    FNDemoBanner()

                    settingsGroup("Node") {
                        labeledRow {
                            Label(model.node.name, systemImage: "server.rack")
                        } value: {
                            Text(model.node.isConnected ? "Connected" : "Offline")
                                .foregroundStyle(model.node.isConnected ? Color.green : Color.secondary)
                        }
                        groupDivider()
                        labeledRow("Host", value: model.node.hostPreview)
                        groupDivider()
                        labeledRow("Network", value: model.node.network.capitalized)
                        groupDivider()
                        labeledRow("Peers", value: "\(model.node.peers)")
                        groupDivider()
                        labeledRow("Version", value: model.node.version)
                    }

                    settingsGroup("Security") {
                        labeledRow {
                            Label("App Lock", systemImage: "lock.fill")
                        } value: {
                            Text("Demo").foregroundStyle(.tertiary)
                        }
                        groupDivider()
                        labeledRow {
                            Label("Tor V3 Auth", systemImage: "key.fill")
                        } value: {
                            Text("Demo").foregroundStyle(.tertiary)
                        }
                        groupDivider()
                        labeledRow {
                            Label("Signers", systemImage: "signature")
                        } value: {
                            Text("Demo").foregroundStyle(.tertiary)
                        }
                        Text("Demo placeholders — not linked to classic Security Center yet.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 4)
                    }

                    settingsGroup("Wallet") {
                        labeledRow("Active", value: model.wallet.name)
                        groupDivider()
                        labeledRow("Currency", value: model.wallet.fiatCode)
                        groupDivider()
                        labeledRow("Type", value: model.wallet.typeLabel)
                    }

                    settingsGroup("About") {
                        labeledRow("Interface", value: "SwiftUI design spike")
                        groupDivider()
                        labeledRow("Default shell", value: "Classic UIKit")
                        groupDivider()
                        labeledRow("Minimum iOS", value: "18.0")
                        groupDivider()
                        labeledRow("Liquid Glass APIs", value: "iOS 26+ (gated)")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 140) // clear floating glass tab bar
            }
            .background {
                LinearGradient(
                    colors: [Color.orange.opacity(0.14), Color.clear, Color.cyan.opacity(0.10)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    @ViewBuilder
    private func settingsGroup<Content: View>(
        _ title: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.leading, 4)

            // Material-only: avoids iOS 26 multi-glass ScrollView smash.
            FNGlassCard(padding: 16, cornerRadius: FNTheme.radiusM, useGlass: false) {
                VStack(alignment: .leading, spacing: 12) {
                    content()
                }
            }
        }
    }

    private func groupDivider() -> some View {
        Divider().opacity(0.35)
    }

    private func labeledRow(_ title: String, value: String) -> some View {
        labeledRow {
            Text(title)
        } value: {
            Text(value)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }

    private func labeledRow<L: View, V: View>(
        @ViewBuilder label: () -> L,
        @ViewBuilder value: () -> V
    ) -> some View {
        HStack(alignment: .firstTextBaseline) {
            label()
            Spacer(minLength: 12)
            value()
        }
        .frame(maxWidth: .infinity, minHeight: 28, alignment: .leading)
    }
}

#Preview("Settings") { FNSettingsView(model: FNAppModel()) }
