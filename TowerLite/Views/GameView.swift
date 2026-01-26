import SwiftUI

struct GameView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var statisticsManager: StatisticsManager
    @EnvironmentObject var achievementManager: AchievementManager
    @Binding var isPresented: Bool
    
    @State private var targetPosition: CGFloat = 0.5 // The moving platform (Top)
    @State private var currentPosition: CGFloat = 0.5 // The static platform (Bottom)
    @State private var scrollOffset: CGFloat = 0
    @State private var playerYOffset: CGFloat = 0
    @State private var isJumping = false
    @State private var currentPlatformType: PlatformType = .normal // The target platform (Top)
    @State private var standingOnPlatformType: PlatformType = .normal // The platform under player (Bottom)
    @State private var gameTimer: Timer? // Manual timer for game loop
    @State private var breakingProgress: CGFloat = 0.0 // 0.0 to 1.0 for cracking animation
    @State private var movingPlatformOffset: CGFloat = 0.0 // Side-to-side movement
    @State private var movingPlatformDirection: CGFloat = 1.0 // 1.0 or -1.0
    
    // Legacy State (Restored)
    @State private var gameResult: GameResult?
    @State private var hasPressed = false
    @State private var showResult = false
    @State private var countdown = 3
    @State private var showCountdown = true
    @State private var currentCombo = 0
    
    // Animation constants
    // TowerClimbView height = 420
    // Distance = 168 pixels, but adding boost to ensure it visually CLEARS the gap
    private let floorHeight: CGFloat = 230 // Huge jump to guarantee clearance
    
    // Movement Logic
    @State private var isMovingRight = true
    
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
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        Spacer()
                        
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
                            .background(Capsule().fill(Color.orange.opacity(0.2)))
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
                    }
                    .padding()
                    
                    Spacer()
                    
                    // The Tower View (Game Area)
                    TowerClimbView(
                        targetPosition: targetPosition,
                        currentPosition: currentPosition,
                        scrollOffset: scrollOffset,
                        isJumping: isJumping,
                        playerYOffset: playerYOffset,
                        targetPlatformType: currentPlatformType,
                        currentPlatformType: standingOnPlatformType,
                        breakingProgress: breakingProgress,
                        movingPlatformOffset: movingPlatformOffset
                    )
                    .frame(height: 420)
                    .padding(.horizontal, 16)
                    .clipped()
                    
                    Spacer()
                    
                    // Jump Button
                    Button(action: handleTap) {
                        Text("JUMP!")
                            .font(AppFonts.title(24))
                            .foregroundColor(.white)
                            .frame(width: 110, height: 110)
                            .background(
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [AppColors.accent, AppColors.accent.opacity(0.6)],
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: 55
                                        )
                                    )
                                    .shadow(color: AppColors.accent.opacity(0.5), radius: 15, y: 8)
                            )
                    }
                    .disabled(isJumping || hasPressed) // Lock input during jump
                    .opacity(isJumping ? 0.5 : 1.0)
                    
                    Spacer().frame(height: 50)
                }
            }
        }
        .onAppear {
            startCountdown()
        }
        .onDisappear {
            gameTimer?.invalidate()
            gameTimer = nil
        }
    }
    
    private func startCountdown() {
        countdown = 3
        showCountdown = true
        // Reset state
        currentPosition = 0.5
        targetPosition = 0.2 // Start closer to center so early taps don't immediately fail
        isMovingRight = true
        scrollOffset = 0
        playerYOffset = 0
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            SoundManager.shared.playCountdown()
            if countdown > 1 {
                countdown -= 1
            } else {
                timer.invalidate()
                withAnimation { showCountdown = false }
                startLoop()
            }
        }
    }
    
    private func startLoop() {
        guard !hasPressed else { return }
        isJumping = false
        gameTimer?.invalidate()
        
        // Manual game loop for accurate collision detection
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            guard !self.hasPressed && !self.showResult else {
                self.gameTimer?.invalidate()
                return
            }
            
            // Move target indicator
            let speed = 0.016 / (self.cycleDuration / 2)
            if self.isMovingRight {
                self.targetPosition += speed
                if self.targetPosition >= 1.0 {
                    self.targetPosition = 1.0
                    self.isMovingRight = false
                }
            } else {
                self.targetPosition -= speed
                if self.targetPosition <= 0.0 {
                    self.targetPosition = 0.0
                    self.isMovingRight = true
                }
            }
            
            // Animate moving platform side-to-side
            if self.currentPlatformType == .moving {
                let movingSpeed: CGFloat = 30.0 // pixels per second
                let maxOffset: CGFloat = 40.0
                self.movingPlatformOffset += self.movingPlatformDirection * movingSpeed * 0.016
                if abs(self.movingPlatformOffset) >= maxOffset {
                    self.movingPlatformDirection *= -1
                    self.movingPlatformOffset = maxOffset * self.movingPlatformDirection
                }
            }
        }
    }
    
    // Legacy function removed
    private func animateTarget() {}
    
    private func handleTap() {
        guard !isJumping && !hasPressed else { return }
        
        // Calculate collision with platform-specific tolerance
        // Normal tolerance
        var tolerance = (GameSettings.targetZoneWidth / 0.8) / 2
        
        // Slippery platform has narrower hit zone
        if currentPlatformType == .slippery {
            tolerance *= 0.6 // 40% harder to hit
        }
        
        let distance = abs(targetPosition - 0.5)
        let isSuccess = distance < tolerance
        
        hasPressed = true // Lock logic loop
        isJumping = true  // Lock input
        
        if isSuccess {
            // SUCCESS SEQUENCE
            SoundManager.shared.playTap()
            
            // 1. Jump Up Animation
            withAnimation(.easeOut(duration: 0.3)) {
                playerYOffset = -floorHeight // Move player UP effectively
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // 2. Landed. Update stats.
                self.gameState.addScore(self.gameState.calculateScoreForFloor())
                self.gameState.climbFloor()
                self.currentCombo += 1
                self.statisticsManager.recordSuccess(score: self.gameState.currentScore)
                
                // Check for achievements after each successful jump
                self.achievementManager.checkAchievements(
                    floor: self.gameState.currentFloor,
                    score: self.gameState.currentScore,
                    combo: self.currentCombo,
                    totalGames: self.statisticsManager.stats.totalGames
                )
                
                SoundManager.shared.playSuccess()
                
                // 3. Scroll World Down
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.scrollOffset = self.floorHeight // Move world DOWN
                    self.playerYOffset = 0 // Player moves 'down' relative to world (stays stuck to platform)
                }
                
                // 4. Reset for next floor
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.scrollOffset = 0
                    
                    // Seamless transition: Current position becomes where we landed
                    self.currentPosition = self.targetPosition
                    self.standingOnPlatformType = self.currentPlatformType
                    
                    // Randomize next platform type based on floor
                    self.currentPlatformType = PlatformType.random(for: self.gameState.currentFloor)
                    
                    self.targetPosition = self.isMovingRight ? 0.0 : 1.0
                    self.hasPressed = false
                    
                    // Reset moving platform offset for next platform
                    self.movingPlatformOffset = 0.0
                    self.movingPlatformDirection = 1.0
                    
                    self.startLoop()
                    self.startBreakingAnimation()
                }
            }
            
        } else {
            // FAILURE SEQUENCE
             SoundManager.shared.playTap()
            
            // 1. Jump Up...
            withAnimation(.easeOut(duration: 0.2)) {
                playerYOffset = -floorHeight * 0.5 // Short hop
            }
            
            // 2. Fall Down!
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                SoundManager.shared.playMiss()
                withAnimation(.easeIn(duration: 0.5)) {
                    playerYOffset = 500 // Fall off screen
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                 gameResult = .tryAgain
                 showResult = true
            }
        }
    }
    
    private func resetGame() {
        hasPressed = false
        gameResult = nil
        showResult = false
        isJumping = false
        targetPosition = 0.2 // Reset to starting position
        isMovingRight = true
        currentPlatformType = .normal
        standingOnPlatformType = .normal
        breakingProgress = 0.0
        movingPlatformOffset = 0.0
        movingPlatformDirection = 1.0
        startCountdown()
    }
    
    private func startBreakingAnimation() {
        guard standingOnPlatformType == .breaking else {
            breakingProgress = 0.0
            return
        }
        
        // Gradually increase breaking progress over 3 seconds
        let startTime = Date()
        let duration: TimeInterval = 3.0
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            let elapsed = Date().timeIntervalSince(startTime)
            self.breakingProgress = min(CGFloat(elapsed / duration), 1.0)
            
            if elapsed >= duration {
                timer.invalidate()
                // Platform breaks - game over
                self.gameResult = .tryAgain
                self.showResult = true
                self.stopGameLoop()
                SoundManager.shared.playTap() // Fail sound
            }
            
            if self.hasPressed {
                timer.invalidate()
            }
        }
    }
    
    private func stopGameLoop() {
        gameTimer?.invalidate()
        gameTimer = nil
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
