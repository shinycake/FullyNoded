import SwiftUI

struct FNActivityView: View {
    @Bindable var model: FNAppModel
    @State private var query = ""

    private var filtered: [FNTransaction] {
        guard !query.isEmpty else { return model.transactions }
        return model.transactions.filter {
            $0.memo.localizedCaseInsensitiveContains(query)
                || $0.addressPreview.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    FNGlassContainer {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                            TextField("Search memos or addresses", text: $query)
                        }
                        .padding(14)
                        .fnSelectiveGlass(cornerRadius: 14, interactive: true)
                    }

                    FNGlassContainer {
                        FNGlassCard(padding: 8, cornerRadius: FNTheme.radiusM) {
                            if filtered.isEmpty {
                                ContentUnavailableView.search(text: query)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 24)
                            } else {
                                VStack(spacing: 0) {
                                    ForEach(Array(filtered.enumerated()), id: \.element.id) { index, tx in
                                        FNTransactionRow(tx: tx)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 8)
                                            .contextMenu {
                                                Button {
                                                    #if canImport(UIKit)
                                                    UIPasteboard.general.string = tx.addressPreview
                                                    #endif
                                                } label: {
                                                    Label("Copy Address Preview", systemImage: "doc.on.doc")
                                                }
                                            }
                                        if index < filtered.count - 1 {
                                            Divider().opacity(0.35)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Text("\(filtered.count) transactions")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
            .background {
                LinearGradient(
                    colors: [Color.blue.opacity(0.12), Color.clear, Color.orange.opacity(0.10)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview("Activity") { FNActivityView(model: FNAppModel()) }
