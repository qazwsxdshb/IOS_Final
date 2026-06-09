import SwiftUI
import SwiftData

@main
struct NumberAdventureKingApp: App {
    @State private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authManager)
                .modelContainer(for: [PlayerProfile.self, GameRecord.self, Achievement.self])
        }
    }
}
