import SwiftUI

struct ContentView: View {
    @State private var game = GameState()
    @State private var hasSeenOnboarding = Persistence.hasSeenOnboarding

    var body: some View {
        ZStack {
            P.bg.ignoresSafeArea()

            if !hasSeenOnboarding {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                    .transition(.opacity)
            } else {
                switch game.screen {
                case .home:
                    LandingView(game: game)
                        .transition(.opacity)
                case .game:
                    if game.levelingUp {
                        LevelUpView(game: game)
                            .transition(.scale.combined(with: .opacity))
                    } else if game.isDone {
                        ResultsView(game: game)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        GameView(game: game)
                            .transition(.opacity)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: hasSeenOnboarding)
        .animation(.easeInOut(duration: 0.3), value: game.screen == .home)
        .animation(.spring(response: 0.5), value: game.levelingUp)
        .animation(.spring(response: 0.5), value: game.isDone)
    }
}

// MARK: - Stats Bar

struct StatsBar: View {
    let game: GameState

    var body: some View {
        HStack(spacing: 6) {
            StatPill(icon: "bolt.fill", value: "\(game.lifetimeXP)", color: P.gold)
            StatPill(icon: "star.fill", value: "L\(game.lifetimeLevel)", color: P.main)
            StatPill(icon: "flame.fill", value: "\(game.dailyStreak)", color: Color(hex: "ff9e00"))
            StatPill(icon: "brain", value: "\(game.allConceptsLearned.count)/\(GameState.totalConceptCount)", color: P.teal)
        }
    }
}

struct StatPill: View {
    let icon: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .black))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 11, weight: .black))
                .foregroundColor(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
                .overlay(Capsule().stroke(color.opacity(0.2), lineWidth: 1.5))
        )
    }
}

// MARK: - Landing

struct LandingView: View {
    let game: GameState
    @State private var celebCount = 0
    @State private var appeared = false

    struct ModeItem: Identifiable {
        let id = UUID()
        let key: String
        let sfSymbol: String
        let name: String
        let desc: String
        let color: Color
        let count: Int
        var isDaily: Bool = false
        var dailyCompleted: Bool = false
    }

    var modes: [ModeItem] {
        [
            ModeItem(key: "daily", sfSymbol: "calendar", name: "Daily Challenge", desc: "5 fresh questions, one shot", color: P.gold, count: 5, isDaily: true, dailyCompleted: game.dailyChallengeCompletedToday),
            ModeItem(key: "all", sfSymbol: "dice.fill", name: "Mix All", desc: "Every mechanic, shuffled", color: P.teal, count: allRounds.count),
            ModeItem(key: "highlight", sfSymbol: "magnifyingglass", name: "Find the Flaw", desc: "Tap the broken logic", color: P.mag, count: allRounds.filter { $0.type == .highlight }.count),
            ModeItem(key: "scale", sfSymbol: "scalemass.fill", name: "Weigh Evidence", desc: "Sort what matters", color: P.blue, count: allRounds.filter { $0.type == .scale }.count),
            ModeItem(key: "chain", sfSymbol: "link", name: "Build the Chain", desc: "Predict consequences", color: P.lime, count: allRounds.filter { $0.type == .chain }.count),
            ModeItem(key: "slider", sfSymbol: "slider.horizontal.3", name: "Calibrate", desc: "Test your intuition", color: Color(hex: "2dd4bf"), count: allRounds.filter { $0.type == .slider }.count),
            ModeItem(key: "persuade", sfSymbol: "mic.fill", name: "Build Your Case", desc: "Master persuasion order", color: P.gold, count: allRounds.filter { $0.type == .persuade }.count),
            ModeItem(key: "rewrite", sfSymbol: "pencil", name: "Fix It", desc: "Repair broken arguments", color: Color(hex: "ff9e00"), count: allRounds.filter { $0.type == .rewrite }.count),
            ModeItem(key: "classic", sfSymbol: "target", name: "Spot It", desc: "Quick fire multi-choice", color: P.red, count: allRounds.filter { $0.type == .classic }.count),
        ]
    }

