import SwiftUI

struct FNReceiveView: View {
    @Bindable var model: FNAppModel

    /// Glass shell uses demo snapshot data until live receive addresses are wired.
    private var isDemoAddress: Bool {
        model.receiveAddress == FNLaunchFlags.demoReceiveAddress
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    FNDemoBanner(text: "Demo receive address — not a live invoice")
                        .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 0, trailing: 20))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                Section {
                    VStack(spacing: 20) {
                        ZStack(alignment: .topTrailing) {
                            FNQRCodeView(payload: model.receiveAddress)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 8)
                                .opacity(0.55)

                            Text("DEMO")
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.orange.gradient, in: Capsule())
                                .foregroundStyle(.black)
                                .padding(12)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Demo QR code, not a live receive address")

                        Text(model.receiveAddress)
                            .font(.fnMono(.footnote))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .textSelection(isDemoAddress ? .disabled : .enabled)

                        HStack(spacing: 12) {
                            Button { } label: {
                                Label("Copy", systemImage: "doc.on.doc")
                                    .frame(maxWidth: .infinity)
                            }
                            .fnGlassButton(prominent: true)
                            .disabled(true)
                            .accessibilityLabel("Copy disabled for demo address")

                            Button { } label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                                    .frame(maxWidth: .infinity)
                            }
                            .fnGlassButton()
                            .disabled(true)
                            .accessibilityLabel("Share disabled for demo address")
                        }
                        .padding(.bottom, 8)

                        Text("Copy and Share stay disabled until this screen uses a live wallet address.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                Section("Address Details") {
                    LabeledContent("Type", value: "Native SegWit (demo)")
                    LabeledContent("Derivation", value: "m/84'/0'/0'/0/17")
                    LabeledContent("Wallet", value: model.wallet.name)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Receive")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview("Receive") { FNReceiveView(model: FNAppModel()) }
