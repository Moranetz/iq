import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var step = 0
    @State private var appeared = false

    private let typeInfo: [(RoundType, String)] = [
        (.highlight, "Find the Flaw"),
        (.scale, "Weigh Evidence"),
        (.chain, "Build the Chain"),
        (.slider, "Calibrate"),
        (.persuade, "Build Your Case"),
        (.rewrite, "Fix It"),
        (.classic, "Spot It"),
    ]

    var body: some View {
        ZStack {
            RadialGradient(colors: [Color(hex: "2a1055"), P.bg], center: .init(x: 0.5, y: 0.3), startRadius: 0, endRadius: UIScreen.main.bounds.height * 0.6)
                .ignoresSafeArea()

            StarsBackground()
                .ignoresSafeArea()
                .opacity(0.5)

            VStack(spacing: 0) {
                Spacer()

                if step == 0 {
                    stepOne
                        .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading).combined(with: .opacity)))
                } else if step == 1 {
                    stepTwo
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                } else {
                    stepThree
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
                }

                Spacer()

                // Dots
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(i == step ? P.teal : P.mut.opacity(0.4))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 16)

                if step < 2 {
                    GButton(text: "next", color: P.teal, big: true) {
                        withAnimation(.spring(response: 0.5)) {
                            step += 1
                        }
                    }
                    .padding(.bottom, 40)
                } else {
                    GButton(text: "start training", color: P.teal, big: true) {
                        Persistence.hasSeenOnboarding = true
                        withAnimation(.spring(response: 0.5)) {
                            hasSeenOnboarding = true
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear { appeared = true }
    }

    // MARK: - Step 1

    private var stepOne: some View {
        VStack(spacing: 12) {
            BrainView(lvl: 6, streak: 4, mood: 1, size: 140, message: nil)
                .frame(width: 140, height: 140)
                .scaleEffect(appeared ? 1 : 0.3)
                .animation(.spring(response: 0.8, dampingFraction: 0.5), value: appeared)

            Text("CORTEX")
                .font(.system(size: 52, weight: .black))
                .foregroundStyle(
                    LinearGradient(colors: [P.teal, P.main, P.mag], startPoint: .topLeading, endPoint: .bottomTrailing)
                )

            Text("The reasoning game where\nthe mechanic IS the skill")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(P.dim)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
    }

    // MARK: - Step 2

    private var stepTwo: some View {
        VStack(spacing: 16) {
            Text("7 ways to think")
                .font(.system(size: 28, weight: .black))
                .foregroundColor(P.txt)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(typeInfo, id: \.0) { rt, name in
                    HStack(spacing: 10) {
                        Image(systemName: rt.icon)
                            .font(.system(size: 18))
                            .foregroundColor(rt.color)
                            .frame(width: 36, height: 36)
                            .background(RoundedRectangle(cornerRadius: 10).fill(rt.color.opacity(0.12)))

                        Text(name)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(P.txt)
                            .lineLimit(1)

                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 14).fill(P.sf))
                }
            }
            .padding(.horizontal, 24)

            Text("Each mechanic teaches a different reasoning skill.\nYou don't learn ABOUT the concept \u{2014} you PERFORM it.")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(P.dim)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 24)
        }
    }

    // MARK: - Step 3

    private var stepThree: some View {
        VStack(spacing: 20) {
            BrainView(lvl: 1, streak: 0, mood: 1, size: 120, message: "let's go!")
                .frame(width: 120, height: 120)

            Text("Ready?")
                .font(.system(size: 36, weight: .black))
                .foregroundStyle(
                    LinearGradient(colors: [P.teal, P.main], startPoint: .leading, endPoint: .trailing)
                )

            Text("Train your brain. Level up your thinking.")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(P.dim)
        }
    }
}
