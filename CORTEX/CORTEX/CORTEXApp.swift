import SwiftUI
import Combine

@main
struct CORTEXApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .onReceive(Timer.publish(every: 10, on: .main, in: .common).autoconnect()) { _ in
                    ReviewManager.shared.addPlayTime(10)
                }
        }
    }
}
