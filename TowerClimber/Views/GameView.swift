import SwiftUI

struct GameView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var statisticsManager: StatisticsManager
    @EnvironmentObject var achievementManager: AchievementManager
    @Binding var isPresented: Bool
    
    // Platform system
    @State private var platforms: [Platform] = []
    @State private var worldOffset: CGFloat = 0 // Scrolls down as player climbs
    @State private var currentPlatformIndex: Int = 0 // Which platform player is standing on
    
    // Player state
    @State private var playerYOffset: CGFloat = 0 // Jump animation
    @State private var playerXOffset: CGFloat = 0 // Platform movement
    @State private var isJumping = false
    
    // Game loop
    @State private var targetPosition: CGFloat = 0.5 // Moving indicator on target platform
    @State private var isMovingRight = true
    @State private var gameTimer: Timer?
    @State private var breakingProgress: CGFloat = 0.0
    
    // UI State
    @State private var gameResult: GameResult?
    @State private var hasPressed = false
    @State private var showResult = false
    @State private var countdown = 3
    @State private var showCountdown = true
    @State private var currentCombo = 0
    
    // Constants - adaptive for iPad
    private var platformSpacing: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 200 : 140
    }
    private var viewHeight: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 600 : 420
    }
    
    var cycleDuration: Double {
        max(GameSettings.minCycleDuration,
            GameSettings.indicatorCycleDuration - Double(gameState.currentFloor - 1) * GameSettings.difficultyIncreasePerFloor)
    }
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            if showCountdown {
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
                ResultView(
                    result: result,
                    combo: currentCombo,
                    onContinue: { resetGame() },
                    onSaveProgress: { saveAndExit() },
                    onExit: { isPresented = false }
                )
            } else {
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
                    
                    // Tower View
                    TowerClimbView(
                        platforms: platforms,
                        worldOffset: worldOffset,
                        playerYOffset: playerYOffset,
                        playerXOffset: playerXOffset,
                        breakingProgress: breakingProgress,
                        currentPlatformId: currentPlatformIndex < platforms.count ? platforms[currentPlatformIndex].id : nil,
                        theme: themeManager.currentTheme
                    )
                    .frame(height: viewHeight)
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
                    .disabled(isJumping || hasPressed)
                    .opacity(isJumping ? 0.5 : 1.0)
                    
                    Spacer().frame(height: 50)
                }
            }
        }
        .onAppear {
            initializePlatforms()
            startCountdown()
        }
        .onDisappear {
            gameTimer?.invalidate()
            gameTimer = nil
        }
    }
    
    // MARK: - Platform Management
    
    private func initializePlatforms() {
        platforms = []
        let playerY: CGFloat = viewHeight * 0.65
        
        // Platform 0: Current (where player stands) - center
        platforms.append(Platform(
            xPosition: 0.5,
            yPosition: playerY + 20,
            type: .normal,
            isTarget: false
        ))
        
        // Platform 1: Target (above) - ALWAYS starts at 0.0
        platforms.append(Platform(
            xPosition: 0.0,
            yPosition: playerY - platformSpacing + 20,
            type: .normal,
            isTarget: true
        ))
        
        // Platform 2: Next - ALWAYS starts at 0.0
        platforms.append(Platform(
            xPosition: 0.0,
            yPosition: playerY - platformSpacing * 2 + 20,
            type: PlatformType.random(for: gameState.currentFloor + 1),
            isTarget: false
        ))
        
        currentPlatformIndex = 0
        worldOffset = 0
        targetPosition = 0.0
        isMovingRight = true
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
                withAnimation { showCountdown = false }
                startLoop()
            }
        }
    }
    
    private func startLoop() {
        guard !hasPressed else { return }
        isJumping = false
        gameTimer?.invalidate()
        
        // Update target platform position (indicator moves)
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            guard !self.hasPressed && !self.showResult else {
                self.gameTimer?.invalidate()
                return
            }
            
            // Move indicator on target platform
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
            
            // Update target platform X position
            if self.currentPlatformIndex + 1 < self.platforms.count {
                self.platforms[self.currentPlatformIndex + 1].xPosition = self.targetPosition
            }
        }
    }
    
    private func handleTap() {
        guard !isJumping && !hasPressed else { return }
        
        // Check if target platform is near center
        let tolerance: CGFloat = GameSettings.targetZoneWidth / 2 + 0.15
        let distance = abs(targetPosition - 0.5)
        let isSuccess = distance < tolerance
        
        hasPressed = true
        isJumping = true
        
        if isSuccess {
            SoundManager.shared.playTap()
            
            // Jump animation - player goes up
            withAnimation(.easeOut(duration: 0.25)) {
                playerYOffset = -platformSpacing
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                // Update game state
                self.gameState.addScore(self.gameState.calculateScoreForFloor())
                self.gameState.climbFloor()
                self.currentCombo += 1
                self.statisticsManager.recordSuccess(score: self.gameState.currentScore)
                
                self.achievementManager.checkAchievements(
                    floor: self.gameState.currentFloor,
                    score: self.gameState.currentScore,
                    combo: self.currentCombo,
                    totalGames: self.statisticsManager.stats.totalGames
                )
                self.themeManager.updateHighestFloor(self.gameState.currentFloor)
                
                SoundManager.shared.playSuccess()
                
                // Scroll world down smoothly
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.worldOffset += self.platformSpacing
                    self.playerYOffset = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    // Move to next platform
                    self.currentPlatformIndex += 1
                    
                    // Add new platform at top - ALWAYS start at 0.0 (consistent!)
                    let newYPosition = self.platforms.last!.yPosition - self.platformSpacing
                    self.platforms.append(Platform(
                        xPosition: 0.0, // Always start at left edge
                        yPosition: newYPosition,
                        type: PlatformType.random(for: self.gameState.currentFloor + 1),
                        isTarget: false
                    ))
                    
                    // Count platforms to be removed BEFORE removal
                    let platformsToRemove = self.platforms.filter { platform in
                        platform.yPosition + self.worldOffset > self.viewHeight + 100
                    }
                    let removedCount = platformsToRemove.count
                    
                    // Remove old platforms that are off screen
                    self.platforms.removeAll { platform in
                        platform.yPosition + self.worldOffset > self.viewHeight + 100
                    }
                    
                    // CRITICAL: Adjust index after removal!
                    self.currentPlatformIndex = max(0, self.currentPlatformIndex - removedCount)
                    
                    // Update target flags with CORRECTED index
                    for i in 0..<self.platforms.count {
                        self.platforms[i].isTarget = (i == self.currentPlatformIndex + 1)
                    }
                    
                    // Reset indicator - ALWAYS start at 0.0 to match platform position
                    self.targetPosition = 0.0
                    self.isMovingRight = true
                    
                    // Sync target platform (should already be at 0.0, but just in case)
                    if self.currentPlatformIndex + 1 < self.platforms.count {
                        self.platforms[self.currentPlatformIndex + 1].xPosition = self.targetPosition
                    }
                    self.hasPressed = false
                    self.isJumping = false
                    
                    // Check if standing on breaking platform - use INDEX not position
                    if self.currentPlatformIndex < self.platforms.count {
                        if self.platforms[self.currentPlatformIndex].type == .breaking {
                            self.startBreakingTimer()
                        }
                    }
                    
                    self.startLoop()
                }
            }
            
        } else {
            // Failure
            SoundManager.shared.playTap()
            
            withAnimation(.easeOut(duration: 0.2)) {
                playerYOffset = -platformSpacing * 0.5
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                SoundManager.shared.playMiss()
                withAnimation(.easeIn(duration: 0.5)) {
                    self.playerYOffset = 500
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.autoSaveProgress()
                self.gameResult = .tryAgain
                self.showResult = true
            }
        }
    }
    
    private func resetGame() {
        gameState.resetProgress()
        
        hasPressed = false
        gameResult = nil
        showResult = false
        isJumping = false
        targetPosition = 0.2
        isMovingRight = true
        breakingProgress = 0.0
        playerXOffset = 0.0
        playerYOffset = 0
        currentCombo = 0
        worldOffset = 0
        
        initializePlatforms()
        showCountdown = false
        startLoop()
    }
    
    private func saveAndExit() {
        isPresented = false
    }
    
    private func autoSaveProgress() {
        statisticsManager.recordGame(
            floor: gameState.currentFloor,
            score: gameState.currentScore,
            combo: currentCombo
        )
        themeManager.updateHighestFloor(gameState.currentFloor)
        achievementManager.checkAchievements(
            floor: gameState.currentFloor,
            score: gameState.currentScore,
            combo: currentCombo,
            totalGames: statisticsManager.stats.totalGames
        )
        gameState.saveProgress()
    }
    
    private func startBreakingTimer() {
        breakingProgress = 0.0
        
        // 2 second breaking timer
        let startTime = Date()
        let duration: TimeInterval = 2.0
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            let elapsed = Date().timeIntervalSince(startTime)
            self.breakingProgress = CGFloat(elapsed / duration)
            
            // If player jumped away, stop timer
            if self.isJumping || self.hasPressed {
                timer.invalidate()
                return
            }
            
            // Platform breaks - game over
            if elapsed >= duration {
                timer.invalidate()
                self.breakingProgress = 1.0
                
                // Fall to death
                SoundManager.shared.playMiss()
                withAnimation(.easeIn(duration: 0.5)) {
                    self.playerYOffset = 500
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.autoSaveProgress()
                    self.gameResult = .tryAgain
                    self.showResult = true
                }
            }
        }
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
