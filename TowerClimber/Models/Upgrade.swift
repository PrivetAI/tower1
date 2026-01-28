import SwiftUI

// MARK: - Upgrade Model

struct Upgrade: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let basePrice: Int
    let effect: UpgradeEffect
    let iconType: UpgradeIconType
    var level: Int = 0
    
    // Exponential price formula: basePrice * (1.12 ^ level)
    var currentPrice: Int {
        let multiplier = pow(1.12, Double(level))
        return Int(Double(basePrice) * multiplier)
    }
    
    var effectValue: Double {
        switch effect {
        case .tapPower(let base):
            return base * Double(level)
        case .autoTap(let base):
            return base * Double(level)
        case .multiplier(let base):
            return 1.0 + (base * Double(level))
        }
    }
    
    var isMaxLevel: Bool {
        level >= 100
    }
}

enum UpgradeEffect: Codable, Equatable {
    case tapPower(Double)
    case autoTap(Double)
    case multiplier(Double)
}

enum UpgradeIconType: String, Codable {
    case paw, boots, claws, rocket, wings
    case bird, wind, elevator, jet, drone
    case clover, gem, crown, diamond
}

// MARK: - Default Upgrades (15 total)

extension Upgrade {
    static let allUpgrades: [Upgrade] = [
        // Tap Power (5)
        Upgrade(id: "strong_paws", name: "Strong Paws", description: "+1 floor per tap",
                basePrice: 15, effect: .tapPower(1), iconType: .paw),
        Upgrade(id: "climbing_boots", name: "Climbing Boots", description: "+2 floors per tap",
                basePrice: 80, effect: .tapPower(2), iconType: .boots),
        Upgrade(id: "turbo_claws", name: "Turbo Claws", description: "+5 floors per tap",
                basePrice: 400, effect: .tapPower(5), iconType: .claws),
        Upgrade(id: "rocket_boost", name: "Rocket Boost", description: "+10 floors per tap",
                basePrice: 2000, effect: .tapPower(10), iconType: .rocket),
        Upgrade(id: "angel_wings", name: "Angel Wings", description: "+25 floors per tap",
                basePrice: 10000, effect: .tapPower(25), iconType: .wings),
        
        // Auto Tap (5)
        Upgrade(id: "helper_bird", name: "Helper Bird", description: "+1 floor/sec",
                basePrice: 50, effect: .autoTap(1), iconType: .bird),
        Upgrade(id: "wind_gust", name: "Wind Gust", description: "+3 floors/sec",
                basePrice: 250, effect: .autoTap(3), iconType: .wind),
        Upgrade(id: "mini_elevator", name: "Mini Elevator", description: "+8 floors/sec",
                basePrice: 1200, effect: .autoTap(8), iconType: .elevator),
        Upgrade(id: "jet_engine", name: "Jet Engine", description: "+20 floors/sec",
                basePrice: 6000, effect: .autoTap(20), iconType: .jet),
        Upgrade(id: "sky_drone", name: "Sky Drone", description: "+50 floors/sec",
                basePrice: 30000, effect: .autoTap(50), iconType: .drone),
        
        // Multipliers (5)
        Upgrade(id: "lucky_clover", name: "Lucky Clover", description: "+10% to all gains",
                basePrice: 150, effect: .multiplier(0.1), iconType: .clover),
        Upgrade(id: "magic_gem", name: "Magic Gem", description: "+20% to all gains",
                basePrice: 800, effect: .multiplier(0.2), iconType: .gem),
        Upgrade(id: "royal_crown", name: "Royal Crown", description: "+35% to all gains",
                basePrice: 4000, effect: .multiplier(0.35), iconType: .crown),
        Upgrade(id: "sky_diamond", name: "Sky Diamond", description: "+50% to all gains",
                basePrice: 20000, effect: .multiplier(0.5), iconType: .diamond)
    ]
}
