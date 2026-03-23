import SwiftUI

struct GButton: View {
    let text: String
    var color: Color = P.main
    var big: Bool = false
    var outline: Bool = false
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: {
            SoundManager.shared.tap()
            HapticsManager.shared.light()
            pressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { pressed = false }
            action()
        }) {
            Text(text)
                .font(.system(size: big ? 17 : 14, weight: .black))
                .foregroundColor(outline ? color : .white)
                .textCase(.uppercase)
                .tracking(0.5)
                .padding(.horizontal, big ? 36 : 24)
                .padding(.vertical, big ? 16 : 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(outline ? Color.clear : color.opacity(pressed ? 0.82 : 1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(outline ? color : Color.clear, lineWidth: 3)
                        )
                )
                .shadow(color: (outline ? color.opacity(0.3) : color.opacity(0.5)), radius: 0, x: 0, y: pressed ? 1 : 5)
                .offset(y: pressed ? 4 : 0)
        }
        .buttonStyle(.plain)
    }
}

struct CardStyle: ViewModifier {
    var highlighted: Bool = false
    var color: Color = P.bdr

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(P.sf)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(highlighted ? color : P.bdr, lineWidth: 2)
            )
            .shadow(color: P.bdr.opacity(0.5), radius: 0, x: 0, y: 3)
    }
}

struct InsightCard: View {
    let round: Round
    let correct: Bool
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "brain")
                    .font(.system(size: 14))
                    .foregroundColor(correct ? P.teal : P.mag)
                Text(round.concept)
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(correct ? P.teal : P.mag)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill((correct ? P.teal : P.mag).opacity(0.08))
                    .overlay(Capsule().stroke((correct ? P.teal : P.mag).opacity(0.2), lineWidth: 2))
            )

            Text(round.explain.isEmpty ? round.lesson : round.explain)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(P.dim)
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            GButton(text: "continue", color: P.teal, action: onContinue)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(P.sf)
                .shadow(color: P.bdr.opacity(0.5), radius: 0, x: 0, y: 4)
        )
        .transition(.scale.combined(with: .opacity))
    }
}

struct TopBar: View {
    let game: GameState

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Button(action: { game.goHome() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(P.mut)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(RoundedRectangle(cornerRadius: 12).fill(P.sf))
                        .shadow(color: P.bdr.opacity(0.5), radius: 0, x: 0, y: 3)
                }
                .buttonStyle(.plain)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(P.sf)
                            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 2)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(colors: [P.teal, P.mag], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * CGFloat(game.roundIndex % game.maxRounds) / CGFloat(game.maxRounds))
                    }
                }
                .frame(height: 16)

                HStack(spacing: 1.5) {
                    ForEach(0..<5, id: \.self) { i in
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12))
                            .foregroundColor(P.main)
                            .opacity(i < game.hearts ? 1 : 0.15)
                    }
                }
            }

            HStack {
                HStack(spacing: 4) {
                    BrainView(lvl: game.level, streak: game.streak, mood: game.mood, size: 32, message: game.brainMessage)
                        .frame(width: 32, height: 32)
                    Text("L\(game.level)")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(P.main)
                    if game.streak >= 3 {
                        HStack(spacing: 1) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 9, weight: .black))
                                .foregroundColor(game.comboColors[game.comboIndex])
                            Text("x\(min(game.streak, 7))")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(game.comboColors[game.comboIndex])
                        }
                    }
                }

                Spacer()

                HStack(spacing: 2) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(P.gold)
                    Text("\(game.xp)")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(P.gold)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(P.gold.opacity(0.08))
                        .shadow(color: P.gold.opacity(0.2), radius: 0, x: 0, y: 2)
                )
            }
        }
    }
}
