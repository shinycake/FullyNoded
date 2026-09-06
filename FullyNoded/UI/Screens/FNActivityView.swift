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
            List {
                Section {
                    ForEach(filtered) { tx in
                        FNTransactionRow(tx: tx)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    model.transactions.removeAll { $0.id == tx.id }
                                } label: {
                                    Label("Hide", systemImage: "eye.slash")
                                }
                            }
                            .contextMenu {
                                Button {
                                    #if canImport(UIKit)
                                    UIPasteboard.general.string = tx.addressPreview
                                    #endif
                                } label: {
                                    Label("Copy Address Preview", systemImage: "doc.on.doc")
                                }
                            }
                    }
                } footer: {
                    Text("\(filtered.count) transactions")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $query, prompt: "Search memos or addresses")
            .overlay {
                if filtered.isEmpty {
                    ContentUnavailableView.search(text: query)
                }
            }
        }
    }
}

#Preview("Activity") { FNActivityView(model: FNAppModel()) }
