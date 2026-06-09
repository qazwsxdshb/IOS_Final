import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) var authManager
    @State private var showError = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.12, blue: 0.35),
                         Color(red: 0.02, green: 0.05, blue: 0.15)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.12))
                            .frame(width: 110, height: 110)
                        Image(systemName: "lock.open.fill")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(colors: [.yellow, .orange],
                                               startPoint: .top, endPoint: .bottom)
                            )
                    }

                    Text("數字冒險王")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Text("AI 輔助猜謎解碼遊戲")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.65))
                }

                Spacer()

                VStack(spacing: 20) {
                    GoogleSignInButton(isLoading: authManager.isLoading) {
                        Task { await authManager.signInWithGoogle() }
                    }

                    Text("登入即代表您同意我們的服務條款與隱私政策")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
        .alert("登入失敗", isPresented: $showError) {
            Button("確定", role: .cancel) {}
        } message: {
            Text(authManager.errorMessage ?? "請稍後再試")
        }
        .onChange(of: authManager.errorMessage) { _, msg in
            showError = msg != nil
        }
    }
}

// MARK: - Google Sign-In Button
struct GoogleSignInButton: View {
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .tint(.black.opacity(0.6))
                        .frame(width: 24, height: 24)
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                        Text("G")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(red: 0.26, green: 0.52, blue: 0.96))
                    }
                }

                Text(isLoading ? "登入中…" : "以 Google 帳號登入")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black.opacity(0.75))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
        }
        .disabled(isLoading)
        .buttonStyle(.plain)
    }
}

#Preview {
    LoginView()
        .environment(AuthManager())
}
