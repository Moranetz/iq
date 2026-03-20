# 🧠 CORTEX

### The reasoning game where the mechanic IS the skill.

> Most "educational" apps are quizzes wearing costumes. CORTEX is different.  
> You don't pick answers. You **weigh evidence**, **build argument chains**, **calibrate your intuition**, and **construct persuasive messages** — the interaction itself teaches the concept.

---

## The Problem

**Kids can't think critically — and nothing teaches them to.**

Schools teach *what* to think. Social media rewards *speed* over *accuracy*. Every day, teens encounter survivorship bias, false dilemmas, anchoring tricks, and correlation-causation errors — and they have zero training to recognize them.

The apps that try? They're multiple-choice quizzes with confetti. You either already know the answer or you guess. Guessing isn't learning.

## What Happens If We Don't Fix This

A generation that can't distinguish evidence from anecdote. That falls for every anchoring trick, every appeal to popularity, every sunk cost trap. That can't construct a persuasive argument or predict second-order consequences.

These aren't abstract skills. This is whether your kid can tell when they're being manipulated.

---

## CORTEX — 7 Mechanics That Teach Through Play

Each game mechanic maps directly to a reasoning skill. You don't learn about the concept — you **perform** it.

| Mechanic | You Do | You Learn |
|---|---|---|
| 🔬 **Find the Flaw** | Tap the exact broken phrase in a statement | Precision — *where* is the logic broken, not just *that* it's broken |
| ⚖️ **Weigh Evidence** | Sort evidence cards to tip a visual scale | Not all evidence is equal — learn to rank by weight |
| 🔗 **Build the Chain** | Order consequence cards into a cause-effect timeline | Second-order thinking — "then what? and then what?" |
| 🎚️ **Calibrate** | Set a probability slider, then see reality | Your intuition vs math — base rates, gambler's fallacy |
| 🎤 **Build Your Case** | Arrange argument blocks in persuasive order | Persuasion architecture — Hook → Problem → Stakes → Solution → Evidence → Action |
| ✏️ **Fix It** | Watch a flawed argument get rewritten in real-time | See *exactly* what makes reasoning break and how to repair it |
| 🎯 **Spot It** | Fast-fire Kahoot-style colored answer blocks | Pattern recognition under time pressure |

### 23 Concepts Taught

Survivorship Bias · Anecdote ≠ Evidence · Ad Hominem · False Dilemma · Cherry Picking · Correlation ≠ Causation · Confounding Variables · Sunk Cost Fallacy · Confirmation Bias · Anchoring Bias · Availability Heuristic · Bandwagon Effect · Base Rate Neglect · Gambler's Fallacy · Goodhart's Law · Second-Order Effects · Cobra Effect · Perverse Incentives · Appeal to Popularity · Persuasive Structure · Evidence Hierarchy · Audience-First Persuasion · Hook → Stakes → Solution

---

## What We Stole (And From Whom)

Good artists borrow. Great artists steal. Here's our receipt:

**From Duolingo** — 3D buttons with thick bottom shadows, mascot with speech bubbles and emotional states (heart eyes at streak 4+, sad face on wrong answers), progress bar, hearts system, Nunito font, rounded everything, minimal text.

**From Kahoot** — Each answer option is a distinct bold color (red ●, blue ◆, green ▲, yellow ★) in a 2×2 grid. The color IS the option identity. Wrong answers fade to 12% opacity while correct scales up.

**From Brilliant** — The "aha moment" reveal with blur-to-sharp animation. Mascot as learning guide, not decoration. The insight card shows the concept name as the visual hero, one sentence of explanation, nothing more.

**What's new** — Nobody combined these into a game where the interaction mechanic and the reasoning skill are the same thing. Sorting evidence on a scale *is* evidence weighing. Building a consequence chain *is* systems thinking. Setting a probability slider *is* calibration. The game doesn't describe the skill. It **is** the skill.

---

## Design Philosophy

**Visual hierarchy: Icon → Color → Shape → then text.**
Every screen leads with a visual element before any words appear. Answer options are identified by color and shape, not letter labels. The mascot's face communicates feedback faster than text ever could.

**One sentence per insight. Period.**
The old version had 3-sentence explanations with a "use this IRL" paragraph. Now: concept name (big, centered) + one line. Kids absorb the name and the line. That's all they need.

**The mechanic teaches. The explanation confirms.**
You experience the concept through interaction FIRST. The insight card after just names what you already did. This is Bloom's taxonomy: apply → then label.

---

## Tech Stack

- **React 18** — Single JSX file, no external component libraries
- **Canvas API** — Brain mascot with real-time animation (blinking, bobbing, heart eyes, orbiting sparkles, crown at level 7)
- **Web Audio API** — Synthesized sounds with escalating pitch on combos (no audio files)
- **Web Vibration API** — Haptic feedback on mobile
- **CSS Animations** — Confetti with particle trails, screen shake, XP fly, combo slam, insight reveal blur
- **Vite** — Build and dev server

Zero dependencies beyond React. No Tailwind. No component library. No state management library. Everything is self-contained.

---

## Run It

```bash
git clone https://github.com/YOUR_USERNAME/cortex.git
cd cortex
npm install
npm run dev
```

Open `http://localhost:5173` — works best on mobile viewport (430px) but scales to any screen.

## Deploy

```bash
npm run build
```

The `dist/` folder is ready for Vercel, Netlify, or any static host.

---

## Project Structure

```
cortex/
├── index.html          # Entry point with meta tags
├── package.json        # Vite + React
├── vite.config.js      # Build config
└── src/
    ├── main.jsx        # React mount
    └── App.jsx         # Everything — 900 lines, one file
```

Yes, it's one file. Intentionally. This is a prototype that proves a concept. When it becomes a product, it splits into components, question banks become API-driven, and persistence gets wired in.

---

## What's Next

- [ ] **Persistent storage** — XP, level, streak survive across sessions
- [ ] **API-generated questions** — Infinite fresh scenarios via Claude API
- [ ] **Daily challenge** — Cross-session streak with escalating rewards  
- [ ] **Spaced repetition** — Concepts you got wrong resurface more often
- [ ] **Social sharing** — Challenge a friend to beat your score
- [ ] **More persuasion mechanics** — Reframe mode, audience analysis, objection handling
- [ ] **Drag-and-drop** — True drag interactions for chain building and evidence sorting
- [ ] **Native iOS** — SwiftUI port with Core Haptics and Rive animations

---

## Why This Matters

Every reasoning skill in this game transfers directly to real decisions:

- **Survivorship bias** → Don't invest because your barber got lucky
- **Base rate neglect** → Don't panic at a positive test for a rare disease  
- **Second-order effects** → Predict what actually happens when a city makes transit free
- **Persuasive structure** → Get your parents to raise your allowance (seriously)
- **Sunk cost fallacy** → Quit the game you hate after 2,000 hours
- **Anchoring bias** → Don't fall for "was $200, now $80!"

These aren't academic concepts. They're the difference between thinking clearly and getting played.

---

<p align="center">
  <b>CORTEX</b> — think smarter ✨🧠
</p>
