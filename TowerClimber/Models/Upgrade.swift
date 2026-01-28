import SwiftUI

// MARK: - Upgrade Model

struct Upgrade: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let basePrice: Int
    let priceMultiplier: Double
    let effect: UpgradeEffect
    var level: Int = 0
    
    var currentPrice: Int {
        Int(Double(basePrice) * pow(priceMultiplier, Double(level)))
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
        level >= 50
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
        // Tap Power Upgrades
        Upgrade(
            id: "strong_paws",
            name: "Strong Paws",
            description: "+1 floor per tap",
            basePrice: 10,
            priceMultiplier: 1.15,
            effect: .tapPower(1)
        ),
        Upgrade(
            id: "climbing_boots",
            name: "Climbing Boots",
            description: "+2 floors per tap",
            basePrice: 100,
            priceMultiplier: 1.2,
            effect: .tapPower(2)
        ),
        Upgrade(
            id: "turbo_claws",
            name: "Turbo Claws",
            description: "+5 floors per tap",
            basePrice: 1000,
            priceMultiplier: 1.25,
            effect: .tapPower(5)
        ),
        Upgrade(
            id: "rocket_tail",
            name: "Rocket Tail",
            description: "+10 floors per tap",
            basePrice: 10000,
            priceMultiplier: 1.3,
            effect: .tapPower(10)
        ),
        
        // Auto Tap Upgrades
        Upgrade(
            id: "helper_bird",
            name: "Helper Bird",
            description: "+1 floor/sec",
            basePrice: 50,
            priceMultiplier: 1.15,
            effect: .autoTap(1)
        ),
        Upgrade(
            id: "friendly_wind",
            name: "Friendly Wind",
            description: "+3 floors/sec",
            basePrice: 500,
            priceMultiplier: 1.2,
            effect: .autoTap(3)
        ),
        Upgrade(
            id: "elevator",
            name: "Mini Elevator",
            description: "+10 floors/sec",
            basePrice: 5000,
            priceMultiplier: 1.25,
            effect: .autoTap(10)
        ),
        
        // Multipliers
        Upgrade(
            id: "lucky_acorn",
            name: "Lucky Acorn",
            description: "+10% to all gains",
            basePrice: 200,
            priceMultiplier: 1.5,
            effect: .multiplier(0.1)
        ),
        Upgrade(
            id: "golden_fur",
            name: "Golden Fur",
            description: "+25% to all gains",
            basePrice: 2000,
            priceMultiplier: 1.6,
            effect: .multiplier(0.25)
        ),
        Upgrade(
            id: "sky_blessing",
            name: "Sky Blessing",
            description: "+50% to all gains",
            basePrice: 20000,
            priceMultiplier: 1.7,
            effect: .multiplier(0.5)
        )
    ]
}
