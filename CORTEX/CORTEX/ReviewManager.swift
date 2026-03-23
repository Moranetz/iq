import Foundation
import UIKit
@preconcurrency import StoreKit

final class ReviewManager {
    static let shared = ReviewManager()
    private init() {}

    private let defaults = UserDefaults.standard
    private let lastVersionKey = "ReviewManager_lastVersionPrompted"

    private var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }

    private var alreadyPromptedThisVersion: Bool {
        defaults.string(forKey: lastVersionKey) == currentVersion
    }

    func checkAndPromptReview(accuracy: Int, sessionCount: Int) {
        guard accuracy >= 70 else { return }
        guard sessionCount >= 3 else { return }
        guard !alreadyPromptedThisVersion else { return }

        defaults.set(currentVersion, forKey: lastVersionKey)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
}
