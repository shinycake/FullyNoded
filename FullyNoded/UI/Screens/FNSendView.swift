import SwiftUI

struct FNSendView: View {
    @Bindable var model: FNAppModel
    @FocusState private var focused: Field?
    private enum Field { case address, amount, memo }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Address or bitcoin: URI", text: $model.sendDraft.address)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .font(.fnMono(.body))
                        .focused($focused, equals: .address)

                    TextField("Amount", text: $model.sendDraft.amountBTC)
                        .keyboardType(.decimalPad)
                        .font(.fnMono(.title3))
                        .focused($focused, equals: .amount)

                    TextField("Memo", text: $model.sendDraft.memo)
                        .focused($focused, equals: .memo)
                } header: {
                    Text("Payment")
                } footer: {
                    Text("Available \(model.wallet.balanceBTCString) BTC in \(model.wallet.name)")
                }

                Section("Network Fee") {
                    Stepper(value: $model.sendDraft.feeRate, in: 1...80) {
                        HStack {
                            Text("Fee rate")
                            Spacer()
                            Text("\(model.sendDraft.feeRate) sat/vB")
                                .foregroundStyle(.secondary)
                                .font(.fnMono(.body))
                        }
                    }
                }

                Section {
                    Button {
                        model.sendDraft.address = "bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq"
                        model.sendDraft.amountBTC = "0.01000000"
                    } label: {
                        Label("Fill Demo Recipient", systemImage: "doc.on.clipboard")
                    }

                    Button { focused = nil } label: {
                        Label("Create PSBT", systemImage: "doc.badge.plus")
                    }
                    .tint(FNTheme.accent)
                }
            }
            .navigationTitle("Send")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focused = nil }
                }
            }
        }
    }
}

#Preview("Send") { FNSendView(model: FNAppModel()) }
