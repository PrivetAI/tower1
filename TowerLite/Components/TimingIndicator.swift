import SwiftUI

struct TowerClimbView: View {
    // Current state inputs
    let targetPosition: CGFloat // 0.0 to 1.0 (The moving platform ABOVE)
    let currentPosition: CGFloat // 0.0 to 1.0 (The static platform BELOW)
    let scrollOffset: CGFloat // Vertical scroll of the world (0 = resting, positive = scrolling down)
    let isJumping: Bool // Is the player currently mid-air?
    let playerYOffset: CGFloat // Vertical animation offset for the player jump
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            // Dimensions
            let platformWidth = width * GameSettings.targetZoneWidth
            let playerSize: CGFloat = 40
            let floorHeight = height * 0.4
            
            // The "World" container that scrolls
            ZStack {
                // Background Tower Wall (Infinite scrolling brick pattern)
                TowerBackground(width: width, height: height, scrollOffset: scrollOffset)
                
                // --- MOVING ELEMENTS ---
                
                // 1. Current Platform (Bottom)
                // Moves DOWN as we scroll
                PlatformView(width: platformWidth)
                    .position(
                        x: calculateX(for: currentPosition, width: width, platformWidth: platformWidth),
                        y: height * 0.8 + scrollOffset
                    )
                
                // 2. Target Platform (Top)
                // Moves LEFT/RIGHT (gameplay) and DOWN (scroll)
                PlatformView(width: platformWidth)
                    .position(
                        x: calculateX(for: targetPosition, width: width, platformWidth: platformWidth),
                        y: height * 0.4 + scrollOffset
                    )
                
                // 3. Player
                // If IDLE: Sits on Current Platform (Bottom)
                // If JUMPING: Interpolates to Target Platform (Top)
                // Visually: We keep the player roughly centered in the view, but they animate UP relative to the world
                // Actually: In this "camera fixed on player" vs "world scrolls" logic:
                // We keep player fixed Y, and world moves? Or player jumps Y and then lands?
                // Let's do: Player moves Y (jump), and when 'Landed', we reset players Y and shift World Y instantly to loop.
                // Or better for SwiftUI: 
                // Player sits at `height * 0.8`.
                // When Jump: Player animates to `height * 0.4`.
                // When Land: Whole world shifts `+floorHeight`, and Player instantly resets to `height * 0.8` (relative to new floor).
                
                // Simplified for this component:
                // Player is drawn at a fixed Y + playerYOffset
                // The logical "Bottom" is Y=0.8. The logical "Top" is Y=0.4.
                // Jump animation will tweak playerYOffset from 0 to -floorHeight.
                
                Image(systemName: "figure.climbing")
                    .resizable()
                    .scaledToFit()
                    .frame(width: playerSize, height: playerSize)
                    .foregroundColor(AppColors.gold)
                    .shadow(color: AppColors.gold.opacity(0.6), radius: 8)
                    .rotationEffect(.degrees(-10))
                    // Player X follows the platform they are currently ON. 
                    // While jumping, they should lerp to the target X? Or jump straight up?
                    // "Tower" logic usually implies jumping straight up or slightly towards center. 
                    // For simplicity: Player stays physically X-aligned with the platform they launched from until mid-air?
                    // No, let's keep Player X Center for now as per previous logic, OR make player X dynamic.
                    // Let's stick to: Player is CENTERED. Platforms move under him.
                    // This implies the Current Platform must be ALIGNED with Center for the player to be there?
                    // Wait, previous logic was: Player Center. Platform Moves. You jump when aligned.
                    // So Player X = Center.
                    .position(x: width / 2, y: height * 0.8 + playerYOffset + scrollOffset)
                    
            }
            .clipped() // Clip anything outside the tower view
        }
    }
    
    // Helper to calculate X screen coordinate from 0..1 normalized position
    private func calculateX(for pos: CGFloat, width: CGFloat, platformWidth: CGFloat) -> CGFloat {
        let trackWidth = width * 0.8
        let minX = (width - trackWidth) / 2 + platformWidth/2
        let maxX = width - (width - trackWidth) / 2 - platformWidth/2
        return minX + (maxX - minX) * pos
    }
}

// Subcomponents

struct PlatformView: View {
    let width: CGFloat
    
    var body: some View {
        ZStack {
            // Main block
            RoundedRectangle(cornerRadius: 6)
                .fill(LinearGradient(colors: [Color(hex: "8d6e63"), Color(hex: "6d4c41")], startPoint: .top, endPoint: .bottom))
                .frame(width: width, height: 25)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.black.opacity(0.3), lineWidth: 1)
                )
            // Visual details
            HStack {
                Circle().fill(Color.black.opacity(0.2)).frame(width: 4, height: 4)
                Spacer()
                Circle().fill(Color.black.opacity(0.2)).frame(width: 4, height: 4)
            }
            .padding(.horizontal, 8)
        }
        .shadow(color: Color.black.opacity(0.4), radius: 4, y: 4)
    }
}

struct TowerBackground: View {
    let width: CGFloat
    let height: CGFloat
    let scrollOffset: CGFloat
    
    var body: some View {
        GeometryReader { _ in
            let brickHeight: CGFloat = 30
            let brickWidth: CGFloat = 40
            let rows = Int(height / brickHeight) + 4 // Extra rows for scrolling buffer
            let cols = Int(width / brickWidth) + 1
            
            VStack(spacing: 0) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<cols, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.white.opacity(0.05))
                                .frame(width: brickWidth - 2, height: brickHeight - 2)
                                .padding(1)
                        }
                    }
                    .offset(x: row % 2 == 0 ? 0 : brickWidth / 2)
                }
            }
            .offset(y: (scrollOffset.truncatingRemainder(dividingBy: brickHeight)) - brickHeight) // Infinite loop effect
        }
        .background(AppColors.towerBase.opacity(0.3))
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        TowerClimbView(
            targetPosition: 0.8,
            currentPosition: 0.5,
            scrollOffset: 0,
            isJumping: false,
            playerYOffset: 0
        )
        .frame(height: 400)
    }
}
