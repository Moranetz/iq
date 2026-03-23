import AVFoundation
import UIKit

final class SoundManager {
    static let shared = SoundManager()
    private var engine: AVAudioEngine?

    private init() {
        setupEngine()
    }

    private func setupEngine() {
        engine = AVAudioEngine()
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    private func playTone(frequency: Double, duration: Double, volume: Float = 0.06, type: String = "sine") {
        guard let engine = engine else { return }
        let sampleRate = engine.outputNode.outputFormat(forBus: 0).sampleRate
        let node = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let freq = frequency
            for frame in 0..<Int(frameCount) {
                let time = Double(frame) / sampleRate
                var sample: Float
                switch type {
                case "triangle":
                    let phase = fmod(time * freq, 1.0)
                    sample = Float(phase < 0.5 ? 4.0 * phase - 1.0 : 3.0 - 4.0 * phase)
                default:
                    sample = Float(sin(2.0 * .pi * freq * time))
                }
                let envelope = Float(max(0, 1.0 - time / duration))
                sample *= volume * envelope
                for buf in ablPointer {
                    let bufPtr = buf.mData?.assumingMemoryBound(to: Float.self)
                    bufPtr?[frame] = sample
                }
            }
            return noErr
        }

        let format = engine.outputNode.outputFormat(forBus: 0)
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
        } catch { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            node.removeTap(onBus: 0)
            self?.engine?.detach(node)
        }
    }

    func ok(streak: Int = 0) {
        let base = 520.0 + Double(streak) * 55.0
        playTone(frequency: base, duration: 0.06, volume: 0.05 + Float(streak) * 0.003)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.playTone(frequency: base * 1.25, duration: 0.08, volume: 0.06)
        }
        if streak >= 3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.playTone(frequency: base * 1.5, duration: 0.08, volume: 0.06)
            }
        }
    }

    func no() {
        playTone(frequency: 280, duration: 0.1, volume: 0.03, type: "triangle")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
            self.playTone(frequency: 240, duration: 0.12, volume: 0.025, type: "triangle")
        }
    }

    func tap() { playTone(frequency: 1100, duration: 0.01, volume: 0.02) }

    func go() {
        let freqs = [523.0, 659.0, 784.0, 1047.0]
        for (i, f) in freqs.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) {
                self.playTone(frequency: f, duration: 0.06, volume: 0.04 + Float(i) * 0.005)
            }
        }
    }

    func levelUp() {
        let freqs = [523.0, 659.0, 784.0, 988.0, 1175.0]
        for (i, f) in freqs.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.065) {
                self.playTone(frequency: f, duration: 0.08, volume: 0.055)
            }
        }
    }

    func slide() { playTone(frequency: 800, duration: 0.03, volume: 0.03) }
    func chain() {
        playTone(frequency: 660, duration: 0.05, volume: 0.04)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.playTone(frequency: 880, duration: 0.05, volume: 0.04)
        }
    }
    func reveal() {
        playTone(frequency: 440, duration: 0.06, volume: 0.04)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.playTone(frequency: 554, duration: 0.07, volume: 0.05)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.playTone(frequency: 660, duration: 0.08, volume: 0.05)
        }
    }
}
