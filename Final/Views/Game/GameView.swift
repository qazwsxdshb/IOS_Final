import SwiftUI
import SwiftData

struct GameView: View {
    @Bindable var gameVM: GameViewModel
    var profile: PlayerProfile?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var showGuessInput = false
    @State private var showHintInput = false
    @State private var hintQuestion = ""
    @State private var hintAnswer = ""
    @State private var isLoadingHint = false
    @State private var navigateToAnalysis = false
    @State private var showForfeitConfirm = false
    @State private var showInsufficientCoins = false
    @State private var feedbackMessage: String? = nil
    @State private var savedRecord: GameRecord? = nil

    private let aiService = AIService()

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                // Navigation bar
                gameNavBar

                ScrollView {
                    VStack(spacing: 20) {
                        // Coin & stats row
                        statsRow

                        // Hidden number blocks
                        hiddenBlocksRow

                        // Clues purchased so far
                        if !gameVM.purchasedClues.isEmpty {
                            clueLogSection
                        }

                        // Guess history
                        if !gameVM.guessList.isEmpty {
                            guessHistorySection
                        }

                        // AI Hint section
                        aiHintSection

                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }

                // Bottom action buttons
                actionButtonBar
            }
        }
        .navigationBarHidden(true)
        // Guess input sheet
        .sheet(isPresented: $showGuessInput) {
            GuessInputSheet(gameVM: gameVM, profile: profile) { result in
                handleGuessResult(result)
            }
            .presentationDetents([.height(320)])
        }
        // Clue picker sheet
        .sheet(isPresented: $gameVM.showCluePicker) {
            CluePickerSheet(gameVM: gameVM)
                .presentationDetents([.medium])
                .interactiveDismissDisabled(true)
        }
        // AI Hint sheet
        .sheet(isPresented: $showHintInput) {
            AIHintSheet(
                gameVM: gameVM,
                aiService: aiService,
                question: $hintQuestion,
                answer: $hintAnswer,
                isLoading: $isLoadingHint
            )
            .presentationDetents([.medium, .large])
        }
        // Forfeit confirmation
        .confirmationDialog("確定要放棄這局嗎？", isPresented: $showForfeitConfirm, titleVisibility: .visible) {
            Button("放棄並查看答案", role: .destructive) { handleForfeit() }
            Button("繼續挑戰", role: .cancel) {}
        }
        // Insufficient coins
        .alert("金幣不足", isPresented: $showInsufficientCoins) {
            Button("確定", role: .cancel) {}
        } message: {
            Text("你的金幣不足以執行此操作。")
        }
        // Navigate to analysis
        .navigationDestination(isPresented: $navigateToAnalysis) {
            if let record = savedRecord {
                AnalysisView(record: record)
            }
        }
    }

    // MARK: - Sub-views

    private var gameNavBar: some View {
        HStack {
            Button { showForfeitConfirm = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: "xmark.circle.fill")
                    Text("放棄")
                }
                .foregroundColor(.red.opacity(0.85))
                .font(.system(size: 15, weight: .semibold))
            }
            Spacer()
            Text("數字探索者")
                .font(.headline)
                .foregroundColor(.white)
            Spacer()
            // Spacer for balance
            Text("放棄").opacity(0)
                .font(.system(size: 15, weight: .semibold))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatChip(icon: "dollarsign.circle.fill", color: .yellow,
                     value: "\(profile?.coinBalance ?? 0)")
            StatChip(icon: "arrow.counterclockwise.circle.fill", color: .orange,
                     value: "猜 \(gameVM.guessCount) 次")
            StatChip(icon: "lightbulb.fill", color: .cyan,
                     value: "線索 \(gameVM.purchasedClues.count) 條")
        }
    }

    private var hiddenBlocksRow: some View {
        HStack(spacing: 16) {
            ForEach(0..<3) { i in
                NumberBlock(
                    number: gameVM.revealedAnswer ? gameVM.hiddenNumbers[i] : nil,
                    colorCode: gameVM.revealedAnswer ? gameVM.hiddenColors[i] : "hidden",
                    index: i
                )
            }
        }
        .padding(.vertical, 8)
    }

    private var clueLogSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("已購買線索", systemImage: "list.bullet.clipboard")
                .font(.subheadline.bold())
                .foregroundColor(.white.opacity(0.8))

            VStack(spacing: 6) {
                ForEach(Array(gameVM.purchasedClues.enumerated()), id: \.offset) { _, clue in
                    HStack(alignment: .top, spacing: 8) {
                        ClueTypeBadge(category: clue.clueType)
                        Text(clue.clueText)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(10)
                    .background(Color.white.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    private var guessHistorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("猜測記錄", systemImage: "clock.arrow.circlepath")
                .font(.subheadline.bold())
                .foregroundColor(.white.opacity(0.8))

            VStack(spacing: 6) {
                ForEach(Array(gameVM.guessList.enumerated()), id: \.offset) { idx, guess in
                    HStack {
                        Text("第\(idx+1)次")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                            .frame(width: 40, alignment: .leading)

                        HStack(spacing: 8) {
                            ForEach(guess.numbers, id: \.self) { n in
                                Text("\(n)")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .frame(width: 34, height: 34)
                                    .background(guess.isCorrect ? Color.green.opacity(0.25)
                                                : Color.white.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .foregroundColor(.white)
                            }
                        }

                        Spacer()

                        Image(systemName: guess.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(guess.isCorrect ? .green : .red.opacity(0.7))

                        Text("-\(guess.cost)")
                            .font(.caption.monospacedDigit())
                            .foregroundColor(.orange.opacity(0.8))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    private var aiHintSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("AI 智慧提示", systemImage: "sparkle")
                .font(.subheadline.bold())
                .foregroundColor(.white.opacity(0.8))

            Button {
                showHintInput = true
            } label: {
                HStack {
                    Image(systemName: "bubble.left.and.text.bubble.right.fill")
                        .foregroundColor(.purple)
                    Text("問 AI 要推理方向…")
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.3))
                        .font(.caption)
                }
                .padding(14)
                .background(Color.white.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            if !hintAnswer.isEmpty {
                Text(hintAnswer)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(12)
                    .background(Color.purple.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var actionButtonBar: some View {
        VStack(spacing: 0) {
            Divider().background(Color.white.opacity(0.1))
            HStack(spacing: 8) {
                ActionButton(
                    title: "猜數字",
                    subtitle: "-\(gameVM.nextGuessCost)",
                    icon: "keyboard.fill",
                    color: .yellow
                ) { showGuessInput = true }

                ActionButton(
                    title: "數字線索",
                    subtitle: "-\(gameVM.nextClueCost(for: .number))",
                    icon: "number.circle.fill",
                    color: .cyan
                ) { buyClue(.number) }

                ActionButton(
                    title: "顏色線索",
                    subtitle: "-\(gameVM.nextClueCost(for: .color))",
                    icon: "paintpalette.fill",
                    color: .mint
                ) { buyClue(.color) }

                ActionButton(
                    title: "隨機線索",
                    subtitle: "-\(gameVM.randomClueCost)",
                    icon: "shuffle.circle.fill",
                    color: .orange
                ) { buyClue(.random) }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Color(red: 0.05, green: 0.08, blue: 0.2))
        }
    }

    // MARK: - Actions

    private func buyClue(_ category: ClueCategory) {
        guard var coins = profile?.coinBalance else { return }
        let success: Bool
        switch category {
        case .number: success = gameVM.beginClueDraw(category: .number, playerCoins: &coins)
        case .color:  success = gameVM.beginClueDraw(category: .color, playerCoins: &coins)
        case .random: success = gameVM.beginRandomClueDraw(playerCoins: &coins)
        }
        if success { profile?.coinBalance = coins }
        else { showInsufficientCoins = true }
    }

    private func handleGuessResult(_ result: GameViewModel.GuessResult) {
        switch result {
        case .correct:
            saveGameRecord()
            navigateToAnalysis = true
        case .wrong:
            break
        case .insufficientCoins(_):
            showInsufficientCoins = true
        }
    }

    private func handleForfeit() {
        gameVM.forfeit()
        saveGameRecord()
        navigateToAnalysis = true
    }

    private func saveGameRecord() {
        let record = GameRecord(hiddenNumbers: gameVM.hiddenNumbers,
                                hiddenColors: gameVM.hiddenColors)
        record.guessList = gameVM.guessList
        record.cluesPurchased = gameVM.purchasedClues
        record.result = gameVM.gameResult
        record.finalCoinChange = -(gameVM.totalSpent) + (gameVM.gameResult == .win ? 5000 : 0)
        modelContext.insert(record)
        savedRecord = record
        profile?.totalGamesPlayed += 1
        if gameVM.gameResult == .win { profile?.totalWins += 1 }
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.05, green: 0.12, blue: 0.35),
                     Color(red: 0.02, green: 0.05, blue: 0.15)],
            startPoint: .top, endPoint: .bottom
        )
    }
}

// MARK: - Number Block
struct NumberBlock: View {
    let number: Int?
    let colorCode: String
    let index: Int

    var blockColor: Color {
        switch colorCode {
        case "yellow": return Color(red: 0.98, green: 0.76, blue: 0.12)
        case "green":  return Color(red: 0.18, green: 0.78, blue: 0.42)
        case "blue":   return Color(red: 0.26, green: 0.52, blue: 0.96)
        default:       return Color.white.opacity(0.12)
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(blockColor)
                .frame(width: 88, height: 100)
                .shadow(color: blockColor.opacity(0.4), radius: 10, y: 4)

            if let n = number {
                Text("\(n)")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            } else {
                Image(systemName: "questionmark")
                    .font(.system(size: 38, weight: .black))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: number)
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(color.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stat Chip
struct StatChip: View {
    let icon: String
    let color: Color
    let value: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon).foregroundColor(color).font(.caption)
            Text(value).font(.system(size: 13, weight: .semibold, design: .rounded)).foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Clue Type Badge
struct ClueTypeBadge: View {
    let category: ClueCategory
    var label: String {
        switch category {
        case .number: return "數"
        case .color:  return "色"
        case .random: return "隨"
        }
    }
    var color: Color {
        switch category {
        case .number: return .cyan
        case .color:  return .mint
        case .random: return .orange
        }
    }
    var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(color)
            .frame(width: 22, height: 22)
            .background(color.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
