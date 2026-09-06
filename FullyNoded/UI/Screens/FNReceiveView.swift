import SwiftUI

struct FNReceiveView: View {
    @Bindable var model: FNAppModel

    private var isDemoAddress: Bool {
        model.receiveAddress == FNLaunchFlags.demoReceiveAddress
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    FNDemoBanner(text: "Demo receive address — not a live invoice")

                    FNGlassContainer {
                        FNGlassCard(interactive: true) {
                            VStack(spacing: 20) {
                                ZStack(alignment: .topTrailing) {
                                    FNQRCodeView(payload: model.receiveAddress)
                                        .frame(maxWidth: .infinity)
                                        .opacity(0.7)

                                    Text("DEMO")
                                        .font(.caption.weight(.bold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.orange.gradient, in: Capsule())
                                        .foregroundStyle(.black)
                                        .padding(8)
                                }
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("Demo QR code, not a live receive address")

                                Group {
                                    if isDemoAddress {
                                        Text(model.receiveAddress)
                                            .font(.fnMono(.footnote))
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.center)
                                            .textSelection(.disabled)
                                    } else {
                                        Text(model.receiveAddress)
                                            .font(.fnMono(.footnote))
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.center)
                                            .textSelection(.enabled)
                                    }
                                }

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

                                Text("Copy and Share stay disabled until this screen uses a live wallet address.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Address Details")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .padding(.leading, 4)

                        VStack(spacing: 12) {
                            LabeledContent("Type", value: "Native SegWit (demo)")
                            Divider().opacity(0.35)
                            LabeledContent("Derivation", value: "m/84'/0'/0'/0/17")
                            Divider().opacity(0.35)
                            LabeledContent("Wallet", value: model.wallet.name)
                        }
                        .padding(16)
                        .fnSelectiveGlass(cornerRadius: FNTheme.radiusM)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
            .background {
                LinearGradient(
                    colors: [Color.orange.opacity(0.14), Color.clear, Color.mint.opacity(0.10)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            .navigationTitle("Receive")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview("Receive") { FNReceiveView(model: FNAppModel()) }
