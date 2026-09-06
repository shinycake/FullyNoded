import SwiftUI

struct FNReceiveView: View {
    @Bindable var model: FNAppModel
    @State private var copied = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 20) {
                        FNQRPlaceholder(payload: model.receiveAddress)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)

                        Text(model.receiveAddress)
                            .font(.fnMono(.footnote))
                            .multilineTextAlignment(.center)
                            .textSelection(.enabled)

                        HStack(spacing: 12) {
                            Button {
                                #if canImport(UIKit)
                                UIPasteboard.general.string = model.receiveAddress
                                #endif
                                copied = true
                                Task {
                                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                                    copied = false
                                }
                            } label: {
                                Label(copied ? "Copied" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc")
                                    .frame(maxWidth: .infinity)
                            }
                            .fnGlassButton(prominent: true)

                            ShareLink(item: model.receiveAddress) {
                                Label("Share", systemImage: "square.and.arrow.up")
                                    .frame(maxWidth: .infinity)
                            }
                            .fnGlassButton()
                        }
                        .padding(.bottom, 8)
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                Section("Address Details") {
                    LabeledContent("Type", value: "Native SegWit")
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
