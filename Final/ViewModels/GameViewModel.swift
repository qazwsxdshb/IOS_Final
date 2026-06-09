import Foundation
import Observation

@Observable
final class GameViewModel {

    // MARK: - Game State
    var hiddenNumbers: [Int] = []
    var hiddenColors: [String] = []

    var guessCount: Int = 0        // n1
    var numberClueCount: Int = 0   // n (number clues bought)
    var colorClueCount: Int = 0    // n (color clues bought)

    var guessList: [GuessEntry] = []
    var purchasedClues: [ClueEntry] = []

    var gameResult: GameResult = .inProgress
    var revealedAnswer: Bool = false

    // Clue picker sheet state
    var pendingClues: [ClueDefinition] = []
    var showCluePicker: Bool = false
    var currentClueCategory: ClueCategory = .number

    // Guess input
    var guessInput: [Int] = [0, 0, 0]

    // MARK: - Cost Calculation

    /// Next guess cost: 100 × 2^(n1-1), capped at 1500
    var nextGuessCost: Int {
        let raw = 100 * Int(pow(2.0, Double(guessCount)))
        return min(raw, 1500)
    }

    /// Next number/color clue cost: 100 × 2^(n-1), capped at 750
    func nextClueCost(for category: ClueCategory) -> Int {
        let n = category == .number ? numberClueCount : colorClueCount
        let raw = 100 * Int(pow(2.0, Double(n)))
        return min(raw, 750)
    }

    /// Random clue is always 300
    let randomClueCost: Int = 300

    // MARK: - Game Lifecycle

    func startNewGame() {
        hiddenNumbers = (0..<3).map { _ in Int.random(in: 0...9) }
        hiddenColors = (0..<3).map { _ in ["yellow", "green", "blue"].randomElement()! }

        guessCount = 0
        numberClueCount = 0
        colorClueCount = 0
        guessList = []
        purchasedClues = []
        gameResult = .inProgress
        revealedAnswer = false
        guessInput = [0, 0, 0]
        pendingClues = []
        showCluePicker = false
    }

    // MARK: - Guess

    /// Returns cost deducted (negative) or 0 if insufficient
    @discardableResult
    func submitGuess(playerCoins: inout Int) -> GuessResult {
        let cost = nextGuessCost
        guard playerCoins >= cost else { return .insufficientCoins(needed: cost) }

        playerCoins -= cost
        guessCount += 1

        let isCorrect = guessInput == hiddenNumbers
        let entry = GuessEntry(
            numbers: guessInput,
            cost: cost,
            isCorrect: isCorrect,
            timestamp: Date()
        )
        guessList.append(entry)

        if isCorrect {
            playerCoins += 5000
            gameResult = .win
        }

        return isCorrect ? .correct : .wrong
    }

    enum GuessResult {
        case correct
        case wrong
        case insufficientCoins(needed: Int)
    }

    // MARK: - Clues

    /// Begins the "draw 3, pick 1" flow for number/color clue
    func beginClueDraw(category: ClueCategory, playerCoins: inout Int) -> Bool {
        let cost = nextClueCost(for: category)
        guard playerCoins >= cost else { return false }

        playerCoins -= cost
        currentClueCategory = category

        if category == .number { numberClueCount += 1 }
        else { colorClueCount += 1 }

        let pool = category == .number ? CluePool.numberClues : CluePool.colorClues
        let usedByCategory = purchasedClues
            .filter { $0.clueType == category }
            .map { $0.clueText }

        // Draw 3 unique clues not yet given to player
        let available = pool.filter { clue in
            let generated = clue.generate(hiddenNumbers, hiddenColors)
            return !usedByCategory.contains(generated)
        }
        pendingClues = Array(available.shuffled().prefix(3))
        if pendingClues.isEmpty {
            // edge case: all clues exhausted — refund and return false
            playerCoins += cost
            if category == .number { numberClueCount -= 1 } else { colorClueCount -= 1 }
            return false
        }
        showCluePicker = true
        return true
    }

    /// Random clue: draw 2, pick 1 from both pools combined
    func beginRandomClueDraw(playerCoins: inout Int) -> Bool {
        guard playerCoins >= randomClueCost else { return false }
        playerCoins -= randomClueCost
        currentClueCategory = .random

        let allPool = CluePool.numberClues + CluePool.colorClues
        let usedTexts = Set(purchasedClues.map { $0.clueText })
        let available = allPool.filter { clue in
            !usedTexts.contains(clue.generate(hiddenNumbers, hiddenColors))
        }
        pendingClues = Array(available.shuffled().prefix(2))
        if pendingClues.isEmpty {
            playerCoins += randomClueCost
            return false
        }
        showCluePicker = true
        return true
    }

    /// Player picks a clue from the pending list
    func selectClue(_ clue: ClueDefinition, playerCoins: inout Int) {
        let text = clue.generate(hiddenNumbers, hiddenColors)
        let cost: Int
        switch currentClueCategory {
        case .number: cost = nextClueCost(for: .number)   // already deducted — cost for display
        case .color:  cost = nextClueCost(for: .color)
        case .random: cost = randomClueCost
        }

        let entry = ClueEntry(
            clueType: currentClueCategory,
            clueText: text,
            cost: cost,
            timestamp: Date()
        )
        purchasedClues.append(entry)
        showCluePicker = false
        pendingClues = []
    }

    // MARK: - Forfeit

    func forfeit() {
        gameResult = .forfeit
        revealedAnswer = true
    }

    // MARK: - Net Coin Change (for saving to GameRecord)
    func computeNetCoinChange(startingBalance: Int, currentBalance: Int) -> Int {
        return currentBalance - startingBalance
    }

    // MARK: - Helpers

    var totalSpent: Int {
        let guessCosts = guessList.map { $0.cost }.reduce(0, +)
        let clueCosts = purchasedClues.map { $0.cost }.reduce(0, +)
        return guessCosts + clueCosts
    }

    var hiddenColorsDisplay: [String] {
        hiddenColors.map { code -> String in
            switch code {
            case "yellow": return "黃"
            case "green":  return "綠"
            case "blue":   return "藍"
            default:       return code
            }
        }
    }
}
