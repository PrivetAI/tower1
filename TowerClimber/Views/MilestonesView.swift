import SwiftUI

struct MilestonesView: View {
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        GeometryReader { geo in
            let isIPad = geo.size.width > 500
            let scale: CGFloat = isIPad ? 1.2 : 1.0
            
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Goals")
                            .font(AppFonts.title(26 * scale))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Progress
                        let completed = gameState.milestones.filter { $0.isCompleted }.count
                        Text("\(completed)/\(gameState.milestones.count)")
                            .font(AppFonts.body(14 * scale))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.horizontal, isIPad ? 40 : 16)
                    .padding(.top, isIPad ? 20 : 12)
                    
                    ScrollView {
                        LazyVStack(spacing: 10 * scale) {
                            ForEach(gameState.milestones) { milestone in
                                MilestoneCard(milestone: milestone, scale: scale) {
                                    claimMilestone(milestone)
                                }
                            }
                        }
                        .padding(.horizontal, isIPad ? 40 : 14)
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
    }
    
    private func claimMilestone(_ milestone: Milestone) {
        if gameState.claimMilestone(milestone) {
            SoundManager.shared.playSuccess()
        }
    }
}

// MARK: - Milestone Card

struct MilestoneCard: View {
    let milestone: Milestone
    var scale: CGFloat = 1.0
    let onClaim: () -> Void
    
    @EnvironmentObject var gameState: GameState
    
    private var progress: Double {
        min(Double(gameState.currentFloor) / Double(milestone.targetFloor), 1.0)
    }
    
    var body: some View {
        HStack(spacing: 12 * scale) {
            // Icon
            ZStack {
                Circle()
                    .fill(milestone.isCompleted ? AppColors.gold.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 44 * scale, height: 44 * scale)
                
                if milestone.isClaimed {
                    CheckmarkIcon()
                        .frame(width: 20 * scale, height: 20 * scale)
                } else if milestone.isCompleted {
                    Star()
                        .fill(AppColors.gold)
                        .frame(width: 22 * scale, height: 22 * scale)
                } else {
                    Text("\(Int(progress * 100))%")
                        .font(AppFonts.body(11 * scale))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(milestone.name)
                    .font(AppFonts.body(15 * scale))
                    .foregroundColor(.white)
                
                Text(milestone.description)
                    .font(AppFonts.body(11 * scale))
                    .foregroundColor(.white.opacity(0.5))
                
                // Progress bar
                if !milestone.isCompleted {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.white.opacity(0.1))
                            
                            RoundedRectangle(cornerRadius: 3)
                                .fill(AppColors.accent)
                                .frame(width: geo.size.width * progress)
                        }
                    }
                    .frame(height: 4 * scale)
                }
            }
            
            Spacer()
            
            // Claim Button / Reward
            if milestone.isClaimed {
                HStack(spacing: 3) {
                    CoinIcon()
                        .frame(width: 12 * scale, height: 12 * scale)
                    Text("+\(formatNumber(milestone.reward))")
                        .font(AppFonts.body(12 * scale))
                        .foregroundColor(AppColors.gold.opacity(0.5))
                }
            } else if milestone.isCompleted {
                Button(action: onClaim) {
                    HStack(spacing: 3) {
                        CoinIcon()
                            .frame(width: 12 * scale, height: 12 * scale)
                        Text(formatNumber(milestone.reward))
                            .font(AppFonts.body(12 * scale))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10 * scale)
                    .padding(.vertical, 8 * scale)
                    .background(
                        RoundedRectangle(cornerRadius: 8 * scale)
                            .fill(AppColors.success)
                    )
                }
            } else {
                HStack(spacing: 3) {
                    CoinIcon()
                        .frame(width: 12 * scale, height: 12 * scale)
                    Text(formatNumber(milestone.reward))
                        .font(AppFonts.body(12 * scale))
                }
                .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding(12 * scale)
        .background(
            RoundedRectangle(cornerRadius: 14 * scale)
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

// MARK: - Checkmark Icon

struct CheckmarkIcon: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 4, y: 10))
            path.addLine(to: CGPoint(x: 8, y: 14))
            path.addLine(to: CGPoint(x: 16, y: 6))
        }
        .stroke(AppColors.success, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
    }
}

#Preview {
    MilestonesView()
        .environmentObject(GameState())
}
