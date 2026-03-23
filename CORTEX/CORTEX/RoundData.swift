import SwiftUI

enum RoundType: String, CaseIterable {
    case highlight, scale, chain, slider, rewrite, persuade, classic

    var label: String {
        switch self {
        case .highlight: return "find the flaw"
        case .scale: return "weigh evidence"
        case .chain: return "build the chain"
        case .slider: return "calibrate"
        case .rewrite: return "fix it"
        case .persuade: return "build your case"
        case .classic: return "spot it"
        }
    }

    var icon: String {
        switch self {
        case .highlight: return "magnifyingglass"
        case .scale: return "scalemass.fill"
        case .chain: return "link"
        case .slider: return "slider.horizontal.3"
        case .rewrite: return "pencil"
        case .persuade: return "mic.fill"
        case .classic: return "target"
        }
    }

    var sfSymbol: String {
        icon
    }

    var menuName: String {
        switch self {
        case .highlight: return "Find the Flaw"
        case .scale: return "Weigh Evidence"
        case .chain: return "Build the Chain"
        case .slider: return "Calibrate"
        case .rewrite: return "Fix It"
        case .persuade: return "Build Your Case"
        case .classic: return "Spot It"
        }
    }

    var menuDesc: String {
        switch self {
        case .highlight: return "Tap the broken logic"
        case .scale: return "Sort what matters"
        case .chain: return "Predict consequences"
        case .slider: return "Test your intuition"
        case .rewrite: return "Repair broken arguments"
        case .persuade: return "Master persuasion order"
        case .classic: return "Quick fire multi-choice"
        }
    }

    var color: Color {
        switch self {
        case .highlight: return P.mag
        case .scale: return P.blue
        case .chain: return P.lime
        case .slider: return Color(hex: "2dd4bf")
        case .rewrite: return Color(hex: "ff9e00")
        case .persuade: return P.gold
        case .classic: return P.red
        }
    }
}

struct Round: Identifiable {
    let id = UUID()
    let type: RoundType

    // Highlight
    var setup: String = ""
    var text: [String] = []
    var flawIdx: [Int] = []

    // Scale
    var leftLabel: String = ""
    var leftIcon: String = ""
    var rightLabel: String = ""
    var rightIcon: String = ""
    var cards: [EvidenceCard] = []

    // Chain
    var chainPrompt: String = ""
    var steps: [ChainStep] = []
    var shuffledOrder: [Int] = []

    // Slider
    var detail: String = ""
    var question: String = ""
    var answer: Int = 50
    var tolerance: Int = 5

    // Rewrite
    var original: [String] = []
    var fixFrom: Int = 0
    var fixTo: String = ""

    // Persuade
    var blocks: [PersuadeBlock] = []

    // Classic
    var emoji: String = ""
    var name: String = ""
    var q: String = ""
    var prompt: String = ""
    var options: [String] = []
    var correctAnswer: Int = 0

    // Common
    var concept: String = ""
    var lesson: String = ""
    var explain: String = ""
}

struct EvidenceCard: Identifiable {
    let id = UUID()
    let text: String
    let side: String // "left" or "right"
    let weight: Int
}

struct ChainStep: Identifiable {
    let id = UUID()
    let text: String
    let order: Int
}

struct PersuadeBlock: Identifiable {
    let id = UUID()
    let text: String
    let tag: String
    let order: Int
}

