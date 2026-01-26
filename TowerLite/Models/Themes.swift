import SwiftUI

// MARK: - Tower Themes

struct TowerTheme: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let icon: String
    let baseColorHex: String
    let topColorHex: String
    let roofColorHex: String
    let windowColorHex: String
    let unlockRequirement: Int // Floor required to unlock (0 = default)
    
    var baseColor: Color { Color(hex: baseColorHex) }
    var topColor: Color { Color(hex: topColorHex) }
    var roofColor: Color { Color(hex: roofColorHex) }
    var windowColor: Color { Color(hex: windowColorHex) }
    
    static let allThemes: [TowerTheme] = [
        TowerTheme(id: "classic", name: "Classic", icon: "🏰", baseColorHex: "533483", topColorHex: "7952b3", roofColorHex: "ffd700", windowColorHex: "ffd700", unlockRequirement: 0),
        TowerTheme(id: "ocean", name: "Ocean", icon: "🌊", baseColorHex: "006994", topColorHex: "40a4df", roofColorHex: "00d4ff", windowColorHex: "00d4ff", unlockRequirement: 10),
        TowerTheme(id: "sunset", name: "Sunset", icon: "🌅", baseColorHex: "b33939", topColorHex: "e55039", roofColorHex: "ffb142", windowColorHex: "ffb142", unlockRequirement: 25),
        TowerTheme(id: "forest", name: "Forest", icon: "🌲", baseColorHex: "1e5631", topColorHex: "4a7c59", roofColorHex: "8fbc8f", windowColorHex: "98fb98", unlockRequirement: 50),
        TowerTheme(id: "midnight", name: "Midnight", icon: "🌙", baseColorHex: "0a0a23", topColorHex: "1a1a40", roofColorHex: "c0c0c0", windowColorHex: "e6e6fa", unlockRequirement: 75),
        TowerTheme(id: "gold", name: "Golden", icon: "👑", baseColorHex: "8b6914", topColorHex: "daa520", roofColorHex: "ffd700", windowColorHex: "fffacd", unlockRequirement: 100),
    ]
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: TowerTheme
    @Published var highestFloorReached: Int {
        didSet {
            UserDefaults.standard.set(highestFloorReached, forKey: "highestFloorReached")
        }
    }
    
    private let themeKey = "selectedTheme"
    
    init() {
        self.highestFloorReached = UserDefaults.standard.integer(forKey: "highestFloorReached")
        
        if let themeId = UserDefaults.standard.string(forKey: themeKey),
           let theme = TowerTheme.allThemes.first(where: { $0.id == themeId }) {
            self.currentTheme = theme
        } else {
            self.currentTheme = TowerTheme.allThemes[0]
        }
    }
    
    func selectTheme(_ theme: TowerTheme) {
        guard isUnlocked(theme) else { return }
        currentTheme = theme
        UserDefaults.standard.set(theme.id, forKey: themeKey)
    }
    
    func isUnlocked(_ theme: TowerTheme) -> Bool {
        highestFloorReached >= theme.unlockRequirement
    }
    
    func updateHighestFloor(_ floor: Int) {
        if floor > highestFloorReached {
            highestFloorReached = floor
        }
    }
    
    var unlockedThemes: [TowerTheme] {
        TowerTheme.allThemes.filter { isUnlocked($0) }
    }
}
