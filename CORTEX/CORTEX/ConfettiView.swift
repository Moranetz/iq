import SwiftUI
import UIKit

struct ConfettiOverlay: UIViewRepresentable {
    let trigger: Int
    var count: Int = 40
    var mega: Bool = false

    func makeUIView(context: Context) -> ConfettiCanvasView {
        let view = ConfettiCanvasView()
        view.backgroundColor = .clear
        view.isOpaque = false
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: ConfettiCanvasView, context: Context) {
        if trigger > 0 {
            uiView.burst(count: count, mega: mega)
        }
    }
}

class ConfettiCanvasView: UIView {
    private var particles: [Particle] = []
    private var displayLink: CADisplayLink?

    struct Particle {
        var x: CGFloat
        var y: CGFloat
        var vx: CGFloat
        var vy: CGFloat
        var size: CGFloat
        var color: UIColor
        var life: CGFloat
        var decay: CGFloat
        var rotation: CGFloat
        var rotSpeed: CGFloat
        var shape: Int
    }

    func burst(count: Int, mega: Bool) {
        let colors: [UIColor] = [
            UIColor(P.teal), UIColor(P.mag), UIColor(P.lime), UIColor(P.gold),
            .white, UIColor(P.blue), UIColor(P.main), UIColor(P.red), UIColor(P.green), UIColor(P.yellow)
        ]
        let scale: CGFloat = mega ? 1.7 : 1.0
        let cx = bounds.width / 2
        let cy = mega ? bounds.height / 3 : bounds.height / 4

        for _ in 0..<count {
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let speed = (2 + CGFloat.random(in: 0...6)) * scale
            particles.append(Particle(
                x: cx, y: cy,
                vx: cos(angle) * speed,
                vy: sin(angle) * speed - 3 * scale,
                size: (2.5 + CGFloat.random(in: 0...5.5)) * scale,
                color: colors.randomElement()!,
                life: 1,
                decay: 0.006 + CGFloat.random(in: 0...0.012),
                rotation: CGFloat.random(in: 0...360),
                rotSpeed: CGFloat.random(in: -4.5...4.5),
                shape: Int.random(in: 0...2)
            ))
        }

        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(tick))
            displayLink?.add(to: .main, forMode: .common)
        }
    }

    @objc private func tick() {
        setNeedsDisplay()
        particles = particles.filter { $0.life > 0 }
        if particles.isEmpty {
            displayLink?.invalidate()
            displayLink = nil
        }
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.clear(rect)

        for i in particles.indices {
            particles[i].x += particles[i].vx
            particles[i].y += particles[i].vy
            particles[i].vy += 0.12
            particles[i].life -= particles[i].decay
            particles[i].rotation += particles[i].rotSpeed

            let p = particles[i]
            guard p.life > 0 else { continue }

            ctx.saveGState()
            ctx.translateBy(x: p.x, y: p.y)
            ctx.rotate(by: p.rotation * .pi / 180)
            ctx.setAlpha(max(0, p.life))
            ctx.setFillColor(p.color.cgColor)

            switch p.shape {
            case 0:
                ctx.fill(CGRect(x: -p.size / 2, y: -p.size / 2, width: p.size, height: p.size))
            case 1:
                ctx.fillEllipse(in: CGRect(x: -p.size / 2, y: -p.size / 2, width: p.size, height: p.size))
            default:
                let path = CGMutablePath()
                path.move(to: CGPoint(x: 0, y: -p.size / 2))
                path.addLine(to: CGPoint(x: p.size / 3, y: 0))
                path.addLine(to: CGPoint(x: 0, y: p.size / 2))
                path.addLine(to: CGPoint(x: -p.size / 3, y: 0))
                path.closeSubpath()
                ctx.addPath(path)
                ctx.fillPath()
            }
            ctx.restoreGState()
        }
    }
}

struct StarsBackground: UIViewRepresentable {
    func makeUIView(context: Context) -> StarsCanvasView {
        let view = StarsCanvasView()
        view.backgroundColor = .clear
        view.isOpaque = false
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: StarsCanvasView, context: Context) {}
}

class StarsCanvasView: UIView {
    private var stars: [(x: CGFloat, y: CGFloat, s: CGFloat, speed: CGFloat, phase: CGFloat, color: UIColor)] = []
    private var displayLink: CADisplayLink?
    private var time: Double = 0

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil && displayLink == nil {
            let colors: [UIColor] = [UIColor(P.teal), UIColor(P.mag), UIColor(P.main), UIColor(P.gold), .white, UIColor(P.blue)]
            stars = (0..<25).map { _ in
                (CGFloat.random(in: 0...UIScreen.main.bounds.width),
                 CGFloat.random(in: 0...UIScreen.main.bounds.height),
                 CGFloat.random(in: 0.4...1.4),
                 CGFloat.random(in: 0.07...0.18),
                 CGFloat.random(in: 0...(2 * .pi)),
                 colors.randomElement()!)
            }
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
        time += 0.02
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.clear(rect)
        for i in stars.indices {
            stars[i].y -= stars[i].speed
            if stars[i].y < -5 {
                stars[i].y = rect.height + 5
                stars[i].x = CGFloat.random(in: 0...rect.width)
            }
            let alpha = 0.1 + sin(time * 2 + stars[i].phase) * 0.08
            ctx.setFillColor(stars[i].color.withAlphaComponent(CGFloat(alpha)).cgColor)
            ctx.fillEllipse(in: CGRect(x: stars[i].x - stars[i].s, y: stars[i].y - stars[i].s, width: stars[i].s * 2, height: stars[i].s * 2))
        }
    }
}
