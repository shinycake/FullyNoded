import SwiftUI

struct FNGlassRootView: View {
    @State private var model = FNAppModel.shared

    var body: some View {
        TabView(selection: $model.selectedTab) {
            FNHomeView(model: model)
                .tabItem { Label(FNTab.home.title, systemImage: FNTab.home.systemImage) }
                .tag(FNTab.home)

            FNActivityView(model: model)
                .tabItem { Label(FNTab.activity.title, systemImage: FNTab.activity.systemImage) }
                .tag(FNTab.activity)

            FNSendView(model: model)
                .tabItem { Label(FNTab.send.title, systemImage: FNTab.send.systemImage) }
                .tag(FNTab.send)

            FNReceiveView(model: model)
                .tabItem { Label(FNTab.receive.title, systemImage: FNTab.receive.systemImage) }
                .tag(FNTab.receive)

            FNSettingsView(model: model)
                .tabItem { Label(FNTab.settings.title, systemImage: FNTab.settings.systemImage) }
                .tag(FNTab.settings)
        }
        .tint(FNTheme.accent)
        // iOS 26: system TabView chrome is Liquid Glass. Clear hosting bg so it refracts.
    }
}

final class FNGlassHostingController: UIHostingController<FNGlassRootView> {
    convenience init() {
        self.init(rootView: FNGlassRootView())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}

#Preview("Root") { FNGlassRootView() }
