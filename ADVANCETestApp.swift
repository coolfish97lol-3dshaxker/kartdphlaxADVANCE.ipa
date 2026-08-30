import SwiftUI

@main
struct ADVANCETestApp: App {
    @StateObject private var hostManager = HostManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(hostManager)
        }
    }
}
