import SwiftUI

@main
struct FNGlassGalleryApp: App {
    var body: some Scene {
        WindowGroup {
            FNUIGalleryView()
                .preferredColorScheme(.dark)
        }
    }
}
