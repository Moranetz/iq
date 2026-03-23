import SwiftUI

// MARK: - HIGHLIGHT -- Tap the exact flaw

struct HighlightView: View {
    let round: Round
    let onResult: (Bool) -> Void

    @State private var tapped: Set<Int> = []
    @State private var done = false
    @State private var correct: Bool? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(round.setup)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(P.dim)

            FlowLayout(spacing: 6) {
                ForEach(Array(round.text.enumerated()), id: \.offset) { i, phrase in
                    Button(action: {
                        guard !done else { return }
                        SoundManager.shared.tap()
                        HapticsManager.shared.light()
                        if tapped.contains(i) { tapped.remove(i) } else { tapped.insert(i) }
                    }) {
                        HStack(spacing: 3) {
                            Text(phrase)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(phraseColor(i))
                            if done && round.flawIdx.contains(i) {
                                Image(systemName: correct == true ? "checkmark" : "exclamationmark.triangle.fill")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(correct == true ? P.teal : P.red)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(phraseBg(i))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(phraseBorder(i), lineWidth: 2))
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(done)
                }
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(P.sf).shadow(color: P.bdr.opacity(0.5), radius: 0, x: 0, y: 4))

            HStack(spacing: 4) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(P.mut)
                Text("Tap the part that's flawed, then check")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(P.mut)
            }

            if !done && !tapped.isEmpty {
                GButton(text: "check", color: P.teal) {
                    let flawSet = Set(round.flawIdx)
                    let ok = round.flawIdx.allSatisfy { tapped.contains($0) } && tapped.count == flawSet.count
                    correct = ok
                    done = true
                    onResult(ok)
                }
            }
        }
    }

    private func phraseColor(_ i: Int) -> Color {
        let isFlawed = round.flawIdx.contains(i)
        let isTapped = tapped.contains(i)
        if done && isFlawed { return correct == true ? P.teal : P.red }
        if done && isTapped && !isFlawed { return P.red }
        if isTapped { return P.mag }
        return P.txt
    }

    private func phraseBg(_ i: Int) -> Color {
        let isFlawed = round.flawIdx.contains(i)
        let isTapped = tapped.contains(i)
        if done && isFlawed { return (correct == true ? P.teal : P.red).opacity(0.15) }
        if done && isTapped && !isFlawed { return P.red.opacity(0.1) }
        if isTapped { return P.mag.opacity(0.12) }
        return .clear
    }

    private func phraseBorder(_ i: Int) -> Color {
        let isFlawed = round.flawIdx.contains(i)
        let isTapped = tapped.contains(i)
        if done && isFlawed { return (correct == true ? P.teal : P.red) }
        if done && isTapped && !isFlawed { return P.red.opacity(0.5) }
        if isTapped { return P.mag }
        return .clear
    }
}

// MARK: - SCALE -- Sort evidence

struct ScaleView: View {
    let round: Round
    let onResult: (Bool) -> Void

    @State private var placed: [Int: String] = [:]
    @State private var done = false
    @State private var score: Int? = nil

    private var leftW: Int { round.cards.enumerated().reduce(0) { s, pair in placed[pair.offset] == "left" ? s + pair.element.weight : s } }
    private var rightW: Int { round.cards.enumerated().reduce(0) { s, pair in placed[pair.offset] == "right" ? s + pair.element.weight : s } }
    private var tilt: Double { max(-25, min(25, Double(leftW - rightW) * 4)) }