let allRounds: [Round] = [
    // HIGHLIGHT
    Round(type: .highlight, setup: "A TikToker says:", text: ["This supplement", "cured my anxiety", "in 3 days!", "Link in bio"], flawIdx: [1, 2], concept: "Anecdote \u{2260} Evidence", explain: "One person's story + they're selling it = zero evidence"),
    Round(type: .highlight, setup: "Someone argues:", text: ["You can't trust her research", "because she went to", "a bad school"], flawIdx: [2], concept: "Ad Hominem", explain: "School doesn't determine research quality. Attack the WORK not the person."),
    Round(type: .highlight, setup: "A social media post:", text: ["If you're not sharing this,", "you're part of", "the problem"], flawIdx: [0, 2], concept: "False Dilemma", explain: "Donating, volunteering, talking privately \u{2014} many options besides sharing."),
    Round(type: .highlight, setup: "Grandpa says:", text: ["We walked to school in snow!", "Kids today", "are soft"], flawIdx: [2], concept: "Cherry Picking", explain: "Selecting one memory to judge an entire generation."),

    // SCALE
    Round(type: .scale, setup: "Restaurant packed every night. Is the food actually good?", leftLabel: "Good food", leftIcon: "hand.thumbsup.fill", rightLabel: "Just popular", rightIcon: "chart.bar.fill", cards: [
        EvidenceCard(text: "Long wait times", side: "left", weight: 1),
        EvidenceCard(text: "Near the train station", side: "right", weight: 2),
        EvidenceCard(text: "Great reviews from food critics", side: "left", weight: 3),
        EvidenceCard(text: "Only restaurant on the block", side: "right", weight: 2),
        EvidenceCard(text: "Cheap prices", side: "right", weight: 1),
    ], concept: "Popularity \u{2260} Quality", explain: "Crowds prove demand, not quality. Location, price, and hype matter too."),
    Round(type: .scale, setup: "New brain supplement \u{2014} 1M sold! Does it work?", leftLabel: "Probably works", leftIcon: "pill.fill", rightLabel: "No real proof", rightIcon: "magnifyingglass", cards: [
        EvidenceCard(text: "No clinical trial done", side: "right", weight: 3),
        EvidenceCard(text: "Millions of sales", side: "left", weight: 1),
        EvidenceCard(text: "Influencer testimonials", side: "left", weight: 1),
        EvidenceCard(text: "Placebo effect explains reviews", side: "right", weight: 2),
        EvidenceCard(text: "Company profits from sales", side: "right", weight: 2),
    ], concept: "Evidence Hierarchy", explain: "Sales = marketing success. Reviews = placebo. Only trials prove anything."),

    // CHAIN
    Round(type: .chain, setup: "A city makes all transit FREE to reduce traffic", chainPrompt: "Build what happens next", steps: [
        ChainStep(text: "Walkers & bikers switch to buses", order: 0),
        ChainStep(text: "Buses get overcrowded", order: 1),
        ChainStep(text: "Service quality drops", order: 2),
        ChainStep(text: "Drivers still don't switch", order: 3),
    ], shuffledOrder: [2, 0, 3, 1], concept: "Second-Order Effects", explain: "Free doesn't just attract drivers. EVERYONE switches. Overcrowding kills quality."),
    Round(type: .chain, setup: "A town pays bounty for each dead cobra", chainPrompt: "What happens over time?", steps: [
        ChainStep(text: "People start killing cobras for money", order: 0),
        ChainStep(text: "Entrepreneurs start BREEDING cobras", order: 1),
        ChainStep(text: "Government cancels the program", order: 2),
        ChainStep(text: "Breeders release cobras \u{2014} MORE than before", order: 3),
    ], shuffledOrder: [1, 3, 0, 2], concept: "Cobra Effect", explain: "Incentivizing the fix created MORE of the problem."),
    Round(type: .chain, setup: "School publishes student test rankings publicly", chainPrompt: "Chain of consequences", steps: [
        ChainStep(text: "Students focus on test scores only", order: 0),
        ChainStep(text: "Cheating increases", order: 1),
        ChainStep(text: "Curiosity and creativity drop", order: 2),
        ChainStep(text: "Bottom-ranked students give up entirely", order: 3),
    ], shuffledOrder: [3, 1, 0, 2], concept: "Perverse Incentives", explain: "When rank = status, students game the metric. Real learning disappears."),

    // SLIDER
    Round(type: .slider, setup: "Priya tested positive for a rare disease", detail: "Disease affects 1 in 10,000 people. Test is 99% accurate.", question: "What's the chance Priya actually has it?", answer: 1, tolerance: 8, concept: "Base Rate Neglect", explain: "1 in 10,000 \u{2192} ~100 false positives per 1 true positive. She's probably fine."),
    Round(type: .slider, setup: "You flipped 5 heads in a row", detail: "Fair coin. No tricks.", question: "Chance the next flip is tails?", answer: 50, tolerance: 5, concept: "Gambler's Fallacy", explain: "Each flip is 50/50. Coins don't have memory."),
    Round(type: .slider, setup: "You see a plane crash on the news", detail: "Car deaths: 1 in 100. Plane deaths: 1 in 11,000.", question: "How dangerous is flying vs driving? (100 = equally dangerous)", answer: 1, tolerance: 10, concept: "Availability Heuristic", explain: "Dramatic events FEEL likely. Flying is 100x safer than driving."),

    // REWRITE
    Round(type: .rewrite, setup: "Your friend says:", original: ["I have 2,000 hours", "so I can't quit now", "\u{2014} that'd be wasted"], fixFrom: 1, fixTo: "but past hours are gone either way", concept: "Sunk Cost Fallacy", explain: "Past time is gone whether you stay or leave. Only future fun counts."),
    Round(type: .rewrite, setup: "Manager says:", original: ["Tickets per hour up 40%!", "System works!", "Keep pushing!"], fixFrom: 1, fixTo: "But are problems actually solved?", concept: "Goodhart's Law", explain: "When a measure becomes a target, it gets gamed."),
    Round(type: .rewrite, setup: "An ad says:", original: ["9 out of 10 kids", "prefer PizzaBlast!", "It's the best!"], fixFrom: 2, fixTo: "But popular \u{2260} best quality", concept: "Appeal to Popularity", explain: "Most-chosen \u{2260} best. Marketing shapes preference."),

    // PERSUADE
    Round(type: .persuade, setup: "You want to convince your school to allow phones at lunch", blocks: [
        PersuadeBlock(text: "Students could use educational apps during breaks", tag: "solution", order: 3),
        PersuadeBlock(text: "72% of teens say phone bans increase stress", tag: "evidence", order: 4),
        PersuadeBlock(text: "Most schools ban phones \u{2014} but are students actually happier?", tag: "hook", order: 0),
        PersuadeBlock(text: "Allow supervised phone use during lunch only", tag: "action", order: 5),
        PersuadeBlock(text: "Without any break, focus drops 40% after lunch", tag: "stakes", order: 2),
        PersuadeBlock(text: "Students need mental resets between intense classes", tag: "problem", order: 1),
    ], concept: "Persuasive Structure", explain: "Hook \u{2192} Problem \u{2192} Stakes \u{2192} Solution \u{2192} Evidence \u{2192} Action. Most people start with the solution. Pros start with the pain."),
    Round(type: .persuade, setup: "Convince your parents to raise your allowance", blocks: [
        PersuadeBlock(text: "I'll track every dollar in a spreadsheet", tag: "evidence", order: 4),
        PersuadeBlock(text: "I've been doing extra chores for 3 months with no raise", tag: "hook", order: 0),
        PersuadeBlock(text: "Could we try $15/week for one month as a test?", tag: "action", order: 5),
        PersuadeBlock(text: "I can't even save for my own things at this rate", tag: "problem", order: 1),
        PersuadeBlock(text: "Learning money management NOW prevents problems later", tag: "solution", order: 3),
        PersuadeBlock(text: "Without practice, teens make worse financial decisions as adults", tag: "stakes", order: 2),
    ], concept: "Persuasion Architecture", explain: "Don't start with what you WANT. Start with what THEY care about. Lead with a track record, build the case, then ask."),
    Round(type: .persuade, setup: "Convince classmates to join your recycling project", blocks: [
        PersuadeBlock(text: "Our school throws away 200 lbs of recyclables per week", tag: "hook", order: 0),
        PersuadeBlock(text: "Sign up at the booth \u{2014} takes 30 seconds", tag: "action", order: 5),
        PersuadeBlock(text: "That's 10,000 lbs per year going to landfills", tag: "stakes", order: 2),
        PersuadeBlock(text: "3 other schools cut waste 60% in one semester", tag: "evidence", order: 4),
        PersuadeBlock(text: "Most of it could be recycled with just two extra bins", tag: "solution", order: 3),
        PersuadeBlock(text: "Nobody's doing anything about it yet", tag: "problem", order: 1),
    ], concept: "Hook \u{2192} Stakes \u{2192} Solution", explain: "Start shocking (200 lbs!), make it urgent (10,000/year!), then make it easy (2 bins, 30 seconds)."),
    Round(type: .persuade, setup: "Convince a friend that a new game is worth trying", blocks: [
        PersuadeBlock(text: "Remember how bored you said you were with shooters?", tag: "hook", order: 0),
        PersuadeBlock(text: "It has a free demo \u{2014} try 20 minutes, no commitment", tag: "action", order: 5),
        PersuadeBlock(text: "This game has 95% positive reviews from people who hate RPGs", tag: "evidence", order: 4),
        PersuadeBlock(text: "You keep replaying the same 3 games on loop", tag: "problem", order: 1),
        PersuadeBlock(text: "It combines the parts you like \u{2014} strategy + co-op \u{2014} without the grind", tag: "solution", order: 3),
        PersuadeBlock(text: "You'll run out of content in those games eventually", tag: "stakes", order: 2),
    ], concept: "Audience-First Persuasion", explain: "Start with THEIR frustration, not your enthusiasm. Make it about what THEY want, then offer the bridge."),

    // CLASSIC
    Round(type: .classic, emoji: "person.fill", name: "Marcus", q: "Barber made $40K on crypto. Putting in $5K", prompt: "The trap:", options: ["Only hears winners, not losers", "Crypto is always bad", "Barbers can't invest", "He should invest more"], correctAnswer: 0, concept: "Survivorship Bias", lesson: "Losers don't brag. You only see survivors."),
    Round(type: .classic, emoji: "building.columns.fill", name: "Principal", q: "Phone-free schools = better grades. Banning phones!", prompt: "Missing:", options: ["Those schools differ in many ways", "Phones = bad grades always", "Schools shouldn't have rules", "Studies prove the link"], correctAnswer: 0, concept: "Confounding Variables", lesson: "Phone-free schools may just be richer schools."),
    Round(type: .classic, emoji: "tag.fill", name: "Shopping", q: "Jacket was $200, now $80! Amazing deal!", prompt: "The trick:", options: ["$200 anchored you \u{2014} $80 may still be overpriced", "$120 off is always good", "Original price = quality", "Sales are always genuine"], correctAnswer: 0, concept: "Anchoring Bias", lesson: "The first number tricks you into thinking $80 is cheap."),
    Round(type: .classic, emoji: "person.3.fill", name: "Group Project", q: "Everyone agrees with the loudest person. No one objects.", prompt: "What's happening:", options: ["Groupthink \u{2014} conformity kills debate", "Loud person is smartest", "Agreeing = good teamwork", "Silence = agreement"], correctAnswer: 0, concept: "Bandwagon Effect", lesson: "Groups often follow the loudest, not the smartest."),
]
