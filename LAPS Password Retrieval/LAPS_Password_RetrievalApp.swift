import SwiftUI

@main
struct JamfLAPSUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 900, minHeight: 700)
        }
        .windowResizability(.contentSize)
    }
}