    var body: some View {
        ZStack {
            RadialGradient(colors: [Color(hex: "2a1055"), P.bg], center: .init(x: 0.5, y: 0.2), startRadius: 0, endRadius: UIScreen.main.bounds.height * 0.6)
                .ignoresSafeArea()

            StarsBackground()
                .ignoresSafeArea()
                .opacity(0.5)

            ConfettiOverlay(trigger: celebCount, count: 65, mega: true)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    BrainView(lvl: game.lifetimeLevel, streak: 4, mood: celebCount > 0 ? 1 : 0, size: 90, message: celebCount > 0 ? "let's goooo!" : nil)
                        .frame(width: 90, height: 90)
                        .padding(.top, 24)
                        .scaleEffect(appeared ? 1 : 0.4)
                        .opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.7, dampingFraction: 0.55), value: appeared)

                    Text("CORTEX")
                        .font(.system(size: 42, weight: .black))
                        .foregroundStyle(
                            LinearGradient(colors: [P.teal, P.main, P.mag], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .padding(.top, 4)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 14)
                        .animation(.easeOut(duration: 0.5).delay(0.15), value: appeared)

                    // Stats bar
                    StatsBar(game: game)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 14)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)

                    HStack(spacing: 4) {
                        Text("choose your training")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(P.dim)
                        Image(systemName: "sparkles")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(P.dim)
                    }
                    .padding(.bottom, 18)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 14)
                    .animation(.easeOut(duration: 0.5).delay(0.25), value: appeared)

                    VStack(spacing: 8) {
                        ForEach(Array(modes.enumerated()), id: \.element.id) { i, mode in
                            let isDisabled = mode.isDaily && mode.dailyCompleted
                            Button(action: {
                                guard !isDisabled else { return }
                                SoundManager.shared.tap()
                                HapticsManager.shared.light()
                                celebCount += 1
                                if mode.key == "all" || mode.key == "daily" {
                                    SoundManager.shared.go()
                                    HapticsManager.shared.big()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + (mode.key == "all" || mode.key == "daily" ? 0.3 : 0.15)) {
                                    if mode.key == "daily" {
                                        game.startDailyChallenge()
                                    } else {
                                        game.startGame(filter: mode.key)
                                    }
                                }
                            }) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Image(systemName: mode.sfSymbol)
                                            .font(.system(size: mode.key == "all" || mode.key == "daily" ? 24 : 20))
                                            .foregroundColor(mode.color)
                                            .frame(width: mode.key == "all" || mode.key == "daily" ? 48 : 42, height: mode.key == "all" || mode.key == "daily" ? 48 : 42)
                                            .background(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .fill(mode.color.opacity(0.1))
                                            )
                                    }

                                    VStack(alignment: .leading, spacing: 1) {
                                        HStack(spacing: 6) {
                                            Text(mode.name)
                                                .font(.system(size: mode.key == "all" || mode.key == "daily" ? 15 : 13, weight: .black))
                                                .foregroundColor(mode.key == "all" ? P.teal : (mode.key == "daily" ? P.gold : P.txt))
                                            if isDisabled {
                                                Text("COMPLETED")
                                                    .font(.system(size: 8, weight: .black))
                                                    .foregroundColor(P.teal)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Capsule().fill(P.teal.opacity(0.15)))
                                            }
                                        }
                                        Text(mode.desc)
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(P.mut)
                                    }

                                    Spacer()

                                    if !isDisabled {
                                        HStack(spacing: 4) {
                                            Text("\(mode.count)")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(P.mut)
                                            Image(systemName: "arrow.right")
                                                .font(.system(size: 12))
                                                .foregroundColor(mode.color)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, mode.key == "all" || mode.key == "daily" ? 14 : 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(mode.key == "all" ?
                                            AnyShapeStyle(LinearGradient(colors: [P.teal.opacity(0.09), P.mag.opacity(0.07)], startPoint: .leading, endPoint: .trailing)) :
                                            mode.key == "daily" ?
                                            AnyShapeStyle(LinearGradient(colors: [P.gold.opacity(0.09), Color(hex: "ff9e00").opacity(0.07)], startPoint: .leading, endPoint: .trailing)) :
                                            AnyShapeStyle(P.sf))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(mode.key == "all" ? P.teal.opacity(0.25) : (mode.key == "daily" ? P.gold.opacity(0.25) : P.bdr), lineWidth: 2)
                                        )
                                )
                                .shadow(color: (mode.key == "all" ? P.tealS.opacity(0.25) : (mode.key == "daily" ? P.gold.opacity(0.15) : P.bdr)), radius: 0, x: 0, y: 4)
                                .opacity(isDisabled ? 0.5 : 1)
                            }
                            .buttonStyle(.plain)
                            .disabled(isDisabled)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 14)
                            .animation(.easeOut(duration: 0.35).delay(0.15 + Double(i) * 0.06), value: appeared)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear { appeared = true }
    }
}

