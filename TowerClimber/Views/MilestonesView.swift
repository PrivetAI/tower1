import SwiftUI

struct MilestonesView: View {
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Milestones")
                        .font(AppFonts.title(28))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Current floor
                    Text("Floor \(formatNumber(gameState.currentFloor))")
                        .font(AppFonts.body(14))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(AppColors.cardBackground))
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(gameState.milestones) { milestone in
                            MilestoneCard(milestone: milestone) {
                                claimMilestone(milestone)
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
    
    private func claimMilestone(_ milestone: Milestone) {
        if gameState.claimMilestone(milestone) {
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

// MARK: - Milestone Card

struct MilestoneCard: View {
    let milestone: Milestone
    let onClaim: () -> Void
    
    @EnvironmentObject var gameState: GameState
    
    private var progress: Double {
        min(1.0, Double(gameState.currentFloor) / Double(milestone.targetFloor))
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Status Icon
            statusIcon
                .frame(width: 44, height: 44)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(milestone.name)
                    .font(AppFonts.body(16))
                    .foregroundColor(.white)
                
                Text(milestone.description)
                    .font(AppFonts.body(12))
                    .foregroundColor(.white.opacity(0.6))
                
                // Progress bar
                if !milestone.isCompleted {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 3)
                                .fill(AppColors.accent)
                                .frame(width: geo.size.width * progress, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
            }
            
            Spacer()
            
            // Reward / Claim Button
            if milestone.isClaimed {
                HStack(spacing: 4) {
                    CheckmarkIcon()
                        .frame(width: 16, height: 16)
                    Text("Claimed")
                        .font(AppFonts.body(12))
                }
                .foregroundColor(AppColors.success)
            } else if milestone.isCompleted {
                Button(action: onClaim) {
                    HStack(spacing: 4) {
                        CoinIcon()
                            .frame(width: 14, height: 14)
                        Text("+\(formatNumber(milestone.reward))")
                            .font(AppFonts.body(14))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppColors.success)
                    )
                }
            } else {
                HStack(spacing: 4) {
                    CoinIcon()
                        .frame(width: 14, height: 14)
                    Text(formatNumber(milestone.reward))
                        .font(AppFonts.body(14))
                }
                .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(milestone.isCompleted && !milestone.isClaimed ? AppColors.success : Color.clear, lineWidth: 2)
                )
        )
    }
    
    @ViewBuilder
    var statusIcon: some View {
        ZStack {
            Circle()
                .fill(statusColor.opacity(0.2))
            
            if milestone.isClaimed {
                CheckmarkIcon()
                    .foregroundColor(AppColors.success)
            } else if milestone.isCompleted {
                GiftIcon()
                    .foregroundColor(AppColors.success)
            } else {
                Text("\(Int(progress * 100))%")
                    .font(AppFonts.body(11))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
    
    var statusColor: Color {
        if milestone.isClaimed {
            return AppColors.success
        } else if milestone.isCompleted {
            return AppColors.gold
        } else {
            return Color.white.opacity(0.2)
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

struct CheckmarkIcon: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 4, y: 10))
            path.addLine(to: CGPoint(x: 8, y: 14))
            path.addLine(to: CGPoint(x: 16, y: 4))
        }
        .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        .frame(width: 20, height: 18)
    }
}

struct GiftIcon: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(AppColors.gold)
                .frame(width: 18, height: 14)
                .offset(y: 3)
            
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "e94560"))
                .frame(width: 20, height: 6)
                .offset(y: -4)
            
            Rectangle()
                .fill(Color(hex: "e94560"))
                .frame(width: 4, height: 14)
                .offset(y: 3)
        }
    }
}

#Preview {
    MilestonesView()
        .environmentObject(GameState())
}
