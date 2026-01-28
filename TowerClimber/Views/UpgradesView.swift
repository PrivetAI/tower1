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
                        .font(AppFonts.title(28))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Coins
                    HStack(spacing: 6) {
                        CoinIcon()
                            .frame(width: 20, height: 20)
                        Text(formatNumber(gameState.coins))
                            .font(AppFonts.number(18))
                            .foregroundColor(AppColors.gold)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(AppColors.cardBackground))
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(gameState.upgrades) { upgrade in
                            UpgradeCard(upgrade: upgrade) {
                                buyUpgrade(upgrade)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
        }
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

// MARK: - Upgrade Card

struct UpgradeCard: View {
    let upgrade: Upgrade
    let onBuy: () -> Void
    
    @EnvironmentObject var gameState: GameState
    
    private var canAfford: Bool {
        gameState.coins >= upgrade.currentPrice
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            upgradeIcon
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconBackground)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(upgrade.name)
                        .font(AppFonts.body(16))
                        .foregroundColor(.white)
                    
                    if upgrade.level > 0 {
                        Text("Lv.\(upgrade.level)")
                            .font(AppFonts.body(12))
                            .foregroundColor(AppColors.gold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(AppColors.gold.opacity(0.2)))
                    }
                }
                
                Text(upgrade.description)
                    .font(AppFonts.body(12))
                    .foregroundColor(.white.opacity(0.6))
                
                if upgrade.level > 0 {
                    Text("Current: +\(Int(upgrade.effectValue))")
                        .font(AppFonts.body(11))
                        .foregroundColor(AppColors.success)
                }
            }
            
            Spacer()
            
            // Buy Button
            if upgrade.isMaxLevel {
                Text("MAX")
                    .font(AppFonts.body(14))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                    )
            } else {
                Button(action: onBuy) {
                    HStack(spacing: 4) {
                        CoinIcon()
                            .frame(width: 14, height: 14)
                        Text(formatNumber(upgrade.currentPrice))
                            .font(AppFonts.body(14))
                    }
                    .foregroundColor(canAfford ? .white : .white.opacity(0.5))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(canAfford ? AppColors.accent : Color.gray.opacity(0.3))
                    )
                }
                .disabled(!canAfford)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
        )
    }
    
    @ViewBuilder
    var upgradeIcon: some View {
        switch upgrade.effect {
        case .tapPower:
            TapIcon()
        case .autoTap:
            AutoIcon()
        case .multiplier:
            MultiplierIcon()
        }
    }
    
    var iconBackground: Color {
        switch upgrade.effect {
        case .tapPower:
            return Color(hex: "e94560").opacity(0.3)
        case .autoTap:
            return Color(hex: "4ade80").opacity(0.3)
        case .multiplier:
            return Color(hex: "ffd700").opacity(0.3)
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

// MARK: - Custom Icons

struct TapIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(hex: "e94560"), lineWidth: 2)
                .frame(width: 24, height: 24)
            
            Circle()
                .fill(Color(hex: "e94560"))
                .frame(width: 12, height: 12)
        }
    }
}

struct AutoIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColors.success, lineWidth: 2)
                .frame(width: 24, height: 24)
            
            // Arrow circle
            Path { path in
                path.addArc(center: CGPoint(x: 12, y: 12), radius: 6, startAngle: .degrees(0), endAngle: .degrees(270), clockwise: false)
            }
            .stroke(AppColors.success, lineWidth: 2)
            .frame(width: 24, height: 24)
        }
    }
}

struct MultiplierIcon: View {
    var body: some View {
        Text("x")
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(AppColors.gold)
    }
}

#Preview {
    UpgradesView()
        .environmentObject(GameState())
}