// MARK: - Game

struct GameView: View {
    let game: GameState

    var body: some View {
        let streakGlow: Color = game.streak >= 5 ? P.mag : game.streak >= 3 ? P.teal : P.main

        ZStack {
            RadialGradient(
                colors: [streakGlow.opacity(min(Double(game.streak) * 0.022, 0.14)), P.bg],
                center: .init(x: 0.5, y: 0.3),
                startRadius: 0,
                endRadius: UIScreen.main.bounds.height * 0.55
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.8), value: game.streak)

            StarsBackground()
                .ignoresSafeArea()
                .opacity(0.5)

            ConfettiOverlay(
                trigger: game.celebrationCount,
                count: game.streak >= 5 ? 65 : game.streak >= 3 ? 40 : 20,
                mega: game.streak >= 5
            )
            .ignoresSafeArea()

            // XP fly animation
            if game.lastPoints > 0 && game.feedback == 1 && !game.showInsight {
                Text("+\(game.lastPoints)")
                    .font(.system(size: 30, weight: .black))
                    .foregroundColor(P.gold)
                    .shadow(color: P.gold.opacity(0.5), radius: 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 6) {
                    TopBar(game: game)
                        .padding(.horizontal, 14)

                    // Combo text
                    if game.streak >= 2 && game.feedback == 1 && !game.showInsight {
                        Text(game.comboTexts[game.comboIndex])
                            .font(.system(size: game.comboSizes[game.comboIndex], weight: .black))
                            .foregroundColor(game.comboColors[game.comboIndex])
                            .shadow(color: game.comboColors[game.comboIndex].opacity(0.5), radius: CGFloat(8 + game.comboIndex * 4))
                            .transition(.scale.combined(with: .opacity))
                    }

                    // Type badge
                    HStack(spacing: 4) {
                        Image(systemName: game.currentRound.type.sfSymbol)
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(P.main)
                        Text(game.currentRound.type.label)
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(P.main)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(P.main.opacity(0.12))
                            .shadow(color: P.mainS.opacity(0.2), radius: 0, x: 0, y: 3)
                    )

                    // Question content
                    Group {
                        switch game.currentRound.type {
                        case .highlight:
                            HighlightView(round: game.currentRound, onResult: { game.onResult(correct: $0) })
                        case .scale:
                            ScaleView(round: game.currentRound, onResult: { game.onResult(correct: $0) })
                        case .chain:
                            ChainView(round: game.currentRound, onResult: { game.onResult(correct: $0) })
                        case .slider:
                            SliderView(round: game.currentRound, onResult: { game.onResult(correct: $0) })
                        case .rewrite:
                            RewriteView(round: game.currentRound, onResult: { game.onResult(correct: $0) })
                        case .persuade:
                            PersuadeView(round: game.currentRound, onResult: { game.onResult(correct: $0) })
                        case .classic:
                            ClassicView(round: game.currentRound, onResult: { game.onResult(correct: $0) })
                        }
                    }
                    .id(game.roundIndex)
                    .padding(.horizontal, 14)
                    .offset(x: game.shaking ? -5 : 0)
                    .animation(game.shaking ? .default.repeatCount(4, autoreverses: true).speed(6) : .default, value: game.shaking)

                    // Insight reveal
                    if game.showInsight {
                        InsightCard(
                            round: game.currentRound,
                            correct: game.feedback == 1
                        ) {
                            game.nextRound()
                        }
                        .padding(.horizontal, 14)
                        .transition(.scale(scale: 0.88).combined(with: .opacity))
                        .animation(.spring(response: 0.4), value: game.showInsight)
                    }

                    Spacer(minLength: 20)

                    // Bottom stats
                    HStack(spacing: 4) {
                        if !game.conceptsLearned.isEmpty {
                            HStack(spacing: 2) {
                                Image(systemName: "brain")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(P.mut)
                                Text("\(game.conceptsLearned.count)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(P.mut)
                            }
                        }
                        HStack(spacing: 2) {
                            Text("best")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(P.mut)
                            Image(systemName: "sparkles")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(P.mut)
                            Text("\(game.bestStreak)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(P.mut)
                        }
                    }
                    .padding(.bottom, 8)
                }
                .padding(.top, 12)
            }
        }
    }
}

// MARK: - Level Up

struct LevelUpView: View {
    let game: GameState

