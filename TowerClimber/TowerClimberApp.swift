import SwiftUI

@main
struct TowerClimberApp: App {
    @StateObject private var gameState = GameState()
    @ObservedObject private var soundManager = SoundManager.shared
    
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView(showSplash: $showSplash)
                        .transition(.opacity)
                } else {
                    HomeView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showSplash)
            .environmentObject(gameState)
            .environmentObject(soundManager)
            .preferredColorScheme(.dark)
        }
    }
}
