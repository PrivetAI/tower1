import SwiftUI

// MARK: - Upgrade Model

struct Upgrade: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let basePrice: Int
    let effect: UpgradeEffect
    var level: Int = 0
    
    // Exponential price formula: basePrice * (1.15 ^ level)
    var currentPrice: Int {
        let multiplier = pow(1.15, Double(level))
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
    case tapPower(Double)      // +floors per tap
    case autoTap(Double)       // +floors per second
    case multiplier(Double)    // x multiplier for all gains
}

// MARK: - Default Upgrades

extension Upgrade {
    static let allUpgrades: [Upgrade] = [
        // Tap Power Upgrades (finger icon theme)
        Upgrade(
            id: "strong_paws",
            name: "Strong Paws",
            description: "+1 floor per tap",
            basePrice: 15,
            effect: .tapPower(1)
        ),
        Upgrade(
            id: "climbing_boots",
            name: "Climbing Boots",
            description: "+2 floors per tap",
            basePrice: 100,
            effect: .tapPower(2)
        ),
        Upgrade(
            id: "turbo_claws",
            name: "Turbo Claws",
            description: "+5 floors per tap",
            basePrice: 500,
            effect: .tapPower(5)
        ),
        Upgrade(
            id: "rocket_boost",
            name: "Rocket Boost",
            description: "+10 floors per tap",
            basePrice: 3000,
            effect: .tapPower(10)
        ),
        
        // Auto Tap Upgrades (clock/auto theme)
        Upgrade(
            id: "helper_bird",
            name: "Helper Bird",
            description: "+1 floor/sec",
            basePrice: 50,
            effect: .autoTap(1)
        ),
        Upgrade(
            id: "wind_gust",
            name: "Wind Gust",
            description: "+3 floors/sec",
            basePrice: 300,
            effect: .autoTap(3)
        ),
        Upgrade(
            id: "mini_elevator",
            name: "Mini Elevator",
            description: "+10 floors/sec",
            basePrice: 2000,
            effect: .autoTap(10)
        ),
        Upgrade(
            id: "jet_engine",
            name: "Jet Engine",
            description: "+25 floors/sec",
            basePrice: 10000,
            effect: .autoTap(25)
        ),
        
        // Multipliers (star/boost theme)
        Upgrade(
            id: "lucky_charm",
            name: "Lucky Charm",
            description: "+10% to all gains",
            basePrice: 200,
            effect: .multiplier(0.1)
        ),
        Upgrade(
            id: "golden_touch",
            name: "Golden Touch",
            description: "+25% to all gains",
            basePrice: 1500,
            effect: .multiplier(0.25)
        ),
        Upgrade(
            id: "sky_blessing",
            name: "Sky Blessing",
            description: "+50% to all gains",
            basePrice: 8000,
            effect: .multiplier(0.5)
        ),
        Upgrade(
            id: "tower_master",
            name: "Tower Master",
            description: "+100% to all gains",
            basePrice: 50000,
            effect: .multiplier(1.0)
        )
    ]
}