    var body: some View {
        ZStack {
            RadialGradient(colors: [Color(hex: "3a1070"), P.bg], center: .center, startRadius: 0, endRadius: 300)
                .ignoresSafeArea()

            StarsBackground()
                .ignoresSafeArea()
                .opacity(0.5)

            ConfettiOverlay(trigger: 1, count: 95, mega: true)
                .ignoresSafeArea()

            VStack(spacing: 8) {
                BrainView(lvl: game.level, streak: game.streak, mood: 1, size: 130, message: "LEVEL UP!")
                    .frame(width: 130, height: 130)

                Text("\(game.level)")
                    .font(.system(size: 56, weight: .black))
                    .foregroundColor(P.teal)
                    .shadow(color: P.teal.opacity(0.3), radius: 30)
            }
            .scaleEffect(1)
            .transition(.scale(scale: 0.2).combined(with: .opacity))
        }
    }
}

// MARK: - Results

struct ResultsView: View {
    let game: GameState

    var body: some View {
        ZStack {
            RadialGradient(colors: [Color(hex: "2a1055"), P.bg], center: .init(x: 0.5, y: 0.3), startRadius: 0, endRadius: UIScreen.main.bounds.height * 0.65)
                .ignoresSafeArea()

            StarsBackground()
                .ignoresSafeArea()
                .opacity(0.5)

            ConfettiOverlay(trigger: 1, count: 85, mega: true)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    BrainView(lvl: game.level, streak: game.bestStreak, mood: 1, size: 100, message: game.hearts > 0 ? "crushed it!" : "next time!")
                        .frame(width: 100, height: 100)
                        .padding(.top, 40)

                    if game.isDailyChallenge {
                        Text("DAILY CHALLENGE")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(P.gold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(P.gold.opacity(0.15)).overlay(Capsule().stroke(P.gold.opacity(0.3), lineWidth: 1.5)))
                    }

                    // Stats grid
                    HStack(spacing: 8) {
                        StatBox(sfSymbol: "bolt.fill", value: "\(game.xp)", color: P.gold)
                        StatBox(sfSymbol: "target", value: "\(game.accuracy)%", color: P.teal)
                        StatBox(sfSymbol: "sparkles", value: "\(game.bestStreak)", color: P.mag)
                    }

                    // Concepts learned
                    if !game.conceptsLearned.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 4) {
                                Image(systemName: "brain")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(P.teal)
                                Text("\(game.conceptsLearned.count) concepts learned")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(P.teal)
                            }

                            FlowLayout(spacing: 3) {
                                ForEach(game.conceptsLearned, id: \.self) { concept in
                                    Text(concept)
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(P.teal)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(
                                            Capsule()
                                                .fill(P.teal.opacity(0.08))
                                                .overlay(Capsule().stroke(P.teal.opacity(0.2), lineWidth: 2))
                                        )
                                }
                            }
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(P.sf)
                                .shadow(color: P.bdr.opacity(0.5), radius: 0, x: 0, y: 4)
                        )
                    }

                    HStack(spacing: 10) {
                        if !game.isDailyChallenge {
                            GButton(text: "again", color: P.teal, big: true) {
                                game.playAgain()
                            }
                        }
                        GButton(text: "home", color: game.isDailyChallenge ? P.teal : P.mut, big: game.isDailyChallenge, outline: !game.isDailyChallenge) {
                            game.goHome()
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

struct StatBox: View {
    let sfSymbol: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: sfSymbol)
                .font(.system(size: 11))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 22, weight: .black))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(P.sf)
                .shadow(color: P.bdr.opacity(0.5), radius: 0, x: 0, y: 4)
        )
    }
}

#Preview {
    ContentView()
}
