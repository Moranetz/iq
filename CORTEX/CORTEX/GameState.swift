import SwiftUI

@Observable
final class GameState {
    var screen: Screen = .home
    var filterType: String = "all"

    // Game state
    var deck: [Round] = []
    var roundIndex: Int = 0
    var feedback: Int? = nil // nil=pending, 1=correct, 0=wrong
    var showInsight: Bool = false
    var streak: Int = 0
    var bestStreak: Int = 0
    var xp: Int = 0
    var hearts: Int = 5
    var celebrationCount: Int = 0
    var shaking: Bool = false
    var level: Int = 1
    var levelingUp: Bool = false
    var lastPoints: Int = 0
    var isDone: Bool = false
    var conceptsLearned: [String] = []
    var totalCorrect: Int = 0
    var totalAttempted: Int = 0
    var mood: Int = 0 // -1, 0, 1
    var brainMessage: String? = nil

    // Lifetime / persistence
    var lifetimeXP: Int = 0
    var lifetimeLevel: Int = 1
    var lifetimeBestStreak: Int = 0
    var allConceptsLearned: [String] = []
    var dailyStreak: Int = 0
    var lastPlayedDate: Date? = nil
    var gamesCompleted: Int = 0

    // Daily challenge
    var isDailyChallenge: Bool = false
    var dailyChallengeCompletedToday: Bool = false

    var currentRound: Round {
        deck[roundIndex % deck.count]
    }

    var maxRounds: Int {
        if isDailyChallenge { return 5 }
        return min(deck.count, 10)
    }

    var accuracy: Int {
        totalAttempted > 0 ? Int(round(Double(totalCorrect) / Double(totalAttempted) * 100)) : 0
    }

    var comboIndex: Int {
        min(streak, comboTexts.count - 1)
    }

    let comboTexts = ["nice!", "smooth!", "yesss!", "AMAZING!", "BRILLIANT!", "ON FIRE!", "LEGENDARY!"]
    let comboColors: [Color] = [P.teal, P.teal, P.main, P.gold, P.gold, P.mag, P.mag]
    let comboSizes: [CGFloat] = [16, 17, 20, 24, 28, 34, 40]
    let okMessages = ["nailed it!", "big brain!", "too easy!", "sheesh!", "exactly right!"]
    let noMessages = ["we got this!", "close!", "next one!", "tricky!"]

    static let totalConceptCount = 23

    enum Screen {
        case home, game
    }

    init() {
        loadFromDisk()
    }

    // MARK: - Persistence

    func loadFromDisk() {
        lifetimeXP = Persistence.lifetimeXP
        lifetimeLevel = Persistence.lifetimeLevel
        lifetimeBestStreak = Persistence.lifetimeBestStreak
        allConceptsLearned = Persistence.allConceptsLearned
        dailyStreak = Persistence.dailyStreak
        lastPlayedDate = Persistence.lastPlayedDate
        gamesCompleted = Persistence.gamesCompleted
        dailyChallengeCompletedToday = Persistence.dailyChallengeCompletedToday
    }

    func saveToDisk() {
        Persistence.lifetimeXP = lifetimeXP
        Persistence.lifetimeLevel = lifetimeLevel
        Persistence.lifetimeBestStreak = lifetimeBestStreak
        Persistence.allConceptsLearned = allConceptsLearned
        Persistence.dailyStreak = dailyStreak
        Persistence.gamesCompleted = gamesCompleted
    }

    private func mergeSessionData() {
        lifetimeXP += xp
        lifetimeLevel = max(lifetimeLevel, level)
        lifetimeBestStreak = max(lifetimeBestStreak, bestStreak)
        for c in conceptsLearned {
            if !allConceptsLearned.contains(c) {
                allConceptsLearned.append(c)
            }
        }
        gamesCompleted += 1
        Persistence.updateDailyStreak()
        dailyStreak = Persistence.dailyStreak
        lastPlayedDate = Persistence.lastPlayedDate
    }

    // MARK: - Game flow

    func startGame(filter: String) {
        filterType = filter
        isDailyChallenge = false
        let pool = filter == "all" ? allRounds : allRounds.filter { $0.type.rawValue == filter }
        deck = pool.shuffled()
        roundIndex = 0
        feedback = nil
        showInsight = false
        streak = 0
        bestStreak = 0
        xp = 0
        hearts = 5
        celebrationCount = 0
        shaking = false
        level = 1
        levelingUp = false
        lastPoints = 0
        isDone = false
        conceptsLearned = []
        totalCorrect = 0
        totalAttempted = 0
        mood = 0
        brainMessage = nil
        screen = .game
    }

    func startDailyChallenge() {
        filterType = "daily"
        isDailyChallenge = true
        deck = allRounds.shuffled()
        roundIndex = 0
        feedback = nil
        showInsight = false
        streak = 0
        bestStreak = 0
        xp = 0
        hearts = 3
        celebrationCount = 0
        shaking = false
        level = 1
        levelingUp = false
        lastPoints = 0
        isDone = false
        conceptsLearned = []
        totalCorrect = 0
        totalAttempted = 0
        mood = 0
        brainMessage = nil
        screen = .game
    }

    func onResult(correct: Bool) {
        totalAttempted += 1
        if correct {
            let ns = streak + 1
            streak = ns
            bestStreak = max(bestStreak, ns)
            totalCorrect += 1
            let p = 12 + min(ns, 7) * 6
            xp += p
            lastPoints = p
            mood = 1
            feedback = 1
            brainMessage = okMessages.randomElement()
            SoundManager.shared.ok(streak: ns)
            HapticsManager.shared.success()
            celebrationCount += 1

            if !conceptsLearned.contains(currentRound.concept) {
                conceptsLearned.append(currentRound.concept)
            }

            if ns % 4 == 0 && level < 15 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                    guard let self = self else { return }
                    self.level += 1
                    self.levelingUp = true
                    SoundManager.shared.levelUp()
                    HapticsManager.shared.big()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { [weak self] in
                        self?.levelingUp = false
                    }
                }
            }
        } else {
            streak = 0
            lastPoints = 0
            hearts = max(0, hearts - 1)
            mood = -1
            feedback = 0
            brainMessage = noMessages.randomElement()
            SoundManager.shared.no()
            HapticsManager.shared.error()
            shaking = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                self?.shaking = false
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.showInsight = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.mood = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.brainMessage = nil
        }
    }

    func nextRound() {
        if hearts <= 0 || (roundIndex > 0 && (roundIndex + 1) % maxRounds == 0) {
            isDone = true
            mergeSessionData()
            if isDailyChallenge {
                Persistence.completeDailyChallenge()
                dailyChallengeCompletedToday = true
            }
            saveToDisk()
            ReviewManager.shared.checkAndPromptReview(accuracy: accuracy, sessionCount: gamesCompleted)
            return
        }
        roundIndex += 1
        feedback = nil
        showInsight = false
    }

    func playAgain() {
        isDone = false
        hearts = isDailyChallenge ? 3 : 5
        roundIndex += 1
        feedback = nil
        showInsight = false
    }

    func goHome() {
        if screen == .game && !isDone {
            // Save partial progress when leaving mid-game
            mergeSessionData()
            saveToDisk()
        }
        screen = .home
        dailyChallengeCompletedToday = Persistence.dailyChallengeCompletedToday
    }
}
