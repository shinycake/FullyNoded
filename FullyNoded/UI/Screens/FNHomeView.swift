import SwiftUI

struct FNHomeView: View {
    @Bindable var model: FNAppModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    FNDemoBanner(text: "Demo balances & node — not your live wallet")
                        .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 0, trailing: 20))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                Section {
                    balanceBlock
                        .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 8, trailing: 20))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                Section {
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
                    .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 12, trailing: 20))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                Section("Node") {
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

                Section("Recent") {
                    ForEach(Array(model.transactions.prefix(3))) { tx in
                        FNTransactionRow(tx: tx)
                    }
                    Button { model.selectedTab = .activity } label: {
                        Text("See All Activity")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Fully Noded")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { } label: { Image(systemName: "arrow.clockwise") }
                        .accessibilityLabel("Refresh")
                }
            }
        }
    }

    private var balanceBlock: some View {
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Balance \(model.wallet.balanceBTCString) bitcoin, \(model.wallet.balanceFiatString)")
    }
}

#Preview("Home") { FNHomeView(model: FNAppModel()) }
