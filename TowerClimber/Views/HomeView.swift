import SwiftUI

struct HomeView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var achievementManager: AchievementManager
    
    @State private var showGame = false
    @State private var showHistory = false
    @State private var showAchievements = false
    @State private var showThemes = false
    @State private var showStatistics = false
    @State private var showSettings = false
    @State private var climbButtonScale: CGFloat = 1.0
    @State private var showAchievementPopup = false
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header Stats
                HStack(spacing: 20) {
                    StatCard(title: "Floor", value: "\(gameState.currentFloor)", icon: "building.2")
                    StatCard(title: "Score", value: "\(gameState.currentScore)", icon: "star.fill")
                }
                .padding(.horizontal)
                
                // Best Score
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(AppColors.gold)
                    Text("Best: \(gameState.bestScore)")
                        .font(AppFonts.body(16))
                        .foregroundColor(AppColors.gold)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(AppColors.cardBackground)
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Best score: \(gameState.bestScore)")
                
                Spacer()
                
                // Tower Visual with theme
                VStack {
                    ThemedTowerAnimation(
                        height: CGFloat(min(gameState.currentFloor * 20, 200)),
                        maxHeight: 200,
                        theme: themeManager.currentTheme
                    )
                    .frame(height: 200)
                    .accessibilityHidden(true)
                    
                    Text("Floor \(gameState.currentFloor)")
                        .font(AppFonts.body(14))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Climb Button
                Button(action: {
                    SoundManager.shared.playButton()
                    showGame = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 28))
                        Text("Climb")
                            .font(AppFonts.title(28))
                    }
                    .foregroundColor(.white)
                    .frame(width: 220, height: 70)
                    .background(
                        RoundedRectangle(cornerRadius: 35)
                            .fill(
                                LinearGradient(
                                    colors: [themeManager.currentTheme.topColor, themeManager.currentTheme.baseColor],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: themeManager.currentTheme.baseColor.opacity(0.5), radius: 15, y: 8)
                    )
                }
                .scaleEffect(climbButtonScale)
                .accessibilityLabel("Climb to next floor")
                .accessibilityHint("Start a timing challenge")
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        climbButtonScale = 1.05
                    }
                }
                
                Spacer()
                    .frame(minHeight: 10)
                
                // Bottom Navigation
                HStack(spacing: 30) {
                    NavButton(icon: "clock.arrow.circlepath", title: "History") {
                        SoundManager.shared.playButton()
                        showHistory = true
                    }
                    NavButton(icon: "trophy", title: "Awards") {
                        SoundManager.shared.playButton()
                        showAchievements = true
                    }
                    NavButton(icon: "paintpalette", title: "Themes") {
                        SoundManager.shared.playButton()
                        showThemes = true
                    }
                    NavButton(icon: "chart.bar", title: "Stats") {
                        SoundManager.shared.playButton()
                        showStatistics = true
                    }
                    NavButton(icon: "gearshape", title: "Settings") {
                        SoundManager.shared.playButton()
                        showSettings = true
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.top, 20)
            
            // Achievement popup
            if showAchievementPopup, let achievement = achievementManager.newlyUnlocked {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showAchievementPopup = false
                    }
                
                AchievementPopup(achievement: achievement) {
                    showAchievementPopup = false
                    achievementManager.newlyUnlocked = nil
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showGame) {
            GameView(isPresented: $showGame)
        }
        .sheet(isPresented: $showHistory) {
            HistoryView()
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsView()
        }
        .sheet(isPresented: $showThemes) {
            ThemesView()
        }
        .sheet(isPresented: $showStatistics) {
            StatisticsView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onChange(of: achievementManager.newlyUnlocked) { _ in
            if achievementManager.newlyUnlocked != nil {
                SoundManager.shared.playAchievement()
                showAchievementPopup = true
            }
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppColors.gold)
            
            Text(value)
                .font(AppFonts.number(32))
                .foregroundColor(.white)
            
            Text(title)
                .font(AppFonts.body(14))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.cardBackground)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

// MARK: - Nav Button

struct NavButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                Text(title)
                    .font(AppFonts.body(10))
            }
            .foregroundColor(.white.opacity(0.8))
        }
        .accessibilityLabel(title)
    }
}

#Preview {
    HomeView()
        .environmentObject(GameState())
        .environmentObject(ThemeManager())
        .environmentObject(AchievementManager())
        .environmentObject(StatisticsManager())
        .environmentObject(SoundManager.shared)
}
