import SwiftUI

class GameState: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentFloor: Int {
        didSet { save() }
    }
    
    @Published var bestFloor: Int {
        didSet { save() }
    }
    
    @Published var coins: Int {
        didSet { save() }
    }
    
    @Published var totalTaps: Int {
        didSet { save() }
    }
    
    @Published var totalFloorsClimbed: Int {
        didSet { save() }
    }
    
    @Published var upgrades: [Upgrade] {
        didSet { save() }
    }
    
    @Published var milestones: [Milestone] {
        didSet { save() }
    }
    
    @Published var playTimeSeconds: Int {
        didSet { save() }
    }
    
    // MARK: - Computed Properties
    
    var floorsPerTap: Int {
        let baseTap = 1
        var bonus = 0.0
        
        for upgrade in upgrades {
            if case .tapPower(let value) = upgrade.effect {
                bonus += value * Double(upgrade.level)
            }
        }
        
        return Int(Double(baseTap + Int(bonus)) * multiplier)
    }
    
    var floorsPerSecond: Double {
        var total = 0.0
        
        for upgrade in upgrades {
            if case .autoTap(let value) = upgrade.effect {
                total += value * Double(upgrade.level)
            }
        }
        
        return total * multiplier
    }
    
    var multiplier: Double {
        var mult = 1.0
        
        for upgrade in upgrades {
            if case .multiplier(let value) = upgrade.effect {
                mult += value * Double(upgrade.level)
            }
        }
        
        return mult
    }
    
    var unclaimedMilestones: Int {
        milestones.filter { $0.isCompleted && !$0.isClaimed }.count
    }
    
    // MARK: - Private
    
    private var autoTimer: Timer?
    private let saveKey = "gameStateV2"
    
    // MARK: - Init
    
    init() {
        // Load saved state
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let saved = try? JSONDecoder().decode(SavedState.self, from: data) {
            self.currentFloor = saved.currentFloor
            self.bestFloor = saved.bestFloor
            self.coins = saved.coins
            self.totalTaps = saved.totalTaps
            self.totalFloorsClimbed = saved.totalFloorsClimbed
            self.upgrades = saved.upgrades
            self.milestones = saved.milestones
            self.playTimeSeconds = saved.playTimeSeconds
        } else {
            self.currentFloor = 1
            self.bestFloor = 1
            self.coins = 0
            self.totalTaps = 0
            self.totalFloorsClimbed = 0
            self.upgrades = Upgrade.allUpgrades
            self.milestones = Milestone.allMilestones
            self.playTimeSeconds = 0
        }
        
        startAutoTap()
        startPlayTimer()
    }
    
    // MARK: - Actions
    
    func tap() {
        let floors = floorsPerTap
        currentFloor += floors
        totalFloorsClimbed += floors
        totalTaps += 1
        
        // Earn coins (1 coin per 10 floors climbed)
        coins += max(1, floors / 10)
        
        updateBestFloor()
        checkMilestones()
    }
    
    func buyUpgrade(_ upgrade: Upgrade) -> Bool {
        guard let index = upgrades.firstIndex(where: { $0.id == upgrade.id }) else { return false }
        guard coins >= upgrade.currentPrice else { return false }
        guard !upgrade.isMaxLevel else { return false }
        
        coins -= upgrade.currentPrice
        upgrades[index].level += 1
        return true
    }
    
    func claimMilestone(_ milestone: Milestone) -> Bool {
        guard let index = milestones.firstIndex(where: { $0.id == milestone.id }) else { return false }
        guard milestone.isCompleted && !milestone.isClaimed else { return false }
        
        coins += milestone.reward
        milestones[index].isClaimed = true
        return true
    }
    
    func resetProgress() {
        currentFloor = 1
        bestFloor = 1
        coins = 0
        totalTaps = 0
        totalFloorsClimbed = 0
        upgrades = Upgrade.allUpgrades
        milestones = Milestone.allMilestones
        playTimeSeconds = 0
    }
    
    // MARK: - Private Methods
    
    private func updateBestFloor() {
        if currentFloor > bestFloor {
            bestFloor = currentFloor
        }
    }
    
    private func checkMilestones() {
        for i in milestones.indices {
            if !milestones[i].isCompleted && currentFloor >= milestones[i].targetFloor {
                milestones[i].isCompleted = true
            }
        }
    }
    
    private func startAutoTap() {
        autoTimer?.invalidate()
        autoTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let fps = self.floorsPerSecond
            if fps > 0 {
                let floorsToAdd = Int(fps / 10)
                if floorsToAdd > 0 {
                    self.currentFloor += floorsToAdd
                    self.totalFloorsClimbed += floorsToAdd
                    self.coins += max(1, floorsToAdd / 10)
                    self.updateBestFloor()
                    self.checkMilestones()
                }
            }
        }
    }
    
    private func startPlayTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.playTimeSeconds += 1
        }
    }
    
    private func save() {
        let state = SavedState(
            currentFloor: currentFloor,
            bestFloor: bestFloor,
            coins: coins,
            totalTaps: totalTaps,
            totalFloorsClimbed: totalFloorsClimbed,
            upgrades: upgrades,
            milestones: milestones,
            playTimeSeconds: playTimeSeconds
        )
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }
}

// MARK: - Saved State

private struct SavedState: Codable {
    let currentFloor: Int
    let bestFloor: Int
    let coins: Int
    let totalTaps: Int
    let totalFloorsClimbed: Int
    let upgrades: [Upgrade]
    let milestones: [Milestone]
    let playTimeSeconds: Int
}
