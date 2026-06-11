import Foundation
import Observation

enum RewardedAdConfiguration {
    static let applicationIdentifier = "ca-app-pub-8874059234215601~2364644736"
    static let rewardedAdUnitIdentifier = "ca-app-pub-8874059234215601/4607664694"
    static let rewardCoins = 10_000

    /// Starting balance for every newly-created player profile.
    static let startingCoins = 20_000
}

/// A small rewarded-ad facade used by the UI. The IDs are kept here so the
/// Google Mobile Ads SDK integration can replace the simulated delay with an
/// actual rewarded ad load/show flow without changing reward accounting.
@MainActor
@Observable
final class RewardedAdService {
    private(set) var isShowingAd = false

    func showRewardedAd() async -> Int {
        guard !isShowingAd else { return 0 }

        isShowingAd = true
        defer { isShowingAd = false }

        // Placeholder for the Google Mobile Ads rewarded ad presentation.
        // The game still applies the same reward path so the economy and UI
        // behavior are ready for the real ad callback.
        try? await Task.sleep(nanoseconds: 800_000_000)
        return RewardedAdConfiguration.rewardCoins
    }
}
