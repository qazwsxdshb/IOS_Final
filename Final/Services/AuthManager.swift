import Foundation
import SwiftUI

// MARK: - User Session Model
struct UserSession {
    let userId: String
    let displayName: String
    let email: String
    let avatarURL: URL?
}

// MARK: - AuthManager
/// Currently uses mock login.
/// To wire in Google Sign-In later:
///   1. Add GoogleSignIn SDK via SPM: https://github.com/google/GoogleSignIn-iOS
///   2. Replace `mockSignIn()` with GIDSignIn.sharedInstance.signIn(...)
///   3. Map GIDGoogleUser → UserSession
@MainActor
@Observable
final class AuthManager {

    var currentUser: UserSession? = nil
    var isLoading: Bool = false
    var errorMessage: String? = nil

    var isLoggedIn: Bool { currentUser != nil }

    // MARK: - Mock Sign In (replace with Google SDK)
    func signInWithGoogle(presentingVC: UIViewController? = nil) async {
        isLoading = true
        errorMessage = nil

        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // TODO: Replace below with actual Google Sign-In
        // Example when Google SDK is added:
        //
        // guard let vc = presentingVC else { isLoading = false; return }
        // do {
        //     let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: vc)
        //     let user = result.user
        //     let profile = user.profile
        //     currentUser = UserSession(
        //         userId: user.userID ?? UUID().uuidString,
        //         displayName: profile?.name ?? "玩家",
        //         email: profile?.email ?? "",
        //         avatarURL: profile?.imageURL(withDimension: 200)
        //     )
        // } catch {
        //     errorMessage = "Google 登入失敗：\(error.localizedDescription)"
        // }

        currentUser = UserSession(
            userId: "mock_\(UUID().uuidString.prefix(8))",
            displayName: "測試玩家",
            email: "test@example.com",
            avatarURL: nil
        )
        isLoading = false
    }

    func signOut() {
        // TODO: GIDSignIn.sharedInstance.signOut()
        currentUser = nil
    }
}
