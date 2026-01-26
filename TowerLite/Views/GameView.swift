import SwiftUI

struct GameView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var statisticsManager: StatisticsManager
    @EnvironmentObject var achievementManager: AchievementManager
    @Binding var isPresented: Bool
    
    @State private var indicatorPosition: CGFloat = 0
    @State private var isMovingRight = true
    @State private var gameResult: GameResult?
    @State private var hasPressed = false
    @State private var showResult = false
    @State private var countdown = 3
    @State private var showCountdown = true
    @State private var currentCombo = 0
    
    private var targetZoneStart: CGFloat {
        GameSettings.targetZonePosition - (GameSettings.targetZoneWidth / 2)
    }
    
    private var targetZoneEnd: CGFloat {
        GameSettings.targetZonePosition + (GameSettings.targetZoneWidth / 2)
    }
    
    var cycleDuration: Double {
        // Speed increases with floor level (skill-based difficulty)
        max(GameSettings.minCycleDuration,
            GameSettings.indicatorCycleDuration - Double(gameState.currentFloor - 1) * GameSettings.difficultyIncreasePerFloor)
    }
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            if showCountdown {
                // Countdown
                VStack(spacing: 20) {
                    Text("Floor \(gameState.currentFloor)")
                        .font(AppFonts.title(24))
                        .foregroundColor(.white)
                    
                    Text("\(countdown)")
                        .font(AppFonts.number(100))
                        .foregroundColor(AppColors.gold)
                        .scaleEffect(countdown > 0 ? 1.0 : 1.5)
                        .accessibilityLabel("Starting in \(countdown)")
                }
            } else if showResult, let result = gameResult {
                // Result
                ResultView(
                    result: result,
                    combo: currentCombo,
                    onContinue: {
                        resetGame()
                    },
                    onSaveProgress: {
                        saveAndExit()
                    },
                    onExit: {
                        isPresented = false
                    }
                )
            } else {
                // Game
                VStack(spacing: 40) {
                    // Header
                    HStack {
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .accessibilityLabel("Close")
                        
                        Spacer()
                        
                        // Combo indicator
                        if currentCombo > 1 {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                Text("x\(currentCombo)")
                                    .font(AppFonts.title(18))
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.orange.opacity(0.2))
                            )
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Floor \(gameState.currentFloor)")
                                .font(AppFonts.body(16))
                                .foregroundColor(.white)
                            Text("+\(gameState.calculateScoreForFloor()) pts")
                                .font(AppFonts.body(14))
                                .foregroundColor(AppColors.gold)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Floor \(gameState.currentFloor), \(gameState.calculateScoreForFloor()) points available")
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Instructions
                    Text("Jump when the platform aligns with you!")
                        .font(AppFonts.body(16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isStaticText)
                    
                    // Tower Climb View (The "Game Area")
                    TowerClimbView(
                        position: indicatorPosition,
                        targetZoneStart: targetZoneStart,
                        targetZoneEnd: targetZoneEnd
                    )
                    .frame(height: 300) // Much taller for the visual
                    .padding(.horizontal, 20)
                    .accessibilityLabel("Moving platform below you")
                    
                    Spacer()
                    
                    // Tap Button
                    Button(action: handleTap) {
                        Text("JUMP!")
                            .font(AppFonts.title(32))
                            .foregroundColor(.white)
                            .frame(width: 160, height: 160) // Slightly smaller button to balance UI
                            .background(
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [AppColors.accent, AppColors.accent.opacity(0.6)],
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: 80
                                        )
                                    )
                                    .shadow(color: AppColors.accent.opacity(0.5), radius: 20, y: 10)
                            )
                    }
                    .disabled(hasPressed)
                    .opacity(hasPressed ? 0.5 : 1.0)
                    .accessibilityLabel("Tap button")
                    .accessibilityHint("Tap when indicator is in green zone")
                    
                    Spacer()
                        .frame(height: 50)
                }
            }
        }
        .onAppear {
            startCountdown()
        }
    }
    
    private func startCountdown() {
        countdown = 3
        showCountdown = true
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            SoundManager.shared.playCountdown()
            if countdown > 1 {
                countdown -= 1
            } else {
                timer.invalidate()
                withAnimation {
                    showCountdown = false
                }
                startIndicatorAnimation()
            }
        }
    }
    
    private func startIndicatorAnimation() {
        indicatorPosition = 0
        isMovingRight = true
        animateIndicator()
    }
    
    private func animateIndicator() {
        guard !hasPressed else { return }
        
        let targetPosition: CGFloat = isMovingRight ? 1.0 : 0.0
        
        withAnimation(.linear(duration: cycleDuration / 2)) {
            indicatorPosition = targetPosition
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + cycleDuration / 2) {
            if !self.hasPressed {
                self.isMovingRight.toggle()
                self.animateIndicator()
            }
        }
    }
    
    private func handleTap() {
        guard !hasPressed else { return }
        hasPressed = true
        
        SoundManager.shared.playTap()
        
        // Check if in target zone
        let isSuccess = indicatorPosition >= targetZoneStart && indicatorPosition <= targetZoneEnd
        
        if isSuccess {
            let score = gameState.calculateScoreForFloor()
            gameState.addScore(score)
            gameState.climbFloor()
            currentCombo += 1
            
            // Update statistics
            statisticsManager.recordSuccess(score: score)
            statisticsManager.updateCombo(currentCombo)
            themeManager.updateHighestFloor(gameState.currentFloor)
            
            // Check achievements
            achievementManager.checkAchievements(
                floor: gameState.currentFloor,
                score: gameState.currentScore,
                combo: currentCombo,
                totalGames: statisticsManager.stats.totalGames
            )
            
            SoundManager.shared.playSuccess()
            gameResult = .success(score: score)
        } else {
            // Reset combo on miss
            currentCombo = 0
            statisticsManager.recordMiss()
            SoundManager.shared.playMiss()
            gameResult = .tryAgain
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                showResult = true
            }
        }
    }
    
    private func resetGame() {
        hasPressed = false
        gameResult = nil
        showResult = false
        startCountdown()
    }
    
    private func saveAndExit() {
        // Record game stats before saving
        statisticsManager.recordGame(
            floor: gameState.currentFloor,
            score: gameState.currentScore,
            combo: currentCombo
        )
        
        // Check achievements with final stats
        achievementManager.checkAchievements(
            floor: gameState.currentFloor,
            score: gameState.currentScore,
            combo: currentCombo,
            totalGames: statisticsManager.stats.totalGames + 1
        )
        
        gameState.saveProgress()
        isPresented = false
    }
}

// MARK: - Game Result

enum GameResult {
    case success(score: Int)
    case tryAgain
    
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
}

#Preview {
    GameView(isPresented: .constant(true))
        .environmentObject(GameState())
        .environmentObject(ThemeManager())
        .environmentObject(StatisticsManager())
        .environmentObject(AchievementManager())
}
