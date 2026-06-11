import Foundation
import SwiftData

// MARK: - PlayerProfile
@Model
final class PlayerProfile {
    var userId: String
    var displayName: String
    var email: String
    var coinBalance: Int
    var totalGamesPlayed: Int
    var totalWins: Int
    // maps achievement id -> unlocked date
    var achievements: [String: Date]
    // extra tracking for achievement conditions
    var currentWinStreak: Int
    var totalCoinsEarned: Int
    var minCoinBalance: Int
    var createdAt: Date

    init(userId: String, displayName: String, email: String) {
        self.userId = userId
        self.displayName = displayName
        self.email = email
        self.coinBalance = RewardedAdConfiguration.startingCoins  // starting coins
        self.totalGamesPlayed = 0
        self.totalWins = 0
        self.achievements = [:]
        self.currentWinStreak = 0
        self.totalCoinsEarned = 0
        self.minCoinBalance = RewardedAdConfiguration.startingCoins
        self.createdAt = Date()
    }

    var winRate: Double {
        guard totalGamesPlayed > 0 else { return 0 }
        return Double(totalWins) / Double(totalGamesPlayed)
    }
}

// MARK: - GameRecord
@Model
final class GameRecord {
    var gameId: String
    var date: Date
    var hiddenNumbers: [Int]  // 3 digits [0-9]
    var hiddenColors: [String]  // ["yellow","green","blue"]
    var guessList: [GuessEntry]
    var cluesPurchased: [ClueEntry]
    var finalCoinChange: Int  // negative = net loss, positive = net gain
    var result: GameResult
    var aiAnalysis: String?  // stored after AI responds

    init(hiddenNumbers: [Int], hiddenColors: [String]) {
        self.gameId = UUID().uuidString
        self.date = Date()
        self.hiddenNumbers = hiddenNumbers
        self.hiddenColors = hiddenColors
        self.guessList = []
        self.cluesPurchased = []
        self.finalCoinChange = 0
        self.result = .inProgress
        self.aiAnalysis = nil
    }
}

// MARK: - Supporting Value Types (Codable for SwiftData storage)
struct GuessEntry: Codable {
    var numbers: [Int]  // player's guess
    var cost: Int
    var isCorrect: Bool
    var timestamp: Date
}

struct ClueEntry: Codable {
    var clueType: ClueCategory
    var clueId: String?
    var clueText: String
    var cost: Int
    var timestamp: Date

    init(clueType: ClueCategory, clueId: String? = nil, clueText: String, cost: Int, timestamp: Date) {
        self.clueType = clueType
        self.clueId = clueId
        self.clueText = clueText
        self.cost = cost
        self.timestamp = timestamp
    }
}

enum ClueCategory: String, Codable {
    case number = "number"
    case color = "color"
    case random = "random"
}

enum GameResult: String, Codable {
    case inProgress = "inProgress"
    case win = "win"
    case forfeit = "forfeit"
}
enum AIProvider: String, CaseIterable, Identifiable {
    case openai = "openai"
    case anthropic = "anthropic"
    case gemini = "gemini"
    case groq = "groq"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .openai: return "OpenAI"
        case .anthropic: return "Claude"
        case .gemini: return "Gemini"
        case .groq: return "Groq"
        }
    }

    var defaultModel: String {
        switch self {
        case .openai: return "gpt-4o"
        case .anthropic: return "claude-sonnet-4-20250514"
        case .gemini: return "gemini-2.0-flash"
        case .groq: return "llama-3.3-70b-versatile"
        }
    }

    var baseURL: String {
        switch self {
        case .openai: return "https://api.openai.com/v1/chat/completions"
        case .anthropic: return "https://api.anthropic.com/v1/messages"
        case .gemini:
            return "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions"
        case .groq: return "https://api.groq.com/openai/v1/chat/completions"
        }
    }
}

// MARK: - Achievement
@Model
final class Achievement {
    var id: String
    var name: String
    var descriptionText: String
    var iconName: String  // SF Symbol name
    var unlockedDate: Date?

    var isUnlocked: Bool { unlockedDate != nil }

    init(id: String, name: String, descriptionText: String, iconName: String) {
        self.id = id
        self.name = name
        self.descriptionText = descriptionText
        self.iconName = iconName
        self.unlockedDate = nil
    }

    // All available achievements (called once to seed)
    static let allAchievements: [Achievement] = [
        Achievement(
            id: "first_win", name: "初出茅廬", descriptionText: "首次猜對密碼", iconName: "star.fill"),
        Achievement(
            id: "no_clue_win", name: "零線索勇士", descriptionText: "不購買任何線索就猜對", iconName: "bolt.fill"),
        Achievement(
            id: "first_guess", name: "神來一筆", descriptionText: "第一次猜就猜對", iconName: "crown.fill"),
        Achievement(
            id: "play_10", name: "十局老手", descriptionText: "累計遊玩 10 局",
            iconName: "gamecontroller.fill"),
        Achievement(
            id: "play_50", name: "五十局達人", descriptionText: "累計遊玩 50 局", iconName: "trophy.fill"),
        Achievement(
            id: "win_streak_3", name: "三連勝", descriptionText: "連續贏得 3 場", iconName: "flame.fill"),
        Achievement(
            id: "broke", name: "破產邊緣", descriptionText: "金幣餘額曾低於 100 元",
            iconName: "exclamationmark.triangle.fill"),
        Achievement(
            id: "rich", name: "金幣大亨", descriptionText: "累計獲得超過 50,000 元",
            iconName: "dollarsign.circle.fill"),
    ]
}
