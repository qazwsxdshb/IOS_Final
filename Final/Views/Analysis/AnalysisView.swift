import SwiftUI
import SwiftData

struct AnalysisView: View {
    let record: GameRecord
    var onReturnHome: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [PlayerProfile]

    @State private var analysis: GameAnalysis? = nil
    @State private var isLoading = true
    @State private var errorMessage: String? = nil

    private let aiService = AIService()

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        // Result banner
                        resultBanner

                        // Answer reveal
                        answerRevealCard

                        // AI Analysis card
                        aiAnalysisCard

                        // Stats summary
                        statsSummaryCard
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                }

                analysisNavigationButtons
            }
        }
        .navigationBarHidden(true)
        .task { await fetchAnalysis() }
    }

    // MARK: - Sub-views

    private var analysisNavigationButtons: some View {
        VStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Text("回到遊戲畫面")
                    .font(.system(size: 17, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.white.opacity(0.12))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)

            Button {
                onReturnHome()
            } label: {
                Text("回到主選單")
                    .font(.system(size: 17, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(colors: [.yellow, .orange],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(Color(red: 0.03, green: 0.06, blue: 0.18).opacity(0.96))
    }

    private var resultBanner: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(resultColor.opacity(0.2))
                    .frame(width: 90, height: 90)
                Image(systemName: resultIcon)
                    .font(.system(size: 42))
                    .foregroundColor(resultColor)
            }
            Text(resultTitle)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(resultSubtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var answerRevealCard: some View {
        VStack(spacing: 14) {
            Text("正確答案")
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 14) {
                ForEach(0..<3) { i in
                    NumberBlock(
                        number: record.hiddenNumbers[i],
                        colorCode: record.hiddenColors[i],
                        index: i
                    )
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 20)
    }

    private var aiAnalysisCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("AI 局後分析", systemImage: "brain.head.profile")
                .font(.headline)
                .foregroundColor(.white)

            if isLoading {
                HStack(spacing: 12) {
                    ProgressView().tint(.purple)
                    Text("AI 正在分析你的本局表現…")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.purple.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red.opacity(0.7))
                    .font(.caption)

            } else if let a = analysis {
                // Score meter
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("策略評分")
                            .font(.caption.bold())
                            .foregroundColor(.white.opacity(0.55))
                        Spacer()
                        Text("\(a.strategyScore) / 10")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(scoreColor(a.strategyScore))
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.1)).frame(height: 8)
                            Capsule()
                                .fill(scoreColor(a.strategyScore))
                                .frame(width: geo.size.width * CGFloat(a.strategyScore) / 10.0,
                                       height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.bottom, 4)

                // Summary
                Text(a.summary)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(12)
                    .background(Color.purple.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                // Key decisions
                if !a.keyDecisions.isEmpty {
                    analysisListSection(title: "關鍵決策點", icon: "flag.fill",
                                        color: .cyan, items: a.keyDecisions)
                }

                // Improvements
                if !a.improvements.isEmpty {
                    analysisListSection(title: "改進建議", icon: "lightbulb.fill",
                                        color: .yellow, items: a.improvements)
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 20)
    }

    private func analysisListSection(title: String, icon: String, color: Color, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.caption.bold())
                .foregroundColor(color)
            ForEach(Array(items.enumerated()), id: \.offset) { i, item in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(i+1).")
                        .font(.caption.bold())
                        .foregroundColor(color.opacity(0.7))
                        .frame(width: 18, alignment: .trailing)
                    Text(item)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var statsSummaryCard: some View {
        HStack(spacing: 0) {
            StatSummaryItem(label: "猜測次數", value: "\(record.guessList.count) 次",
                            icon: "arrow.counterclockwise", color: .orange)
            Divider().frame(height: 40).background(Color.white.opacity(0.15))
            StatSummaryItem(label: "使用線索", value: "\(record.cluesPurchased.count) 條",
                            icon: "lightbulb", color: .cyan)
            Divider().frame(height: 40).background(Color.white.opacity(0.15))
            StatSummaryItem(label: "金幣變化", value: "\(record.finalCoinChange > 0 ? "+" : "")\(record.finalCoinChange)",
                            icon: "dollarsign.circle", color: record.finalCoinChange >= 0 ? .green : .red)
        }
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal, 20)
    }

    // MARK: - Helpers

    private var resultColor: Color {
        record.result == .win ? .yellow : .red.opacity(0.7)
    }
    private var resultIcon: String {
        record.result == .win ? "crown.fill" : "flag.fill"
    }
    private var resultTitle: String {
        record.result == .win ? "恭喜猜對！" : "挑戰結束"
    }
    private var resultSubtitle: String {
        record.result == .win
            ? "你成功破解了密碼，獲得 5,000 元！"
            : "答案已揭曉，下次一定可以！"
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 8...10: return .green
        case 5...7:  return .yellow
        default:     return .red.opacity(0.8)
        }
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.05, green: 0.12, blue: 0.35),
                     Color(red: 0.02, green: 0.05, blue: 0.15)],
            startPoint: .top, endPoint: .bottom
        )
    }

    // MARK: - AI Fetch
    private func fetchAnalysis() async {
        // Check if already cached
        if let cached = record.aiAnalysis,
           let data = cached.data(using: .utf8),
           let parsed = try? JSONDecoder().decode(GameAnalysis.self, from: data) {
            analysis = parsed
            isLoading = false
            return
        }

        let totalSpent = record.guessList.map { $0.cost }.reduce(0, +)
                       + record.cluesPurchased.map { $0.cost }.reduce(0, +)

        let req = AIAnalysisRequest(
            hiddenNumbers: record.hiddenNumbers,
            hiddenColors: record.hiddenColors,
            guessList: record.guessList,
            cluesPurchased: record.cluesPurchased,
            result: record.result,
            totalSpent: totalSpent
        )

        do {
            let result = try await aiService.fetchGameAnalysis(req)
            analysis = result
            // Cache to SwiftData
            if let encoded = try? JSONEncoder().encode(result),
               let str = String(data: encoded, encoding: .utf8) {
                record.aiAnalysis = str
            }
        } catch {
            errorMessage = "AI 分析載入失敗：\(error.localizedDescription)"
        }
        isLoading = false
    }
}

// MARK: - Stat Summary Item
struct StatSummaryItem: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon).foregroundColor(color).font(.title3)
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
    }
}
