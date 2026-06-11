import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(AuthManager.self) var authManager
    @Query private var profiles: [PlayerProfile]
    @Environment(\.modelContext) private var modelContext

    @State private var navigateToGame = false
    @State private var gameVM = GameViewModel()
    @State private var activeProfile: PlayerProfile?

    private var profile: PlayerProfile? {
        guard let userId = authManager.currentUser?.userId else { return nil }
        return profiles.first { $0.userId == userId }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient.ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("歡迎回來，")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                            Text(authManager.currentUser?.displayName ?? "玩家")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                        }

                        Spacer()

                        HStack(spacing: 6) {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.yellow)
                            Text("\(profile?.coinBalance ?? 3000)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.yellow)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    Spacer()

                    VStack(spacing: 24) {
                        HStack(spacing: 12) {
                            ForEach(0..<3) { i in
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(heroBoxColors[i])
                                    .frame(width: 68, height: 80)
                                    .overlay(
                                        Text("?")
                                            .font(.system(size: 32, weight: .black, design: .rounded))
                                            .foregroundColor(.white)
                                    )
                                    .shadow(color: heroBoxColors[i].opacity(0.5), radius: 10, y: 4)
                            }
                        }

                        VStack(spacing: 8) {
                            Text("數字冒險王")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            Text("抽線索、控成本，推理出三位密碼！")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .padding(32)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal, 24)

                    Spacer()

                    Button {
                        activeProfile = ensureProfile()
                        gameVM.startNewGame()
                        navigateToGame = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                            Text("開始新遊戲")
                                .font(.system(size: 19, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(
                            LinearGradient(colors: [.yellow, .orange],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .orange.opacity(0.5), radius: 12, y: 4)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            .navigationDestination(isPresented: $navigateToGame) {
                GameView(gameVM: gameVM, profile: activeProfile ?? profile)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .onAppear { _ = ensureProfile() }
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.05, green: 0.12, blue: 0.35),
                     Color(red: 0.02, green: 0.05, blue: 0.15)],
            startPoint: .top, endPoint: .bottom
        )
    }

    private let heroBoxColors: [Color] = [
        Color(red: 0.98, green: 0.76, blue: 0.12),
        Color(red: 0.18, green: 0.78, blue: 0.42),
        Color(red: 0.26, green: 0.52, blue: 0.96),
    ]

    @discardableResult
    private func ensureProfile() -> PlayerProfile? {
        guard let user = authManager.currentUser else { return nil }
        if let existing = profiles.first(where: { $0.userId == user.userId }) {
            return existing
        }

        let p = PlayerProfile(userId: user.userId,
                              displayName: user.displayName,
                              email: user.email)
        modelContext.insert(p)
        return p
    }
}

#Preview {
    HomeView()
        .environment(AuthManager())
        .modelContainer(for: [PlayerProfile.self, GameRecord.self, Achievement.self],
                        inMemory: true)
}
