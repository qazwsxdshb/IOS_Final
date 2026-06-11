import SwiftData
import SwiftUI

struct ProfileView: View {
    @Environment(AuthManager.self) var authManager
    @Query(sort: \GameRecord.date, order: .reverse) private var records: [GameRecord]
    @Query private var profiles: [PlayerProfile]

    @AppStorage("ai_provider") private var aiProvider: String = "openai"
    @AppStorage("ai_api_key") private var aiAPIKey: String = ""
    @AppStorage("ai_model") private var aiModel: String = ""
    @State private var showAPIKey: Bool = false

    private var profile: PlayerProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        profileHeader
                        statsGrid
                        achievementSection
                        apiKeySection

                        if !records.isEmpty {
                            recentGamesSection
                        }

                        Button {
                            authManager.signOut()
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("登出")
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.red.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("我的紀錄")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(
                Color(red: 0.05, green: 0.12, blue: 0.35),
                for: .navigationBar
            )
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    // MARK: - Sub-views

    private var profileHeader: some View {
        let user = authManager.currentUser

        return HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.26, green: 0.52, blue: 0.96).opacity(0.3))
                    .frame(width: 64, height: 64)
                Text(String(user?.displayName.prefix(1) ?? "?"))
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(user?.displayName ?? "玩家")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                Text(user?.email ?? "")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            VStack(spacing: 2) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                Text("\(profile?.coinBalance ?? RewardedAdConfiguration.startingCoins)")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundColor(.yellow)
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal, 20)
    }

    private var statsGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12
        ) {
            ProfileStatCard(
                label: "遊玩場次", value: "\(records.count)",
                icon: "gamecontroller.fill", color: .blue)
            ProfileStatCard(
                label: "勝場數",
                value: "\(records.filter { $0.result == .win }.count)",
                icon: "trophy.fill", color: .yellow)
            ProfileStatCard(
                label: "勝率", value: winRateText,
                icon: "chart.pie.fill", color: .green)
        }
        .padding(.horizontal, 20)
    }

    private var winRateText: String {
        guard !records.isEmpty else { return "0%" }
        let rate = Double(records.filter { $0.result == .win }.count) / Double(records.count)
        return String(format: "%.0f%%", rate * 100)
    }

    private var achievementSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("成就徽章", systemImage: "medal.fill")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Achievement.allAchievements) { ach in
                        let unlocked = profile?.achievements.contains(ach.id) ?? false
                        AchievementBadge(achievement: ach, isUnlocked: unlocked)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var apiKeySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("AI 模型設定", systemImage: "cpu.fill")
                .font(.headline)
                .foregroundColor(.white)

            VStack(spacing: 12) {
                // Provider 選擇
                VStack(alignment: .leading, spacing: 8) {
                    Text("選擇 AI Provider")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.5))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(AIProvider.allCases) { provider in
                                Button {
                                    aiProvider = provider.rawValue
                                    aiModel = provider.defaultModel
                                } label: {
                                    Text(provider.displayName)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(
                                            aiProvider == provider.rawValue
                                                ? .black : .white.opacity(0.6)
                                        )
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            aiProvider == provider.rawValue
                                                ? Color.yellow : Color.white.opacity(0.08)
                                        )
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                // Model 名稱
                VStack(alignment: .leading, spacing: 8) {
                    Text("Model 名稱")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.5))

                    TextField(
                        AIProvider(rawValue: aiProvider)?.defaultModel ?? "模型名稱",
                        text: $aiModel
                    )
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // API Key
                VStack(alignment: .leading, spacing: 8) {
                    Text("API Key")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.5))

                    HStack(spacing: 10) {
                        Group {
                            if showAPIKey {
                                TextField("貼上你的 API Key", text: $aiAPIKey)
                            } else {
                                SecureField("貼上你的 API Key", text: $aiAPIKey)
                            }
                        }
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        Button {
                            showAPIKey.toggle()
                        } label: {
                            Image(systemName: showAPIKey ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.white.opacity(0.4))
                                .font(.system(size: 16))
                        }
                        .buttonStyle(.plain)
                    }

                    HStack(spacing: 6) {
                        Circle()
                            .fill(aiAPIKey.count > 10 ? Color.green : Color.orange)
                            .frame(width: 6, height: 6)
                        Text(aiAPIKey.count > 10 ? "API Key 已設定" : "尚未設定，AI 功能將無法使用")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, 20)
    }

    private var recentGamesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("最近對局", systemImage: "clock.fill")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)

            VStack(spacing: 8) {
                ForEach(records.prefix(10)) { record in
                    GameRecordRow(record: record)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.12, blue: 0.35),
                Color(red: 0.02, green: 0.05, blue: 0.15),
            ],
            startPoint: .top, endPoint: .bottom
        )
    }
}

// MARK: - Profile Stat Card
struct ProfileStatCard: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon).foregroundColor(color).font(.title2)
            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Achievement Badge
struct AchievementBadge: View {
    let achievement: Achievement
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.yellow.opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 56, height: 56)
                Image(systemName: achievement.iconName)
                    .font(.title2)
                    .foregroundColor(isUnlocked ? .yellow : .white.opacity(0.2))
            }
            Text(achievement.name)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(isUnlocked ? .white : .white.opacity(0.3))
                .lineLimit(1)
        }
        .frame(width: 72)
    }
}

// MARK: - Game Record Row
struct GameRecordRow: View {
    let record: GameRecord

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: record.result == .win ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(record.result == .win ? .green : .red.opacity(0.6))
                .font(.title3)

            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Text("\(record.hiddenNumbers[i])")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .frame(width: 26, height: 28)
                        .background(colorFor(record.hiddenColors[i]).opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .foregroundColor(.white)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(record.guessList.count) 次猜測")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.55))
                Text(coinChangeText(record.finalCoinChange))
                    .font(.caption.bold())
                    .foregroundColor(record.finalCoinChange >= 0 ? .green : .orange)
            }

            Text(record.date, style: .date)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func colorFor(_ code: String) -> Color {
        switch code {
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        default: return .gray
        }
    }

    private func coinChangeText(_ change: Int) -> String {
        change >= 0 ? "+\(change)" : "\(change)"
    }
}

// MARK: - Preview
#Preview {
    ProfileView()
        .environment(AuthManager())
        .modelContainer(
            for: [PlayerProfile.self, GameRecord.self, Achievement.self],
            inMemory: true)
}
