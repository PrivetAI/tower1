import SwiftUI

// MARK: - Achievement System

struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let icon: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        lhs.id == rhs.id && lhs.isUnlocked == rhs.isUnlocked
    }
    
    static let allAchievements: [Achievement] = [
        // Floor achievements
        Achievement(id: "first_climb", title: "First Steps", description: "Complete your first climb", icon: "figure.stairs", isUnlocked: false),
        Achievement(id: "floor_5", title: "Getting Higher", description: "Reach floor 5", icon: "building", isUnlocked: false),
        Achievement(id: "floor_10", title: "Tower Climber", description: "Reach floor 10", icon: "building.2", isUnlocked: false),
        Achievement(id: "floor_25", title: "Sky High", description: "Reach floor 25", icon: "cloud", isUnlocked: false),
        Achievement(id: "floor_50", title: "Cloud Walker", description: "Reach floor 50", icon: "cloud.sun", isUnlocked: false),
        Achievement(id: "floor_75", title: "Stratosphere", description: "Reach floor 75", icon: "airplane", isUnlocked: false),
        Achievement(id: "floor_100", title: "Space Climber", description: "Reach floor 100", icon: "moon.stars", isUnlocked: false),
        Achievement(id: "floor_150", title: "Orbit Master", description: "Reach floor 150", icon: "globe", isUnlocked: false),
        Achievement(id: "floor_200", title: "Galaxy Explorer", description: "Reach floor 200", icon: "sparkles", isUnlocked: false),
        
        // Score achievements
        Achievement(id: "score_100", title: "Century", description: "Earn 100 points in one climb", icon: "star", isUnlocked: false),
        Achievement(id: "score_500", title: "High Scorer", description: "Earn 500 points in one climb", icon: "star.fill", isUnlocked: false),
        Achievement(id: "score_1000", title: "Score Master", description: "Earn 1000 points in one climb", icon: "star.circle.fill", isUnlocked: false),
        Achievement(id: "score_2500", title: "Point Hunter", description: "Earn 2500 points in one climb", icon: "star.square.fill", isUnlocked: false),
        Achievement(id: "score_5000", title: "Score Legend", description: "Earn 5000 points in one climb", icon: "rosette", isUnlocked: false),
        
        // Combo achievements
        Achievement(id: "perfect_5", title: "Combo x5", description: "Hit 5 perfect taps in a row", icon: "flame", isUnlocked: false),
        Achievement(id: "perfect_10", title: "Combo x10", description: "Hit 10 perfect taps in a row", icon: "flame.fill", isUnlocked: false),
        Achievement(id: "perfect_20", title: "Combo x20", description: "Hit 20 perfect taps in a row", icon: "bolt.fill", isUnlocked: false),
        Achievement(id: "perfect_50", title: "Combo Master", description: "Hit 50 perfect taps in a row", icon: "bolt.circle.fill", isUnlocked: false),
        
        // Games played achievements
        Achievement(id: "games_10", title: "Regular", description: "Complete 10 climbs", icon: "repeat", isUnlocked: false),
        Achievement(id: "games_50", title: "Dedicated", description: "Complete 50 climbs", icon: "repeat.circle", isUnlocked: false),
        Achievement(id: "games_100", title: "Veteran", description: "Complete 100 climbs", icon: "medal", isUnlocked: false),
        Achievement(id: "games_500", title: "Master Climber", description: "Complete 500 climbs", icon: "medal.fill", isUnlocked: false),
        
        // Speed achievements
        Achievement(id: "speed_demon", title: "Speed Demon", description: "Reach floor 10 in under 30 seconds", icon: "hare", isUnlocked: false),
        Achievement(id: "lightning", title: "Lightning Fast", description: "Reach floor 20 in under 60 seconds", icon: "bolt", isUnlocked: false),
        
        // Theme achievements
        Achievement(id: "theme_unlock", title: "Designer", description: "Unlock a new theme", icon: "paintpalette", isUnlocked: false),
        Achievement(id: "all_themes", title: "Collector", description: "Unlock all themes", icon: "paintpalette.fill", isUnlocked: false),
    ]
}

class AchievementManager: ObservableObject {
    @Published var achievements: [Achievement]
    @Published var newlyUnlocked: Achievement?
    
    private let storageKey = "achievements"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([Achievement].self, from: data) {
            // Merge saved with all achievements (in case new ones added)
            var merged = Achievement.allAchievements
            for (index, achievement) in merged.enumerated() {
                if let saved = saved.first(where: { $0.id == achievement.id }), saved.isUnlocked {
                    merged[index].isUnlocked = true
                    merged[index].unlockedDate = saved.unlockedDate
                }
            }
            self.achievements = merged
        } else {
            self.achievements = Achievement.allAchievements
        }
    }
    
    func unlock(_ id: String) {
        guard let index = achievements.firstIndex(where: { $0.id == id && !$0.isUnlocked }) else { return }
        
        achievements[index].isUnlocked = true
        achievements[index].unlockedDate = Date()
        newlyUnlocked = achievements[index]
        save()
        
        // Haptic feedback
        HapticManager.shared.achievement()
    }
    
    func checkAchievements(floor: Int, score: Int, combo: Int, totalGames: Int) {
        // First climb
        if floor > 1 { unlock("first_climb") }
        
        // Floor achievements
        if floor >= 5 { unlock("floor_5") }
        if floor >= 10 { unlock("floor_10") }
        if floor >= 25 { unlock("floor_25") }
        if floor >= 50 { unlock("floor_50") }
        if floor >= 75 { unlock("floor_75") }
        if floor >= 100 { unlock("floor_100") }
        if floor >= 150 { unlock("floor_150") }
        if floor >= 200 { unlock("floor_200") }
        
        // Score achievements
        if score >= 100 { unlock("score_100") }
        if score >= 500 { unlock("score_500") }
        if score >= 1000 { unlock("score_1000") }
        if score >= 2500 { unlock("score_2500") }
        if score >= 5000 { unlock("score_5000") }
        
        // Combo achievements
        if combo >= 5 { unlock("perfect_5") }
        if combo >= 10 { unlock("perfect_10") }
        if combo >= 20 { unlock("perfect_20") }
        if combo >= 50 { unlock("perfect_50") }
        
        // Games played achievements
        if totalGames >= 10 { unlock("games_10") }
        if totalGames >= 50 { unlock("games_50") }
        if totalGames >= 100 { unlock("games_100") }
        if totalGames >= 500 { unlock("games_500") }
    }
    
    // Called when theme unlocked
    func checkThemeAchievements(unlockedThemes: Int, totalThemes: Int) {
        if unlockedThemes > 1 { unlock("theme_unlock") }
        if unlockedThemes >= totalThemes { unlock("all_themes") }
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var totalCount: Int {
        achievements.count
    }
}
