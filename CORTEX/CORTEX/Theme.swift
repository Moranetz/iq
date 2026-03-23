import SwiftUI

enum P {
    static let bg = Color(hex: "120a28")
    static let sf = Color(hex: "1a1040")
    static let sf2 = Color(hex: "221455")
    static let bdr = Color(hex: "3a2080")

    static let red = Color(hex: "ff4858")
    static let redS = Color(hex: "cc3a47")
    static let blue = Color(hex: "45a3f1")
    static let blueS = Color(hex: "3682c1")
    static let green = Color(hex: "26d782")
    static let greenS = Color(hex: "1fac68")
    static let yellow = Color(hex: "ffba08")
    static let yellowS = Color(hex: "cc9506")

    static let main = Color(hex: "c77dff")
    static let mainS = Color(hex: "9d4edd")
    static let teal = Color(hex: "00f5d4")
    static let tealS = Color(hex: "00c4a8")
    static let mag = Color(hex: "f72585")
    static let magS = Color(hex: "c51e6a")
    static let lime = Color(hex: "b5e48c")
    static let gold = Color(hex: "ffd60a")

    static let txt = Color(hex: "f0e6ff")
    static let dim = Color(hex: "a89cc8")
    static let mut = Color(hex: "6b5b95")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

let nunitoFont = "Nunito"
