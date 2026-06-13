import SwiftUI
import SwiftData
import TipKit

@main
struct NumberAdventureKingApp: App {
    @State private var authManager = AuthManager()

    init() {
        // TipKit 初始化，開發時用 .resetDatastore 讓提示每次都顯示
        // 上線前把 .resetDatastore 那行刪掉
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])
        // 開發測試用，上線前刪除：
        // try? Tips.resetDatastore()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authManager)
                .modelContainer(for: [PlayerProfile.self, GameRecord.self, Achievement.self])
        }
    }
}
