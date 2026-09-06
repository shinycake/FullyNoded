import SwiftUI

struct FNUIGalleryView: View {
    enum Screen: String, CaseIterable, Identifiable {
        case home, activity, send, receive, settings
        var id: String { rawValue }

        @ViewBuilder
        var content: some View {
            let model = FNAppModel()
            switch self {
            case .home: FNHomeView(model: model)
            case .activity: FNActivityView(model: model)
            case .send: FNSendView(model: model)
            case .receive: FNReceiveView(model: model)
            case .settings: FNSettingsView(model: model)
            }
        }
    }

    @State private var selection: Screen = .home

    var body: some View {
        TabView(selection: $selection) {
            ForEach(Screen.allCases) { screen in
                screen.content
                    .tag(screen)
                    .accessibilityIdentifier("gallery.\(screen.rawValue)")
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .tint(FNTheme.accent)
    }
}

#Preview("Gallery") { FNUIGalleryView() }
#Preview("Home") { FNHomeView(model: FNAppModel()) }
#Preview("Activity") { FNActivityView(model: FNAppModel()) }
#Preview("Send") { FNSendView(model: FNAppModel()) }
#Preview("Receive") { FNReceiveView(model: FNAppModel()) }
#Preview("Settings") { FNSettingsView(model: FNAppModel()) }
