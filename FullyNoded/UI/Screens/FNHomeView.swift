import SwiftUI

struct FNHomeView: View {
    @Bindable var model: FNAppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    FNDemoBanner(text: "Demo balances & node — not your live wallet")
                        .padding(.horizontal, 4)

                    // Balance hero — Liquid Glass card (visible chrome)
                    FNGlassContainer {
                        FNGlassCard(interactive: true) {
                            balanceContent
                        }
                    }

                    // Primary actions — native glass buttons morph in container
                    FNGlassContainer {
                        HStack(spacing: 12) {
                            Button { model.selectedTab = .receive } label: {
                                Label("Receive", systemImage: "arrow.down")
                                    .frame(maxWidth: .infinity)
                            }
                            .fnGlassButton()

                            Button { model.selectedTab = .send } label: {
                                Label("Send", systemImage: "arrow.up")
                                    .frame(maxWidth: .infinity)
                            }
                            .fnGlassButton(prominent: true)
                        }
                    }

                    // Node status — glass surface
                    FNGlassContainer {
                        FNGlassCard(padding: 16, cornerRadius: FNTheme.radiusM, interactive: true) {
                            nodeContent
                        }
                    }

                    // Recent stays inset-grouped style (content, not chrome)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .padding(.leading, 4)

                        VStack(spacing: 0) {
                            ForEach(Array(model.transactions.prefix(3).enumerated()), id: \.element.id) { index, tx in
                                FNTransactionRow(tx: tx)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 4)
                                if index < 2 {
                                    Divider().opacity(0.35)
                                }
                            }
                            Button { model.selectedTab = .activity } label: {
                                Text("See All Activity")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 10)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .fnSelectiveGlass(cornerRadius: FNTheme.radiusM)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
            .background {
                // Soft depth so glass refraction reads in screenshots
                LinearGradient(
                    colors: [
                        Color.orange.opacity(0.18),
                        Color.clear,
                        Color.blue.opacity(0.12)
                    ],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
                .ignoresSafeArea()
            }
            .navigationTitle("Fully Noded")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { } label: { Image(systemName: "arrow.clockwise") }
                        .fnGlassButton()
                        .accessibilityLabel("Refresh")
                }
            }
        }
    }

    private var balanceContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(model.wallet.name.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .tracking(0.6)

            Text(model.wallet.balanceBTCString)
                .font(.fnBalance(.largeTitle))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())

            Text("BTC")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(FNTheme.accent)

            Text(model.wallet.balanceFiatString)
                .font(.title3)
                .foregroundStyle(.secondary)

            if model.wallet.pendingBTC > 0 {
                Text(String(format: "+%.8f pending", model.wallet.pendingBTC))
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            }

            Text(model.wallet.typeLabel)
                .font(.footnote)
                .foregroundStyle(.tertiary)
                .padding(.top, 4)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Balance \(model.wallet.balanceBTCString) bitcoin, \(model.wallet.balanceFiatString)")
    }

    private var nodeContent: some View {
        HStack(spacing: 12) {
            Image(systemName: model.node.isTor ? "shield.lefthalf.filled" : "server.rack")
                .foregroundStyle(model.node.isConnected ? Color.green : Color.secondary)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(model.node.name)
                Text("\(model.node.version) · \(model.node.blockHeight.formatted())")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(model.node.isConnected ? "Connected" : "Offline")
                .font(.subheadline)
                .foregroundStyle(model.node.isConnected ? Color.green : Color.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("Home") { FNHomeView(model: FNAppModel()) }
