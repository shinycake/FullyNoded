import SwiftUI

@main
struct FNGlassGalleryApp: App {
    init() {
        Self.ingestLaunchArguments()
    }

    var body: some Scene {
        WindowGroup {
            // Real tab shell so iOS 26 Liquid Glass tab chrome is visible in screenshots.
            FNGlassRootView()
                .preferredColorScheme(.dark)
                .onAppear(perform: Self.applyGalleryScreenSelection)
        }
    }

    /// `-FNGalleryScreen home|activity|send|receive|settings`
    private static func ingestLaunchArguments() {
        let args = ProcessInfo.processInfo.arguments
        if let idx = args.firstIndex(of: "-FNGalleryScreen") {
            let next = args.index(after: idx)
            if next < args.endIndex {
                UserDefaults.standard.set(args[next].lowercased(), forKey: "FNGalleryScreen")
            }
        }
    }

    private static func applyGalleryScreenSelection() {
        guard let raw = UserDefaults.standard.string(forKey: "FNGalleryScreen")?.lowercased() else { return }
        let tab: FNTab?
        switch raw {
        case "home": tab = .home
        case "activity": tab = .activity
        case "send": tab = .send
        case "receive": tab = .receive
        case "settings", "settingscontact", "contact": tab = .settings
        default: tab = nil
        }
        if let tab {
            FNAppModel.shared.selectedTab = tab
        }
    }
}
