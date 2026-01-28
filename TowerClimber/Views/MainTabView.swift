import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var gameState: GameState
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Content
            Group {
                switch selectedTab {
                case 0:
                    GameView()
                case 1:
                    UpgradesView()
                case 2:
                    MilestonesView()
                case 3:
                    SettingsView()
                default:
                    GameView()
                }
            }
            
            // Custom Tab Bar
            HStack(spacing: 0) {
                TabBarButton(
                    icon: "tower",
                    label: "Climb",
                    isSelected: selectedTab == 0,
                    action: { selectedTab = 0 }
                )
                
                TabBarButton(
                    icon: "upgrades",
                    label: "Upgrades",
                    isSelected: selectedTab == 1,
                    action: { selectedTab = 1 }
                )
                
                ZStack {
                    TabBarButton(
                        icon: "milestones",
                        label: "Goals",
                        isSelected: selectedTab == 2,
                        badge: gameState.unclaimedMilestones,
                        action: { selectedTab = 2 }
                    )
                }
                
                TabBarButton(
                    icon: "settings",
                    label: "Stats",
                    isSelected: selectedTab == 3,
                    action: { selectedTab = 3 }
                )
            }
            .padding(.horizontal, 8)
            .padding(.top, 12)
            .padding(.bottom, 24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(hex: "1a1a2e").opacity(0.95))
                    .shadow(color: .black.opacity(0.3), radius: 10, y: -5)
            )
            .padding(.horizontal, 12)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Tab Bar Button

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    var badge: Int = 0
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            SoundManager.shared.playButton()
            action()
        }) {
            VStack(spacing: 4) {
                ZStack {
                    tabIcon
                        .frame(width: 24, height: 24)
                    
                    if badge > 0 {
                        Circle()
                            .fill(AppColors.accent)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Text("\(badge)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 12, y: -10)
                    }
                }
                
                Text(label)
                    .font(AppFonts.body(10))
            }
            .foregroundColor(isSelected ? AppColors.accent : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    var tabIcon: some View {
        switch icon {
        case "tower":
            TabTowerIcon(isSelected: isSelected)
        case "upgrades":
            TabUpgradesIcon(isSelected: isSelected)
        case "milestones":
            TabMilestonesIcon(isSelected: isSelected)
        case "settings":
            TabSettingsIcon(isSelected: isSelected)
        default:
            Circle().fill(isSelected ? AppColors.accent : .white.opacity(0.5))
        }
    }
}

// MARK: - Tab Icons

struct TabTowerIcon: View {
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(isSelected ? AppColors.accent : .white.opacity(0.5))
                .frame(width: 10, height: 16)
            
            Triangle()
                .fill(isSelected ? AppColors.accent : .white.opacity(0.5))
                .frame(width: 14, height: 7)
                .offset(y: -10)
        }
    }
}

struct TabUpgradesIcon: View {
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 12, y: 4))
                path.addLine(to: CGPoint(x: 12, y: 20))
                path.move(to: CGPoint(x: 6, y: 10))
                path.addLine(to: CGPoint(x: 12, y: 4))
                path.addLine(to: CGPoint(x: 18, y: 10))
            }
            .stroke(isSelected ? AppColors.accent : .white.opacity(0.5), lineWidth: 2)
        }
    }
}

struct TabMilestonesIcon: View {
    let isSelected: Bool
    
    var body: some View {
        Star()
            .fill(isSelected ? AppColors.accent : .white.opacity(0.5))
    }
}

struct TabSettingsIcon: View {
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(isSelected ? AppColors.accent : .white.opacity(0.5), lineWidth: 2)
                .frame(width: 16, height: 16)
            
            ForEach(0..<4) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(isSelected ? AppColors.accent : .white.opacity(0.5))
                    .frame(width: 2, height: 6)
                    .offset(y: -11)
                    .rotationEffect(.degrees(Double(i) * 90))
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(GameState())
        .environmentObject(SoundManager.shared)
}
