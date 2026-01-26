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
            ZStack {
                // Background Tower Wall (Infinite scrolling brick pattern)
                TowerBackground(width: width, height: height, scrollOffset: scrollOffset)
                
                // Pillars (Rails)
                HStack {
                    Rectangle()
                        .fill(LinearGradient(colors: [Color(hex: "2d3436"), Color(hex: "636e72")], startPoint: .leading, endPoint: .trailing))
                        .frame(width: 20)
                    Spacer()
                    Rectangle()
                        .fill(LinearGradient(colors: [Color(hex: "636e72"), Color(hex: "2d3436")], startPoint: .leading, endPoint: .trailing))
                        .frame(width: 20)
                }
                .frame(width: width * 0.9) // Pillars slightly outside the track width
                
                // --- MOVING ELEMENTS ---
                
                // 1. Current Platform (Bottom)
                PlatformView(width: platformWidth)
                    .position(
                        x: calculateX(for: currentPosition, width: width, platformWidth: platformWidth),
                        y: height * 0.8 + scrollOffset
                    )
                
                // 2. Target Platform (Top)
                PlatformView(width: platformWidth)
                    .position(
                        x: calculateX(for: targetPosition, width: width, platformWidth: platformWidth),
                        y: height * 0.4 + scrollOffset
                    )
                
                // 3. Player
                // Using custom asset "climber"
                Image("climber")
                    .resizable()
                    .scaledToFit()
                    .frame(width: playerSize * 1.8, height: playerSize * 1.8) // Larger size
                    .shadow(color: Color.black.opacity(0.4), radius: 8, y: 6)
                    // Position ON the platform (offset up by playerSize to stand on it)
                    .position(x: width / 2, y: height * 0.8 - playerSize * 0.9 + playerYOffset + scrollOffset)
                    
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
            let brickHeight: CGFloat = 25
            let brickWidth: CGFloat = 50
            let rows = Int(height / brickHeight) + 6 // Extra rows for scrolling buffer
            let cols = Int(width / brickWidth) + 2
            
            ZStack {
                // Base gradient
                LinearGradient(
                    colors: [Color(hex: "4a3728"), Color(hex: "3d2d22"), Color(hex: "2d1f18")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Brick pattern
                VStack(spacing: 2) {
                    ForEach(0..<rows, id: \.self) { row in
                        HStack(spacing: 2) {
                            ForEach(0..<cols, id: \.self) { col in
                                ZStack {
                                    // Brick base
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(hex: "8b7355").opacity(0.8),
                                                    Color(hex: "6b5344").opacity(0.6)
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .frame(width: brickWidth - 4, height: brickHeight - 4)
                                    
                                    // Random window on some bricks
                                    if (row + col) % 7 == 0 {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color(hex: "ffd700").opacity(0.3))
                                            .frame(width: 8, height: 10)
                                    }
                                }
                            }
                        }
                        .offset(x: row % 2 == 0 ? 0 : brickWidth / 2)
                    }
                }
                .offset(y: (scrollOffset.truncatingRemainder(dividingBy: brickHeight + 2)) - brickHeight * 2)
            }
        }
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
