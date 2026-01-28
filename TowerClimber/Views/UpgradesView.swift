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
            // Paw Pad
            Circle()
                .fill(Color(hex: "e94560"))
                .frame(width: 16, height: 16)
                .offset(y: 4)
            
            // Toes
            HStack(spacing: 2) {
                Circle().fill(Color(hex: "e94560")).frame(width: 8, height: 8)
                Circle().fill(Color(hex: "e94560")).frame(width: 8, height: 8).offset(y: -4)
                Circle().fill(Color(hex: "e94560")).frame(width: 8, height: 8)
            }
            .offset(y: -8)
        }
    }
}

struct AutoIcon: View {
    var body: some View {
        ZStack {
            // Bird/Wing shape
            Path { path in
                path.move(to: CGPoint(x: 4, y: 14))
                path.addQuadCurve(to: CGPoint(x: 20, y: 6), control: CGPoint(x: 12, y: 4))
                path.addQuadCurve(to: CGPoint(x: 12, y: 20), control: CGPoint(x: 24, y: 16))
                path.closeSubpath()
            }
            .fill(AppColors.success)
            .frame(width: 24, height: 24)
        }
    }
}

struct MultiplierIcon: View {
    var body: some View {
        ZStack {
            // Acorn shape
            Ellipse()
                .fill(Color(hex: "d4a574"))
                .frame(width: 18, height: 22)
            
            // Cap
            Path { path in
                path.move(to: CGPoint(x: 2, y: 10))
                path.addQuadCurve(to: CGPoint(x: 22, y: 10), control: CGPoint(x: 12, y: 0))
                path.closeSubpath()
            }
            .fill(Color(hex: "8b5a2b"))
            .frame(width: 24, height: 24)
        }
    }
}

#Preview {
    UpgradesView()
        .environmentObject(GameState())
}
