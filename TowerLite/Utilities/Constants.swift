import SwiftUI

enum AppColors {
    static let background = LinearGradient(
        colors: [Color(hex: "1a1a2e"), Color(hex: "16213e")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let cardBackground = Color(hex: "0f3460").opacity(0.8)
    
    static let accent = Color(hex: "e94560")
    static let gold = Color(hex: "ffd700")
    static let success = Color(hex: "4ade80")
    static let danger = Color(hex: "ef4444")
    
    static let towerBase = Color(hex: "533483")
    static let towerTop = Color(hex: "7952b3")
    
    static let targetZone = Color(hex: "4ade80").opacity(0.3)
    static let indicator = Color(hex: "ffd700")
}

enum GameSettings {
    // Timing game settings
    static let indicatorCycleDuration: Double = 2.5 // Slower start (was 1.0)
    static let targetZoneWidth: CGFloat = 0.3 // Platform and hit zone width
    static let targetZonePosition: CGFloat = 0.5 // center
    
    // Difficulty scaling
    static let minCycleDuration: Double = 1.0 // Minimum speed cap (was 0.6)
    static let difficultyIncreasePerFloor: Double = 0.01 // Slower ramp up (was 0.02)
}

enum AppFonts {
    static func title(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    
    static func body(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
    
    static func number(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
