import SwiftUI

struct UpgradesView: View {
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Upgrades")
                        .font(AppFonts.title(26))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Coins
                    HStack(spacing: 5) {
                        CoinIcon()
                            .frame(width: 18, height: 18)
                        Text(formatNumber(gameState.coins))
                            .font(AppFonts.number(16))
                            .foregroundColor(AppColors.gold)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(AppColors.cardBackground))
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                // Category tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryPill(title: "Tap Power", color: Color(hex: "e94560"), count: tapUpgrades.count)
                        CategoryPill(title: "Auto Climb", color: Color(hex: "4ade80"), count: autoUpgrades.count)
                        CategoryPill(title: "Multipliers", color: Color(hex: "a855f7"), count: multiplierUpgrades.count)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 12)
                
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(gameState.upgrades) { upgrade in
                            UpgradeCard(upgrade: upgrade) {
                                buyUpgrade(upgrade)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 12)
                    .padding(.bottom, 100)
                }
            }
        }
    }
    
    private var tapUpgrades: [Upgrade] {
        gameState.upgrades.filter { if case .tapPower = $0.effect { return true }; return false }
    }
    
    private var autoUpgrades: [Upgrade] {
        gameState.upgrades.filter { if case .autoTap = $0.effect { return true }; return false }
    }
    
    private var multiplierUpgrades: [Upgrade] {
        gameState.upgrades.filter { if case .multiplier = $0.effect { return true }; return false }
    }
    
    private func buyUpgrade(_ upgrade: Upgrade) {
        if gameState.buyUpgrade(upgrade) {
            SoundManager.shared.playSuccess()
        }
    }
    
    private func formatNumber(_ num: Int) -> String {
        if num >= 1000000 {
            return String(format: "%.1fM", Double(num) / 1000000)
        } else if num >= 1000 {
            return String(format: "%.1fK", Double(num) / 1000)
        }
        return "\(num)"
    }
}

// MARK: - Category Pill

struct CategoryPill: View {
    let title: String
    let color: Color
    let count: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
                .font(AppFonts.body(12))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(color.opacity(0.2)))
    }
}

// MARK: - Upgrade Card

struct UpgradeCard: View {
    let upgrade: Upgrade
    let onBuy: () -> Void
    
    @EnvironmentObject var gameState: GameState
    
    private var canAfford: Bool {
        gameState.coins >= upgrade.currentPrice
    }
    
    private var categoryColor: Color {
        switch upgrade.effect {
        case .tapPower: return Color(hex: "e94560")
        case .autoTap: return Color(hex: "4ade80")
        case .multiplier: return Color(hex: "a855f7")
        }
    }
    
    var body: some View {
        HStack(spacing: 10) {
            // Icon
            UpgradeIconView(iconType: upgrade.iconType, size: 24)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(categoryColor.opacity(0.2))
                )
            
            // Info
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(upgrade.name)
                        .font(AppFonts.body(15))
                        .foregroundColor(.white)
                    
                    if upgrade.level > 0 {
                        Text("Lv.\(upgrade.level)")
                            .font(AppFonts.body(11))
                            .foregroundColor(categoryColor)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(categoryColor.opacity(0.2)))
                    }
                }
                
                Text(upgrade.description)
                    .font(AppFonts.body(11))
                    .foregroundColor(.white.opacity(0.5))
                
                if upgrade.level > 0 {
                    Text("Total: +\(Int(upgrade.effectValue))")
                        .font(AppFonts.body(10))
                        .foregroundColor(categoryColor)
                }
            }
            
            Spacer()
            
            // Buy Button
            if upgrade.isMaxLevel {
                Text("MAX")
                    .font(AppFonts.body(12))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                    )
            } else {
                Button(action: onBuy) {
                    HStack(spacing: 3) {
                        CoinIcon()
                            .frame(width: 12, height: 12)
                        Text(formatNumber(upgrade.currentPrice))
                            .font(AppFonts.body(12))
                    }
                    .foregroundColor(canAfford ? .white : .white.opacity(0.4))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(canAfford ? categoryColor : Color.gray.opacity(0.3))
                    )
                }
                .disabled(!canAfford)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppColors.cardBackground)
        )
    }
    
    private func formatNumber(_ num: Int) -> String {
        if num >= 1000000 {
            return String(format: "%.1fM", Double(num) / 1000000)
        } else if num >= 1000 {
            return String(format: "%.1fK", Double(num) / 1000)
        }
        return "\(num)"
    }
}

#Preview {
    UpgradesView()
        .environmentObject(GameState())
}
