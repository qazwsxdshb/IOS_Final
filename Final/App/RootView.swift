import SwiftUI

struct RootView: View {
    @Environment(AuthManager.self) var authManager

    var body: some View {
        Group {
            if authManager.isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authManager.isLoggedIn)
    }
}

#Preview {
    RootView()
        .environment(AuthManager())
}
