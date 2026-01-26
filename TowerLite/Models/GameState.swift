import SwiftUI

struct GameSession: Codable, Identifiable {
    let id: UUID
    let date: Date
    let floorReached: Int
    let scoreEarned: Int
    
    init(id: UUID = UUID(), date: Date = Date(), floorReached: Int, scoreEarned: Int) {
        self.id = id
        self.date = date
        self.floorReached = floorReached
        self.scoreEarned = scoreEarned
    }
}

class GameState: ObservableObject {
    @Published var currentFloor: Int {
        didSet { saveToUserDefaults() }
    }
    @Published var currentScore: Int {
        didSet { saveToUserDefaults() }
    }
    @Published var bestScore: Int {
        didSet { UserDefaults.standard.set(bestScore, forKey: "bestScore") }
    }
    @Published var history: [GameSession] {
        didSet { saveHistory() }
    }
    
    private let floorKey = "currentFloor"
    private let scoreKey = "currentScore"
    private let bestScoreKey = "bestScore"
    private let historyKey = "gameHistory"
    
    init() {
        self.currentFloor = UserDefaults.standard.integer(forKey: floorKey)
        self.currentScore = UserDefaults.standard.integer(forKey: scoreKey)
        self.bestScore = UserDefaults.standard.integer(forKey: bestScoreKey)
        
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([GameSession].self, from: data) {
            self.history = decoded
        } else {
            self.history = []
        }
        
        if currentFloor == 0 {
            currentFloor = 1
        }
    }
    
    private func saveToUserDefaults() {
        UserDefaults.standard.set(currentFloor, forKey: floorKey)
        UserDefaults.standard.set(currentScore, forKey: scoreKey)
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }
    
    func addScore(_ score: Int) {
        currentScore += score
        if currentScore > bestScore {
            bestScore = currentScore
        }
    }
    
    func climbFloor() {
        currentFloor += 1
    }
    
    /// Save current progress and start a new climb
    func saveProgress() {
        if currentFloor > 1 || currentScore > 0 {
            let session = GameSession(
                floorReached: currentFloor,
                scoreEarned: currentScore
            )
            history.insert(session, at: 0)
            
            // Keep only last 50 sessions
            if history.count > 50 {
                history = Array(history.prefix(50))
            }
        }
        
        currentFloor = 1
        currentScore = 0
    }
    
    func calculateScoreForFloor() -> Int {
        // Higher floors = more score (skill-based progression)
        return 10 + (currentFloor * 5)
    }
}