    var body: some View {
        VStack(spacing: 10) {
            Text(round.setup)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(P.dim)
                .multilineTextAlignment(.center)

            // Visual scale
            ZStack {
                Rectangle().fill(P.bdr).frame(width: 4, height: 30).cornerRadius(2)
                    .offset(y: 15)
                HStack {
                    HStack(spacing: 3) {
                        Image(systemName: round.leftIcon)
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(P.blue)
                        Text(round.leftLabel)
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(P.blue)
                    }
                    Spacer()
                    HStack(spacing: 3) {
                        Image(systemName: round.rightIcon)
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(P.mag)
                        Text(round.rightLabel)
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(P.mag)
                    }
                }
                .frame(height: 4)
                .frame(maxWidth: .infinity)
                .background(Rectangle().fill(P.main).frame(height: 4).cornerRadius(2))
                .rotationEffect(.degrees(tilt))
                .animation(.spring(response: 0.4), value: tilt)
            }
            .frame(height: 60)
            .padding(.horizontal)

            // Evidence cards
            VStack(spacing: 8) {
                ForEach(Array(round.cards.enumerated()), id: \.element.id) { i, card in
                    HStack(spacing: 8) {
                        sideButton(cardIndex: i, side: "left", color: P.blue, arrow: "chevron.left", isCorrect: done && placed[i] == card.side, isWrong: done && placed[i] != nil && placed[i] != card.side)

                        Text(card.text)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(placed[i] != nil ? P.txt : P.dim)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 12).fill(P.sf))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(cardBorder(i, card), lineWidth: 2))
                            .shadow(color: P.bdr.opacity(0.5), radius: 0, x: 0, y: 3)

                        sideButton(cardIndex: i, side: "right", color: P.mag, arrow: "chevron.right", isCorrect: done && placed[i] == card.side, isWrong: done && placed[i] != nil && placed[i] != card.side)
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }

            if !done && placed.count >= round.cards.count {
                GButton(text: "weigh it", color: P.teal) {
                    var correct = 0
                    for (i, card) in round.cards.enumerated() {
                        if placed[i] == card.side { correct += 1 }
                    }
                    score = correct
                    done = true
                    onResult(correct >= Int(ceil(Double(round.cards.count) * 0.6)))
                }
            }
        }
    }

    private func cardBorder(_ i: Int, _ card: EvidenceCard) -> Color {
        guard done, let p = placed[i] else { return .clear }
        return p == card.side ? P.teal.opacity(0.5) : P.red.opacity(0.5)
    }

    @ViewBuilder
    private func sideButton(cardIndex: Int, side: String, color: Color, arrow: String, isCorrect: Bool, isWrong: Bool) -> some View {
        let isPlaced = placed[cardIndex] == side
        Button(action: {
            guard !done else { return }
            SoundManager.shared.tap()
            HapticsManager.shared.light()
            placed[cardIndex] = side
        }) {
            Group {
                if isPlaced && done {
                    Image(systemName: isCorrect ? "checkmark" : "xmark")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(isCorrect ? P.teal : P.red)
                } else {
                    Image(systemName: arrow)
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(color)
                }
            }
            .frame(width: 44, height: 44)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isPlaced ? (done ? (isCorrect ? P.teal.opacity(0.12) : P.red.opacity(0.12)) : color.opacity(0.12)) : P.sf)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(isPlaced ? (done ? (isCorrect ? P.teal : P.red) : color) : P.bdr, lineWidth: 2))
            )
        }
        .buttonStyle(.plain)
        .disabled(done)
    }
}

// MARK: - CHAIN -- Build consequence timeline

struct ChainView: View {
    let round: Round
    let onResult: (Bool) -> Void

    @State private var chain: [Int] = []
    @State private var done = false
    @State private var correct: Bool? = nil

    private var used: Set<Int> { Set(chain) }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(round.setup)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(P.dim)

            Text(round.chainPrompt)
                .font(.system(size: 12, weight: .black))
                .foregroundColor(P.teal)

