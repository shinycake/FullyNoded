import SwiftUI

struct FNSettingsView: View {
    @Bindable var model: FNAppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                // One glass container for the page — per-section containers can morph/overlap.
                FNGlassContainer {
                    VStack(alignment: .leading, spacing: 20) {
                        FNGlassCard(interactive: true) {
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
                            }
                        }

                        FNDemoBanner()

                        sectionHeader("Node")
                        FNGlassCard(padding: 16, cornerRadius: FNTheme.radiusM) {
                            VStack(alignment: .leading, spacing: 12) {
                                LabeledContent {
                                    Text(model.node.isConnected ? "Connected" : "Offline")
                                        .foregroundStyle(model.node.isConnected ? Color.green : Color.secondary)
                                } label: {
                                    Label(model.node.name, systemImage: "server.rack")
                                }
                                Divider().opacity(0.35)
                                LabeledContent("Host", value: model.node.hostPreview)
                                Divider().opacity(0.35)
                                LabeledContent("Network", value: model.node.network.capitalized)
                                Divider().opacity(0.35)
                                LabeledContent("Peers", value: "\(model.node.peers)")
                                Divider().opacity(0.35)
                                LabeledContent("Version", value: model.node.version)
                            }
                        }

                        sectionHeader("Security")
                        FNGlassCard(padding: 16, cornerRadius: FNTheme.radiusM) {
                            VStack(alignment: .leading, spacing: 12) {
                                demoSecurityRow("App Lock", systemImage: "lock.fill")
                                Divider().opacity(0.35)
                                demoSecurityRow("Tor V3 Auth", systemImage: "key.fill")
                                Divider().opacity(0.35)
                                demoSecurityRow("Signers", systemImage: "signature")
                                Text("Demo placeholders — not linked to classic Security Center yet.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        sectionHeader("Wallet")
                        FNGlassCard(padding: 16, cornerRadius: FNTheme.radiusM) {
                            VStack(alignment: .leading, spacing: 12) {
                                LabeledContent("Active", value: model.wallet.name)
                                Divider().opacity(0.35)
                                LabeledContent("Currency", value: model.wallet.fiatCode)
                                Divider().opacity(0.35)
                                LabeledContent("Type", value: model.wallet.typeLabel)
                            }
                        }

                        sectionHeader("About")
                        FNGlassCard(padding: 16, cornerRadius: FNTheme.radiusM) {
                            VStack(alignment: .leading, spacing: 12) {
                                LabeledContent("Interface", value: "SwiftUI design spike")
                                Divider().opacity(0.35)
                                LabeledContent("Default shell", value: "Classic UIKit")
                                Divider().opacity(0.35)
                                LabeledContent("Minimum iOS", value: "18.0")
                                Divider().opacity(0.35)
                                LabeledContent("Liquid Glass APIs", value: "iOS 26+ (gated)")
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 100) // clear floating glass tab bar
                }
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

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .padding(.leading, 4)
    }

    private func demoSecurityRow(_ title: String, systemImage: String) -> some View {
        HStack {
            Label(title, systemImage: systemImage)
            Spacer(minLength: 8)
            Text("Demo")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), demo placeholder, not navigable")
    }
}

#Preview("Settings") { FNSettingsView(model: FNAppModel()) }
