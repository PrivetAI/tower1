import SwiftUI

@main
struct TowerLiteApp: App {
    @StateObject private var gameState = GameState()
    @StateObject private var achievementManager = AchievementManager()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var statisticsManager = StatisticsManager()
    @ObservedObject private var soundManager = SoundManager.shared
    
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView(showSplash: $showSplash)
                        .transition(.opacity)
                } else {
                    NavigationView {
                        HomeView()
                    }
                    .navigationViewStyle(.stack)
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showSplash)
            .environmentObject(gameState)
            .environmentObject(achievementManager)
            .environmentObject(themeManager)
            .environmentObject(statisticsManager)
            .environmentObject(soundManager)
            .onAppear {
                statisticsManager.startSession()
            }
        }
    }
}
