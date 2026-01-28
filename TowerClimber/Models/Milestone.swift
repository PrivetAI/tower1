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

// MARK: - Default Milestones

extension Milestone {
    static let allMilestones: [Milestone] = [
        Milestone(id: "m1", name: "First Steps", description: "Reach floor 10", targetFloor: 10, reward: 50),
        Milestone(id: "m2", name: "Getting Started", description: "Reach floor 50", targetFloor: 50, reward: 100),
        Milestone(id: "m3", name: "Climbing Up", description: "Reach floor 100", targetFloor: 100, reward: 200),
        Milestone(id: "m4", name: "Sky View", description: "Reach floor 250", targetFloor: 250, reward: 500),
        Milestone(id: "m5", name: "Cloud Walker", description: "Reach floor 500", targetFloor: 500, reward: 1000),
        Milestone(id: "m6", name: "Tower Master", description: "Reach floor 1000", targetFloor: 1000, reward: 2500),
        Milestone(id: "m7", name: "Sky Scraper", description: "Reach floor 2500", targetFloor: 2500, reward: 5000),
        Milestone(id: "m8", name: "Above Clouds", description: "Reach floor 5000", targetFloor: 5000, reward: 10000),
        Milestone(id: "m9", name: "Space Reach", description: "Reach floor 10000", targetFloor: 10000, reward: 25000),
        Milestone(id: "m10", name: "Legend", description: "Reach floor 25000", targetFloor: 25000, reward: 50000),
        Milestone(id: "m11", name: "Infinite Climber", description: "Reach floor 50000", targetFloor: 50000, reward: 100000),
        Milestone(id: "m12", name: "God Mode", description: "Reach floor 100000", targetFloor: 100000, reward: 250000)
    ]
}
