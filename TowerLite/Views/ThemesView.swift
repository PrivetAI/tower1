import SwiftUI

struct ThemesView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Current theme preview
                        VStack(spacing: 12) {
                            Text("Current Theme")
                                .font(AppFonts.body(14))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text(themeManager.currentTheme.icon)
                                .font(.system(size: 60))
                            
                            Text(themeManager.currentTheme.name)
                                .font(AppFonts.title(24))
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 20)
                        
                        // Theme grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(TowerTheme.allThemes) { theme in
                                ThemeCard(
                                    theme: theme,
                                    isSelected: themeManager.currentTheme.id == theme.id,
                                    isUnlocked: themeManager.isUnlocked(theme),
                                    highestFloor: themeManager.highestFloorReached
                                ) {
                                    if themeManager.isUnlocked(theme) {
                                        SoundManager.shared.playButton()
                                        themeManager.selectTheme(theme)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Tower Themes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.gold)
                }
            }
        }
    }
}

struct ThemeCard: View {
    let theme: TowerTheme
    let isSelected: Bool
    let isUnlocked: Bool
    let highestFloor: Int
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                // Theme icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [theme.topColor, theme.baseColor],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 80)
                    
                    if !isUnlocked {
                        Color.black.opacity(0.6)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        VStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 20))
                            Text("Floor \(theme.unlockRequirement)")
                                .font(AppFonts.body(12))
                        }
                        .foregroundColor(.white)
                    } else {
                        Text(theme.icon)
                            .font(.system(size: 40))
                    }
                }
                
                // Theme name
                Text(theme.name)
                    .font(AppFonts.body(14))
                    .foregroundColor(isUnlocked ? .white : .white.opacity(0.5))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSelected ? AppColors.gold : Color.clear, lineWidth: 3)
                    )
            )
        }
        .disabled(!isUnlocked)
        .accessibilityLabel("\(theme.name) theme. \(isUnlocked ? (isSelected ? "Selected" : "Available") : "Locked. Reach floor \(theme.unlockRequirement) to unlock")")
    }
}

#Preview {
    ThemesView()
        .environmentObject(ThemeManager())
}