            // Built chain
            VStack(spacing: 4) {
                ForEach(Array(chain.enumerated()), id: \.offset) { pos, order in
                    let isRight = done && order == pos
                    let isWrong = done && order != pos
                    HStack(spacing: 8) {
                        Text("\(pos + 1)")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(RoundedRectangle(cornerRadius: 8).fill(done ? (isRight ? P.teal : P.red) : P.main))

                        HStack(spacing: 4) {
                            Text(round.steps[order].text)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(P.txt)
                            if done {
                                Image(systemName: isRight ? "checkmark" : "xmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(isRight ? P.teal : P.red)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 12).fill(done ? (isRight ? P.teal.opacity(0.1) : P.red.opacity(0.1)) : P.sf))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(done ? (isRight ? P.teal.opacity(0.5) : P.red.opacity(0.5)) : P.bdr, lineWidth: 2))
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                if !chain.isEmpty && !done {
                    Button(action: { chain.removeLast() }) {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(P.mut)
                            Text("undo")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(P.mut)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(minHeight: 40)
            .padding(.bottom, 8)

            // Available steps
            if !done {
                VStack(spacing: 6) {
                    ForEach(round.shuffledOrder, id: \.self) { order in
                        if !used.contains(order) {
                            Button(action: {
                                SoundManager.shared.chain()
                                HapticsManager.shared.light()
                                withAnimation(.spring(response: 0.3)) {
                                    chain.append(order)
                                }
                            }) {
                                Text(round.steps[order].text)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(P.txt)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(P.sf))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(P.bdr, lineWidth: 2))
                                    .shadow(color: P.bdr.opacity(0.5), radius: 0, x: 0, y: 3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            if !done && chain.count == round.steps.count {
                HStack {
                    Spacer()
                    GButton(text: "lock it in", color: P.teal) {
                        let ok = chain.enumerated().allSatisfy { $0.element == $0.offset }
                        correct = ok
                        done = true
                        onResult(ok)
                    }
                    Spacer()
                }
            }
        }
    }
}

// MARK: - SLIDER -- Set probability

struct SliderView: View {
    let round: Round
    let onResult: (Bool) -> Void

    @State private var value: Double = 50
    @State private var done = false
    @State private var correct: Bool? = nil

    var body: some View {
        VStack(spacing: 6) {
            Text(round.setup)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(P.dim)

            Text(round.detail)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(P.mut)

            Text(round.question)
                .font(.system(size: 14, weight: .black))
                .foregroundColor(P.teal)
                .padding(.bottom, 8)

            Slider(value: $value, in: 0...100, step: 1) {
                Text("")
            }
            .tint(P.teal)
            .disabled(done)
            .onChange(of: value) { _, _ in SoundManager.shared.slide() }

            Text("\(Int(value))%")
                .font(.system(size: 36, weight: .black))
                .foregroundColor(done ? (correct == true ? P.teal : P.red) : P.main)
                .animation(.easeInOut(duration: 0.3), value: done)

            if done {
                HStack(spacing: 4) {
                    Text("Reality:")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(P.dim)
                    Text("~\(round.answer)%")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(P.gold)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 12).fill(P.sf).shadow(color: P.bdr.opacity(0.5), radius: 0, x: 0, y: 3))
            }

            if !done {
                GButton(text: "lock answer", color: P.teal) {
                    let ok = abs(Int(value) - round.answer) <= round.tolerance
                    correct = ok
                    done = true
                    onResult(ok)
                }
            }
        }
    }
}

// MARK: - REWRITE -- Fix the broken argument

struct RewriteView: View {
    let round: Round
    let onResult: (Bool) -> Void

    @State private var fixed = false
    @State private var done = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(round.setup)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(P.dim)

            HStack(spacing: 4) {
                ForEach(Array(round.original.enumerated()), id: \.offset) { i, phrase in
                    let isTarget = i == round.fixFrom
                    let showFix = isTarget && fixed
                    Text(showFix ? round.fixTo : phrase)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(showFix ? P.teal : (isTarget && !done ? P.red : P.txt))
                        .strikethrough(isTarget && !showFix, color: P.red)
                        .padding(.horizontal, isTarget ? 6 : 0)
                        .padding(.vertical, isTarget ? 2 : 0)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(showFix ? P.teal.opacity(0.1) : (isTarget && !done ? P.red.opacity(0.06) : .clear))
                        )
                        .animation(.easeInOut(duration: 0.4), value: fixed)
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 16).fill(P.sf).shadow(color: P.bdr.opacity(0.5), radius: 0, x: 0, y: 4))

            HStack(spacing: 4) {
                Image(systemName: done ? "checkmark" : "pencil")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(P.mut)
                Text(done ? "Fixed!" : "Tap to fix the flawed reasoning")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(P.mut)
            }

            if !done {
                GButton(text: "fix it", color: P.mag) {
                    SoundManager.shared.reveal()
                    HapticsManager.shared.success()
                    fixed = true
                    done = true
                    onResult(true)
                }
            }
        }
    }
}

// MARK: - PERSUADE -- Build argument in order

struct PersuadeView: View {
    let round: Round
    let onResult: (Bool) -> Void

    @State private var placed: [Int] = []
    @State private var done = false
    @State private var score: Int? = nil

    private var used: Set<Int> { Set(placed) }

    private let tagColors: [String: Color] = [
        "hook": P.mag, "problem": P.red, "stakes": Color(hex: "ff9e00"),
        "solution": P.teal, "evidence": P.blue, "action": P.lime
    ]
    private let tagLabels: [String: String] = [
        "hook": "Hook", "problem": "Problem", "stakes": "Stakes",
        "solution": "Solution", "evidence": "Proof", "action": "Action"
    ]
    private let tagSymbols: [String: String] = [
        "hook": "link", "problem": "exclamationmark.circle.fill", "stakes": "exclamationmark.triangle.fill",
        "solution": "lightbulb.fill", "evidence": "chart.bar.fill", "action": "hand.point.right.fill"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(round.setup)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(P.dim)

            HStack(spacing: 4) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(P.gold)
                Text("Tap blocks in the most persuasive order")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(P.gold)
            }

            if done {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 3) {
                        ForEach(["hook", "problem", "stakes", "solution", "evidence", "action"], id: \.self) { tag in
                            HStack(spacing: 2) {
                                Image(systemName: tagSymbols[tag] ?? "circle.fill")
                                    .font(.system(size: 7, weight: .black))
                                    .foregroundColor(tagColors[tag] ?? P.txt)
                                Text(tagLabels[tag] ?? tag)
                                    .font(.system(size: 8, weight: .black))
                                    .foregroundColor(tagColors[tag] ?? P.txt)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill((tagColors[tag] ?? P.txt).opacity(0.12)))
                        }
                    }
                }
            }

            // Built sequence
            VStack(spacing: 4) {
                ForEach(Array(placed.enumerated()), id: \.offset) { pos, bi in
                    let block = round.blocks[bi]
                    let isRight = done && block.order == pos
                    let isWrong = done && block.order != pos
                    HStack(spacing: 6) {
                        Text("\(pos + 1)")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(RoundedRectangle(cornerRadius: 6).fill(done ? (isRight ? P.teal : P.red) : P.main))

                        HStack(spacing: 4) {
                            Text(block.text)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(done ? (isRight ? P.teal : P.txt) : P.txt)
                                .strikethrough(isWrong)
                                .opacity(isWrong ? 0.6 : 1)

                            if done {
                                Text(block.tag)
                                    .font(.system(size: 8, weight: .black))
                                    .foregroundColor(tagColors[block.tag] ?? P.txt)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 1)
                                    .background(Capsule().fill((tagColors[block.tag] ?? P.txt).opacity(0.15)))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(done ? (isRight ? P.teal.opacity(0.07) : P.red.opacity(0.05)) : P.sf)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(done ? (isRight ? P.teal.opacity(0.4) : P.red.opacity(0.3)) : P.bdr, lineWidth: 2))
                        )
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                if !placed.isEmpty && !done {
                    Button(action: { placed.removeLast() }) {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(P.mut)
                            Text("undo")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(P.mut)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(minHeight: 20)

            // Available blocks
            if !done {
                VStack(spacing: 5) {
                    ForEach(Array(round.blocks.enumerated()), id: \.element.id) { i, block in
                        if !used.contains(i) {
                            Button(action: {
                                SoundManager.shared.chain()
                                HapticsManager.shared.light()
                                withAnimation(.spring(response: 0.3)) {
                                    placed.append(i)
                                }
                            }) {
                                Text(block.text)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(P.txt)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 9)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(P.sf))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(P.bdr, lineWidth: 2))
                                    .shadow(color: P.bdr.opacity(0.5), radius: 0, x: 0, y: 3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            if !done && placed.count == round.blocks.count {
                HStack {
                    Spacer()
                    GButton(text: "deliver it", color: P.gold) {
                        var correct = 0
                        for (pos, bi) in placed.enumerated() {
                            if round.blocks[bi].order == pos { correct += 1 }
                        }
                        score = correct
                        done = true
                        onResult(correct >= Int(ceil(Double(round.blocks.count) * 0.65)))
                    }
                    Spacer()
                }
            }

            // Optimal order reveal
            if done {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(P.gold)
                        Text("Optimal order:")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(P.gold)
                    }

                    ForEach(round.blocks.sorted(by: { $0.order < $1.order })) { block in
                        HStack(spacing: 6) {
                            HStack(spacing: 2) {
                                Image(systemName: tagSymbols[block.tag] ?? "circle.fill")
                                    .font(.system(size: 7, weight: .black))
                                    .foregroundColor(tagColors[block.tag] ?? P.txt)
                                Text(tagLabels[block.tag] ?? block.tag)
                                    .font(.system(size: 8, weight: .black))
                                    .foregroundColor(tagColors[block.tag] ?? P.txt)
                            }
                            .frame(minWidth: 55)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 1)
                            .background(Capsule().fill((tagColors[block.tag] ?? P.txt).opacity(0.15)))

                            Text(block.text)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(P.dim)
                                .lineSpacing(2)
                        }
                    }
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(P.sf2)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(P.bdr, lineWidth: 2))
                )
            }
        }
    }
}

// MARK: - CLASSIC -- Multi-choice

struct ClassicView: View {
    let round: Round
    let onResult: (Bool) -> Void

    @State private var selected: Int? = nil
    @State private var done = false

    private let answerColors: [Color] = [P.red, P.blue, P.green, P.yellow]
    private let answerShapes = ["circle.fill", "diamond.fill", "triangle.fill", "star.fill"]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: round.emoji)
                    .font(.system(size: 20))
                    .foregroundColor(P.main)
                    .frame(width: 44, height: 44)
                    .background(RoundedRectangle(cornerRadius: 14).fill(P.sf).shadow(color: P.bdr.opacity(0.5), radius: 0, x: 0, y: 4))

                VStack(alignment: .leading, spacing: 2) {
                    Text(round.name)
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(P.mut)
                    Text(round.q)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(P.txt)
                        .lineSpacing(2)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(P.sf)
                        .shadow(color: P.bdr.opacity(0.5), radius: 0, x: 0, y: 4)
                )
            }

            Text(round.prompt)
                .font(.system(size: 13, weight: .black))
                .foregroundColor(P.teal)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(Array(round.options.enumerated()), id: \.offset) { i, opt in
                    let isSel = selected == i
                    let isCorrect = i == round.correctAnswer

                    Button(action: {
                        guard !done else { return }
                        SoundManager.shared.tap()
                        HapticsManager.shared.light()
                        selected = i
                        done = true
                        onResult(i == round.correctAnswer)
                    }) {
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: answerShapes[i])
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.8))
                            Text(opt)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .lineSpacing(2)
                            if done && isCorrect {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(done ? (isCorrect ? P.teal : (isSel ? P.red.opacity(0.6) : answerColors[i].opacity(0.12))) : answerColors[i])
                                .shadow(color: (done && !isCorrect ? Color.clear : answerColors[i].opacity(0.5)), radius: 0, x: 0, y: done ? 0 : 5)
                        )
                        .opacity(done && !isCorrect && !isSel ? 0.12 : 1)
                    }
                    .buttonStyle(.plain)
                    .disabled(done)
                }
            }
        }
    }
}

// MARK: - FlowLayout helper

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(in: proposal.width ?? 0, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(in: bounds.width, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func layout(in width: CGFloat, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxHeight = max(maxHeight, y + rowHeight)
        }

        return (positions, CGSize(width: width, height: maxHeight))
    }
}
