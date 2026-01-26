import SwiftUI

struct GameView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var statisticsManager: StatisticsManager
    @EnvironmentObject var achievementManager: AchievementManager
    @Binding var isPresented: Bool
    
    // State for Infinite Climber
    @State private var targetPosition: CGFloat = 0.5 // The moving platform (Top)
    @State private var currentPosition: CGFloat = 0.5 // The static platform (Bottom)
    @State private var scrollOffset: CGFloat = 0
    @State private var playerYOffset: CGFloat = 0
    @State private var isJumping = false
    
    // Animation constants
    private let floorHeight: CGFloat = 300 * 0.4
    
    // Movement Logic
    @State private var isMovingRight = true
    
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
                        playerYOffset: playerYOffset
                    )
                    .frame(height: 300)
                    .padding(.horizontal, 20)
                    .clipped()
                    
                    Text("Jump precisely when the top platform aligns!")
                        .font(AppFonts.body(14))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    // Jump Button
                    Button(action: handleTap) {
                        Text("JUMP!")
                            .font(AppFonts.title(32))
                            .foregroundColor(.white)
                            .frame(width: 160, height: 160)
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
                    .disabled(isJumping || hasPressed) // Lock input during jump
                    .opacity(isJumping ? 0.5 : 1.0)
                    
                    Spacer().frame(height: 50)
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
        // Reset state
        currentPosition = 0.5
        targetPosition = 0.0
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
        
        // Ensure inputs are unlocked
        isJumping = false
        
        // Loop Animation for the Target Platform using updated duration
        animateTarget()
    }
    
    private func animateTarget() {
        guard !hasPressed && !showResult else { return }
        
        let destination: CGFloat = isMovingRight ? 1.0 : 0.0
        
        // Calculate duration based on distance to ensure constant speed?
        // Or simple cycle based on floor?
        // Let's stick to simple ping-pong with duration from settings
        
        withAnimation(.linear(duration: cycleDuration / 2)) {
            targetPosition = destination
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + cycleDuration / 2) {
            if !self.hasPressed && !self.showResult {
                self.isMovingRight.toggle()
                self.animateTarget()
            }
        }
    }
    
    private func handleTap() {
        guard !isJumping && !hasPressed else { return }
        
        // Calculate collision
        // Player effectively at 0.5 (Center) of the screen WIDTH-wise?
        // Wait, visually the player is at center (width/2).
        // The Platform follows 'targetPosition' (0..1).
        // To Land, the Platform must be roughly centered.
        // Platform X = minX + (maxX-minX)*pos
        // Player X = Center = width/2.
        // So we need to check if Platform's frame overlaps Center.
        
        // We know Platform Width is relative to screen width via settings.
        // Logic: if targetPosition is roughly 0.5, it's a hit?
        // Yes, because current implementation puts Player FIXED at Center.
        // So the user must time it so the moving platform hits the center.
        
        // Hit Zone Logic:
        // Platform is at `targetPosition` (0..1).
        // Center is 0.5.
        // Hit range is 0.5 +/- (platformWidthInPercent / 2 in terms of position space?)
        // Wait, position 0 = Left Edge, 1 = Right Edge.
        // Center is 0.5.
        // So yes, simply checking if `targetPosition` is close to 0.5 is correct
        // IF the platform travel covers the full width. 
        // Our visualization does full width traversal.
        
        // Let's refactor `targetZoneWidth` to be "Tolerance" in 0..1 space.
        // If platform is at 0.5, it is perfectly centered.
        // If platform is at 0.5 +/- 0.15, it overlaps center enough?
        
        // Actual math:
        // Hit if abs(targetPosition - 0.5) < (GameSettings.targetZoneWidth / 2)
        // Wait, GameSettings.targetZoneWidth IS the platform width (0.3).
        // IF platform width is 0.3 of screen...
        // And travel distance is roughly 0.8 of screen...
        // Then 1.0 unit of position = 0.8 screen width.
        // Platform width = 0.3 screen width = (0.3/0.8) units of position ≈ 0.375 units.
        // So if platform center is within 0.375/2 of player center (0.5), it's a hit?
        // Yes.
        
        let tolerance = (GameSettings.targetZoneWidth / 0.8) / 2
        let distance = abs(targetPosition - 0.5)
        let isSuccess = distance < tolerance
        
        hasPressed = true // Lock logic loop
        isJumping = true  // Lock input
        
        // Stop the platform at current spot for visual clarity
        // Using specific withAnimation block to freeze it? 
        // The linear animation is ongoing... hard to kill midway without complex state.
        // Easier: Just let it slide or (better) snap to the tapped value?
        // SwiftUI animation cancel is tricky. We'll just define the outcome.
        
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
                SoundManager.shared.playSuccess()
                
                // 3. Scroll World Down
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.scrollOffset = self.floorHeight // Move world DOWN
                    self.playerYOffset = 0 // Player moves 'down' relative to world (stays stuck to platform)
                }
                
                // 4. Reset for next floor
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // Instant reset logic to loop
                    self.scrollOffset = 0 // Reset container
                    self.currentPosition = 0.5 // Previous target is now current (Center, because we hit it!)
                    // Wait, if we hit it at offset, should we stay offset?
                    // For simplicity, let's "Snap" to center as if player corrected balance?
                    // Or keep 'currentPosition' = 'targetPosition' (the actual hit spot).
                    // Infinite climber usually you stay where you landed.
                    // But our Player is FIXED X=Center. So we must treat "Success" as "Platform aligned with Center".
                    // So effectively, we are now on a platform at Center.
                    self.currentPosition = 0.5 
                    
                    self.targetPosition = self.isMovingRight ? 0.0 : 1.0 // Start from side
                    self.hasPressed = false
                    self.startLoop()
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
