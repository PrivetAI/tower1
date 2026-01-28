import SwiftUI

class GameState: ObservableObject {
    @Published var currentFloor: Int {
        didSet {
            UserDefaults.standard.set(currentFloor, forKey: "currentFloor")
            if currentFloor > bestFloor {
                bestFloor = currentFloor
            }
        }
    }
    
    @Published var bestFloor: Int {
        didSet {
            UserDefaults.standard.set(bestFloor, forKey: "bestFloor")
        }
    }
    
    @Published var totalTaps: Int {
        didSet {
            UserDefaults.standard.set(totalTaps, forKey: "totalTaps")
        }
    }
    
    init() {
        self.currentFloor = UserDefaults.standard.integer(forKey: "currentFloor")
        self.bestFloor = UserDefaults.standard.integer(forKey: "bestFloor")
        self.totalTaps = UserDefaults.standard.integer(forKey: "totalTaps")
        
        if currentFloor == 0 {
            currentFloor = 1
        }
        if bestFloor == 0 {
            bestFloor = 1
        }
    }
    
    func tap() {
        currentFloor += 1
        totalTaps += 1
    }
    
    func reset() {
        currentFloor = 1
    }
}
