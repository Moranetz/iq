import SwiftUI
import UIKit

struct BrainView: UIViewRepresentable {
    let lvl: Int
    let streak: Int
    let mood: Int // -1 sad, 0 neutral, 1 happy
    let size: CGFloat
    var message: String?

    func makeUIView(context: Context) -> BrainCanvasView {
        let view = BrainCanvasView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        view.backgroundColor = .clear
        view.isOpaque = false
        view.lvl = lvl
        view.streak = streak
        view.mood = mood
        view.message = message
        return view
    }

    func updateUIView(_ uiView: BrainCanvasView, context: Context) {
        uiView.lvl = lvl
        uiView.streak = streak
        uiView.mood = mood
        uiView.message = message
    }
}

class BrainCanvasView: UIView {
    var lvl: Int = 1
    var streak: Int = 0
    var mood: Int = 0
    var message: String?
    private var displayLink: CADisplayLink?
    private var time: Double = 0

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil && displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(tick))
            displayLink?.add(to: .main, forMode: .common)
        }
    }

    override func removeFromSuperview() {
        displayLink?.invalidate()
        displayLink = nil
        super.removeFromSuperview()
    }

    @objc private func tick() {
        time += 0.035
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let T = time
        let cx = rect.midX
        let cy = rect.midY
        let s = min(rect.width, rect.height) * 0.4

        // Glow
        let glowR = s * (1.4 + CGFloat(min(lvl, 10)) * 0.05)
        let glowColor: UIColor = streak >= 5 ? UIColor(P.gold) : streak >= 3 ? UIColor(P.teal) : UIColor(P.main)
        let glow = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [glowColor.withAlphaComponent(0.19).cgColor, UIColor.clear.cgColor] as CFArray, locations: [0, 1])!
        ctx.drawRadialGradient(glow, startCenter: CGPoint(x: cx, y: cy), startRadius: s * 0.2, endCenter: CGPoint(x: cx, y: cy), endRadius: glowR, options: [])

        ctx.saveGState()
        ctx.translateBy(x: cx, y: cy)

        // Bob
        let bob: CGFloat = mood == 1 ? CGFloat(sin(T * 14) * 5 * max(0, 1 - fmod(T, 1))) : CGFloat(sin(T * 1.5) * 2)
        ctx.translateBy(x: 0, y: bob)

        // Brain shape
        let brainGrad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [
            UIColor(hex: "e2b4ff").cgColor,
            UIColor(hex: "c77dff").cgColor,
            UIColor(hex: "7c3aed").cgColor
        ] as CFArray, locations: [0, 0.5, 1])!

        let brainPath = CGMutablePath()
        brainPath.move(to: CGPoint(x: 0, y: -s * 0.88))
        brainPath.addCurve(to: CGPoint(x: -s * 0.9, y: 0), control1: CGPoint(x: -s * 0.55, y: -s * 0.96), control2: CGPoint(x: -s * 0.96, y: -s * 0.55))
        brainPath.addCurve(to: CGPoint(x: -s * 0.18, y: s * 0.8), control1: CGPoint(x: -s * 0.98, y: s * 0.4), control2: CGPoint(x: -s * 0.68, y: s * 0.85))
        brainPath.addCurve(to: CGPoint(x: s * 0.18, y: s * 0.8), control1: CGPoint(x: 0, y: s * 0.84), control2: CGPoint(x: 0, y: s * 0.84))
        brainPath.addCurve(to: CGPoint(x: s * 0.9, y: 0), control1: CGPoint(x: s * 0.68, y: s * 0.85), control2: CGPoint(x: s * 0.98, y: s * 0.4))
        brainPath.addCurve(to: CGPoint(x: 0, y: -s * 0.88), control1: CGPoint(x: s * 0.96, y: -s * 0.55), control2: CGPoint(x: s * 0.55, y: -s * 0.96))

        ctx.addPath(brainPath)
        ctx.clip()
        ctx.drawRadialGradient(brainGrad, startCenter: CGPoint(x: -s * 0.12, y: -s * 0.2), startRadius: s * 0.1, endCenter: CGPoint(x: 0, y: s * 0.1), endRadius: s * 1.1, options: [])
        ctx.resetClip()

        // Outline
        ctx.addPath(brainPath)
        ctx.setStrokeColor(UIColor(hex: "6d28d9").cgColor)
        ctx.setLineWidth(2)
        ctx.strokePath()

        // Eyes
        let eY: CGFloat = -s * 0.18
        let eR: CGFloat = s * 0.17
        let blink: CGFloat = sin(T * 0.35) > 0.96 ? 0.1 : 1.0
        let lk = CGFloat(sin(T * 0.6) * 1.5)

        for side: CGFloat in [-1, 1] {
            let ex = side * s * 0.28
            // White
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.fillEllipse(in: CGRect(x: ex - eR * 1.1, y: eY - eR * blink * 1.1, width: eR * 2.2, height: eR * blink * 2.2))

            if blink > 0.5 {
                if mood == 1 && streak >= 4 {
                    // Heart eyes
                    let hs = eR * 0.65
                    let heartPath = CGMutablePath()
                    heartPath.move(to: CGPoint(x: ex + lk, y: eY + hs * 0.3))
                    heartPath.addCurve(to: CGPoint(x: ex + lk, y: eY + hs * 0.7), control1: CGPoint(x: ex + lk - hs * 0.5, y: eY - hs * 0.5), control2: CGPoint(x: ex + lk - hs, y: eY + hs * 0.1))
                    heartPath.addCurve(to: CGPoint(x: ex + lk, y: eY + hs * 0.3), control1: CGPoint(x: ex + lk + hs, y: eY + hs * 0.1), control2: CGPoint(x: ex + lk + hs * 0.5, y: eY - hs * 0.5))
                    ctx.addPath(heartPath)
                    ctx.setFillColor(UIColor(P.mag).cgColor)
                    ctx.fillPath()
                } else {
                    // Normal iris
                    ctx.setFillColor(UIColor(hex: "5b21b6").cgColor)
                    ctx.fillEllipse(in: CGRect(x: ex + lk - eR * 0.55, y: eY - eR * 0.55, width: eR * 1.1, height: eR * 1.1))
                    ctx.setFillColor(UIColor(hex: "1a0a40").cgColor)
                    ctx.fillEllipse(in: CGRect(x: ex + lk - eR * 0.3, y: eY - eR * 0.3, width: eR * 0.6, height: eR * 0.6))
                }
                // Highlight
                ctx.setFillColor(UIColor.white.cgColor)
                ctx.fillEllipse(in: CGRect(x: ex + eR * 0.2 + lk - eR * 0.17, y: eY - eR * 0.2 - eR * 0.17, width: eR * 0.34, height: eR * 0.34))
            }
        }

        // Cheek blush
        ctx.setFillColor(UIColor(P.mag).withAlphaComponent(0.12).cgColor)
        for side: CGFloat in [-1, 1] {
            ctx.fillEllipse(in: CGRect(x: side * s * 0.48 - s * 0.12, y: s * 0.06 - s * 0.07, width: s * 0.24, height: s * 0.14))
        }

        // Mouth
        ctx.setStrokeColor(UIColor(hex: "6d28d9").cgColor)
        ctx.setLineWidth(2.5)
        ctx.setLineCap(.round)
        if mood == 1 {
            ctx.addArc(center: CGPoint(x: 0, y: s * 0.2), radius: s * 0.16, startAngle: .pi * 0.1, endAngle: .pi * 0.9, clockwise: false)
            ctx.strokePath()
        } else if mood == -1 {
            ctx.strokeEllipse(in: CGRect(x: -s * 0.07, y: s * 0.22 - s * 0.09, width: s * 0.14, height: s * 0.18))
        } else {
            ctx.addArc(center: CGPoint(x: 0, y: s * 0.17), radius: s * 0.11, startAngle: .pi * 0.15, endAngle: .pi * 0.85, clockwise: false)
            ctx.strokePath()
        }

        ctx.restoreGState()
    }
}

private extension UIColor {
    convenience init(hex: String) {
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = CGFloat((int >> 16) & 0xFF) / 255.0
        let g = CGFloat((int >> 8) & 0xFF) / 255.0
        let b = CGFloat(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
