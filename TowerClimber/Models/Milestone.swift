import SwiftUI

// MARK: - Milestone Model

struct Milestone: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let targetFloor: Int
    let reward: Int
    var isCompleted: Bool = false
    var isClaimed: Bool = false
}

// MARK: - Default Milestones (20 total)

extension Milestone {
    static let allMilestones: [Milestone] = [
        // Early game
        Milestone(id: "m1", name: "First Steps", description: "Reach floor 10", targetFloor: 10, reward: 25),
        Milestone(id: "m2", name: "Getting Started", description: "Reach floor 25", targetFloor: 25, reward: 50),
        Milestone(id: "m3", name: "Warming Up", description: "Reach floor 50", targetFloor: 50, reward: 100),
        Milestone(id: "m4", name: "Climbing Steady", description: "Reach floor 100", targetFloor: 100, reward: 200),
        
        // Mid game
        Milestone(id: "m5", name: "Sky View", description: "Reach floor 200", targetFloor: 200, reward: 400),
        Milestone(id: "m6", name: "Cloud Walker", description: "Reach floor 350", targetFloor: 350, reward: 700),
        Milestone(id: "m7", name: "Tower Builder", description: "Reach floor 500", targetFloor: 500, reward: 1000),
        Milestone(id: "m8", name: "Above Clouds", description: "Reach floor 750", targetFloor: 750, reward: 1500),
        Milestone(id: "m9", name: "Sky Master", description: "Reach floor 1000", targetFloor: 1000, reward: 2500),
        
        // Late game
        Milestone(id: "m10", name: "Stratosphere", description: "Reach floor 1500", targetFloor: 1500, reward: 4000),
        Milestone(id: "m11", name: "Space Reach", description: "Reach floor 2500", targetFloor: 2500, reward: 7000),
        Milestone(id: "m12", name: "Orbital Height", description: "Reach floor 4000", targetFloor: 4000, reward: 12000),
        Milestone(id: "m13", name: "Moon Bound", description: "Reach floor 6000", targetFloor: 6000, reward: 20000),
        Milestone(id: "m14", name: "Star Gazer", description: "Reach floor 10000", targetFloor: 10000, reward: 35000),
        
        // End game
        Milestone(id: "m15", name: "Galaxy Explorer", description: "Reach floor 15000", targetFloor: 15000, reward: 50000),
        Milestone(id: "m16", name: "Cosmic Climber", description: "Reach floor 25000", targetFloor: 25000, reward: 80000),
        Milestone(id: "m17", name: "Universe Walker", description: "Reach floor 40000", targetFloor: 40000, reward: 120000),
        Milestone(id: "m18", name: "Dimension Breaker", description: "Reach floor 60000", targetFloor: 60000, reward: 180000),
        Milestone(id: "m19", name: "Infinity Seeker", description: "Reach floor 85000", targetFloor: 85000, reward: 250000),
        Milestone(id: "m20", name: "Eternal Legend", description: "Reach floor 100000", targetFloor: 100000, reward: 500000)
    ]
}
