import Foundation

enum Persistence {
    private static let defaults = UserDefaults.standard

    // Keys
    private enum Key {
        static let lifetimeXP = "cortex_lifetimeXP"
        static let lifetimeLevel = "cortex_lifetimeLevel"
        static let lifetimeBestStreak = "cortex_lifetimeBestStreak"
        static let allConceptsLearned = "cortex_allConceptsLearned"
        static let dailyStreak = "cortex_dailyStreak"
        static let lastPlayedDate = "cortex_lastPlayedDate"
        static let gamesCompleted = "cortex_gamesCompleted"
        static let hasSeenOnboarding = "cortex_hasSeenOnboarding"
        static let lastDailyChallengeDate = "cortex_lastDailyChallengeDate"
    }

    // MARK: - Read

    static var lifetimeXP: Int {
        get { defaults.integer(forKey: Key.lifetimeXP) }
        set { defaults.set(newValue, forKey: Key.lifetimeXP) }
    }

    static var lifetimeLevel: Int {
        get { max(1, defaults.integer(forKey: Key.lifetimeLevel)) }
        set { defaults.set(newValue, forKey: Key.lifetimeLevel) }
    }

    static var lifetimeBestStreak: Int {
        get { defaults.integer(forKey: Key.lifetimeBestStreak) }
        set { defaults.set(newValue, forKey: Key.lifetimeBestStreak) }
    }

    static var allConceptsLearned: [String] {
        get { defaults.stringArray(forKey: Key.allConceptsLearned) ?? [] }
        set { defaults.set(newValue, forKey: Key.allConceptsLearned) }
    }

    static var dailyStreak: Int {
        get { defaults.integer(forKey: Key.dailyStreak) }
        set { defaults.set(newValue, forKey: Key.dailyStreak) }
    }

    static var lastPlayedDate: Date? {
        get { defaults.object(forKey: Key.lastPlayedDate) as? Date }
        set { defaults.set(newValue, forKey: Key.lastPlayedDate) }
    }

    static var gamesCompleted: Int {
        get { defaults.integer(forKey: Key.gamesCompleted) }
        set { defaults.set(newValue, forKey: Key.gamesCompleted) }
    }

    static var hasSeenOnboarding: Bool {
        get { defaults.bool(forKey: Key.hasSeenOnboarding) }
        set { defaults.set(newValue, forKey: Key.hasSeenOnboarding) }
    }

    static var lastDailyChallengeDate: Date? {
        get { defaults.object(forKey: Key.lastDailyChallengeDate) as? Date }
        set { defaults.set(newValue, forKey: Key.lastDailyChallengeDate) }
    }

    // MARK: - Daily streak logic

    static func updateDailyStreak() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())

        if let last = lastPlayedDate {
            let lastDay = cal.startOfDay(for: last)
            let diff = cal.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 1 {
                dailyStreak += 1
            } else if diff > 1 {
                dailyStreak = 1
            }
            // diff == 0 means same day, keep streak
        } else {
            dailyStreak = 1
        }
        lastPlayedDate = Date()
    }

    static var dailyChallengeCompletedToday: Bool {
        guard let last = lastDailyChallengeDate else { return false }
        return Calendar.current.isDateInToday(last)
    }

    static func completeDailyChallenge() {
        lastDailyChallengeDate = Date()
    }
}
