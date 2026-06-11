import Foundation
import SwiftData

final class AchievementManager {
    /// Checks achievement conditions and unlocks any newly met achievements.
    /// - Returns: array of newly unlocked `Achievement` objects (for UI feedback).
    static func checkAndUnlock(profile: PlayerProfile, record: GameRecord, in context: ModelContext) -> [Achievement] {
        var newlyUnlocked: [Achievement] = []
        let already = Set(profile.achievements.keys)

        func unlock(_ id: String) {
            guard !already.contains(id) else { return }
            profile.achievements[id] = Date()
            if let ach = Achievement.allAchievements.first(where: { $0.id == id }) {
                newlyUnlocked.append(ach)
            }
        }

        // Win-related achievements
        if record.result == .win {
            unlock("first_win")
            if record.cluesPurchased.isEmpty { unlock("no_clue_win") }
            if record.guessList.count == 1, record.guessList.first?.isCorrect == true { unlock("first_guess") }
        }

        // Play count achievements
        if profile.totalGamesPlayed >= 10 { unlock("play_10") }
        if profile.totalGamesPlayed >= 50 { unlock("play_50") }

        // Streak
        if profile.currentWinStreak >= 3 { unlock("win_streak_3") }

        // Coin-related
        if profile.minCoinBalance < 100 { unlock("broke") }
        if profile.totalCoinsEarned >= 50_000 { unlock("rich") }

        // Model mutations on @Model types are tracked by SwiftData when modified inside a view-model or modelContext transaction.
        // The caller is responsible for saving/modelContext lifecycle.

        return newlyUnlocked
    }
}
