import SwiftUI

struct FNSendView: View {
    @Bindable var model: FNAppModel
    @FocusState private var focused: Field?
    private enum Field { case address, amount, memo }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    FNDemoBanner(text: "Demo send form — PSBT creation not wired")

                    FNGlassContainer {
                        FNGlassCard(interactive: true) {
                            VStack(alignment: .leading, spacing: 16) {
                                field(title: "Address or bitcoin: URI") {
                                    TextField("bc1…", text: $model.sendDraft.address)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .font(.fnMono(.body))
                                        .focused($focused, equals: .address)
                                }
                                Divider().opacity(0.35)
                                field(title: "Amount") {
                                    TextField("0.00000000", text: $model.sendDraft.amountBTC)
                                        .keyboardType(.decimalPad)
                                        .font(.fnMono(.title3))
                                        .focused($focused, equals: .amount)
                                }
                                Divider().opacity(0.35)
                                field(title: "Memo") {
                                    TextField("Optional", text: $model.sendDraft.memo)
                                        .focused($focused, equals: .memo)
                                }
                                Text("Demo balance \(model.wallet.balanceBTCString) BTC in \(model.wallet.name).")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    FNGlassContainer {
                        FNGlassCard(padding: 16, cornerRadius: FNTheme.radiusM, interactive: true) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Network Fee")
                                    .font(.subheadline.weight(.semibold))
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
                        }
                    }

                    FNGlassContainer {
                        VStack(spacing: 12) {
                            Button {
                                model.sendDraft.address = "bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq"
                                model.sendDraft.amountBTC = "0.01000000"
                            } label: {
                                Label("Fill Demo Recipient", systemImage: "doc.on.clipboard")
                                    .frame(maxWidth: .infinity)
                            }
                            .fnGlassButton()

                            Button { } label: {
                                Label("Create PSBT (Demo)", systemImage: "doc.badge.plus")
                                    .frame(maxWidth: .infinity)
                            }
                            .fnGlassButton(prominent: true)
                            .disabled(true)
                            .accessibilityLabel("Create PSBT disabled until wired to classic UIKit flow")

                            Text("Create PSBT stays disabled until it presents the existing UIKit PSBT flow.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
            .background {
                LinearGradient(
                    colors: [Color.orange.opacity(0.12), Color.clear, Color.blue.opacity(0.10)],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
                .ignoresSafeArea()
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

    private func field<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)
            content()
        }
    }
}

#Preview("Send") { FNSendView(model: FNAppModel()) }
