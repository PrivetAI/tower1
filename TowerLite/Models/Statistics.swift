import SwiftUI

// MARK: - Statistics

struct GameStatistics: Codable {
    var totalGames: Int = 0
    var totalScore: Int = 0
    var totalFloors: Int = 0
    var totalSuccessfulTaps: Int = 0
    var totalMissedTaps: Int = 0
    var longestCombo: Int = 0
    var highestFloor: Int = 0
    var highestScore: Int = 0
    var totalPlayTime: TimeInterval = 0
    
    var successRate: Double {
        let total = totalSuccessfulTaps + totalMissedTaps
        guard total > 0 else { return 0 }
        return Double(totalSuccessfulTaps) / Double(total) * 100
    }
    
    var averageScore: Double {
        guard totalGames > 0 else { return 0 }
        return Double(totalScore) / Double(totalGames)
    }
    
    var averageFloor: Double {
        guard totalGames > 0 else { return 0 }
        return Double(totalFloors) / Double(totalGames)
    }
}

class StatisticsManager: ObservableObject {
    @Published var stats: GameStatistics
    
    private let storageKey = "gameStatistics"
    private var sessionStartTime: Date?
    
    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode(GameStatistics.self, from: data) {
            self.stats = saved
        } else {
            self.stats = GameStatistics()
        }
    }
    
    func startSession() {
        sessionStartTime = Date()
    }
    
    func endSession() {
        if let start = sessionStartTime {
            stats.totalPlayTime += Date().timeIntervalSince(start)
            save()
        }
        sessionStartTime = nil
    }
    
    func recordSuccess(score: Int) {
        stats.totalSuccessfulTaps += 1
        stats.totalScore += score
        save()
    }
    
    func recordMiss() {
        stats.totalMissedTaps += 1
        save()
    }
    
    func recordGame(floor: Int, score: Int, combo: Int) {
        stats.totalGames += 1
        stats.totalFloors += floor
        
        if floor > stats.highestFloor {
            stats.highestFloor = floor
        }
        if score > stats.highestScore {
            stats.highestScore = score
        }
        if combo > stats.longestCombo {
            stats.longestCombo = combo
        }
        save()
    }
    
    func updateCombo(_ combo: Int) {
        if combo > stats.longestCombo {
            stats.longestCombo = combo
        }
        save()
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    func formattedPlayTime() -> String {
        let hours = Int(stats.totalPlayTime) / 3600
        let minutes = (Int(stats.totalPlayTime) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
