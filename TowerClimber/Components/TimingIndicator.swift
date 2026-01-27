import SwiftUI

// MARK: - Platform Types

enum PlatformType: CaseIterable {
    case normal
    case breaking    // Crumbles after landing
    case moving      // Moves side to side
    case slippery    // Narrower hit zone
    
    var color: LinearGradient {
        switch self {
        case .normal:
            return LinearGradient(colors: [Color(hex: "8d6e63"), Color(hex: "6d4c41")], startPoint: .top, endPoint: .bottom)
        case .breaking:
            return LinearGradient(colors: [Color(hex: "ff4444"), Color(hex: "cc0000")], startPoint: .top, endPoint: .bottom)
        case .moving:
            return LinearGradient(colors: [Color(hex: "00bfff"), Color(hex: "0080ff")], startPoint: .top, endPoint: .bottom)
        case .slippery:
            return LinearGradient(colors: [Color(hex: "00ff88"), Color(hex: "00cc66")], startPoint: .top, endPoint: .bottom)
        }
    }
    
    var icon: String? {
        // No icons on platforms
        return nil
    }
    
    static func random(for floor: Int) -> PlatformType {
        // More variety as floors increase
        if floor < 5 { return .normal }
        
        let chance = Double.random(in: 0...1)
        if floor < 15 {
            return chance < 0.7 ? .normal : .breaking
        } else if floor < 30 {
            if chance < 0.5 { return .normal }
            else if chance < 0.75 { return .breaking }
            else { return .moving }
        } else {
            if chance < 0.4 { return .normal }
            else if chance < 0.6 { return .breaking }
            else if chance < 0.8 { return .moving }
            else { return .slippery }
        }
    }
}

struct TowerClimbView: View {
    // Current state inputs
    let targetPosition: CGFloat // 0.0 to 1.0 (The moving platform ABOVE)
    let currentPosition: CGFloat // 0.0 to 1.0 (The static platform BELOW)
    let scrollOffset: CGFloat // Vertical scroll of the world (0 = resting, positive = scrolling down)
    let isJumping: Bool // Is the player currently mid-air?
    let playerYOffset: CGFloat // Vertical animation offset for the player jump
    var targetPlatformType: PlatformType = .normal
    var currentPlatformType: PlatformType = .normal
    var breakingProgress: CGFloat = 0.0 // 0.0 = no cracks, 1.0 = fully cracked
    var movingPlatformOffset: CGFloat = 0.0 // Side-to-side movement for moving platform
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            // Dimensions
            let platformWidth = width * GameSettings.targetZoneWidth
            let playerSize: CGFloat = 50
            ZStack {
                // Background Tower Wall (Infinite scrolling brick pattern)
                TowerBackground(width: width, height: height, scrollOffset: scrollOffset)
                
                // Pillars (Rails)
                HStack {
                    Rectangle()
                        .fill(LinearGradient(colors: [Color(hex: "2d3436"), Color(hex: "636e72")], startPoint: .leading, endPoint: .trailing))
                        .frame(width: 16)
                    Spacer()
                    Rectangle()
                        .fill(LinearGradient(colors: [Color(hex: "636e72"), Color(hex: "2d3436")], startPoint: .leading, endPoint: .trailing))
                        .frame(width: 16)
                }
                .frame(width: width * 0.95)
                
                // --- MOVING ELEMENTS ---
                
                // 1. Current Platform (Bottom)
                PlatformView(width: platformWidth, type: currentPlatformType, breakingProgress: breakingProgress)
                    .position(
                        x: calculateX(for: currentPosition, width: width, platformWidth: platformWidth),
                        y: height * 0.75 + scrollOffset
                    )
                
                // 2. Target Platform (Top) - with moving offset for moving/slippery types
                PlatformView(width: platformWidth, type: targetPlatformType)
                    .position(
                        x: calculateX(for: targetPosition, width: width, platformWidth: platformWidth) + ((targetPlatformType == .moving || targetPlatformType == .slippery) ? movingPlatformOffset : 0),
                        y: height * 0.35 + scrollOffset
                    )
                
                // 3. Player
                Image("climber")
                    .resizable()
                    .scaledToFit()
                    .frame(width: playerSize * 1.3, height: playerSize * 1.3) // Smaller size (was 1.6)
                    .shadow(color: Color.black.opacity(0.4), radius: 6, y: 4)
                    // Position ON the platform (offset up by 0.9 * playerSize)
                    .position(x: width / 2, y: height * 0.75 - playerSize * 0.9 + playerYOffset + scrollOffset)
                    
            }
            .clipped()
        }
    }
    
    private func calculateX(for pos: CGFloat, width: CGFloat, platformWidth: CGFloat) -> CGFloat {
        let trackWidth = width * 0.85
        let minX = (width - trackWidth) / 2 + platformWidth/2
        let maxX = width - (width - trackWidth) / 2 - platformWidth/2
        return minX + (maxX - minX) * pos
    }
}

// Subcomponents

struct PlatformView: View {
    let width: CGFloat
    var type: PlatformType = .normal
    var breakingProgress: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            // Glow effect for special platforms
            if type == .moving {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.cyan.opacity(0.5))
                    .frame(width: width + 12, height: 38)
                    .blur(radius: 10)
            }
            if type == .slippery {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.green.opacity(0.5))
                    .frame(width: width + 12, height: 38)
                    .blur(radius: 10)
            }
            
            // Main block
            RoundedRectangle(cornerRadius: 8)
                .fill(type.color)
                .frame(width: width, height: 28)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(type == .moving ? Color.cyan : (type == .slippery ? Color.green : (type == .breaking ? Color.yellow : Color.black.opacity(0.4))), lineWidth: type == .normal ? 2 : 3)
                )
            
            // Breaking countdown bar
            if type == .breaking && breakingProgress > 0 {
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.yellow)
                        .frame(width: (width - 8) * (1 - breakingProgress), height: 4)
                }
                .frame(width: width - 8, height: 28)
                
                CrackOverlay(progress: breakingProgress)
                    .frame(width: width, height: 28)
            }
            
            // Pulsing warning for breaking platform
            if type == .breaking && breakingProgress > 0.7 {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.yellow, lineWidth: 3)
                    .frame(width: width, height: 28)
                    .opacity(breakingProgress > 0.9 ? 1 : 0.6)
            }
        }
        .shadow(color: Color.black.opacity(0.5), radius: 5, y: 5)
    }
}

// Crack overlay for breaking platforms
struct CrackOverlay: View {
    let progress: CGFloat
    
    var body: some View {
        Canvas { context, size in
            let crackPath = Path { path in
                // Crack pattern becomes more visible as progress increases
                if progress > 0.2 {
                    // First crack - diagonal from top-left
                    path.move(to: CGPoint(x: size.width * 0.2, y: 0))
                    path.addLine(to: CGPoint(x: size.width * 0.4, y: size.height))
                }
                
                if progress > 0.4 {
                    // Second crack - vertical in middle
                    path.move(to: CGPoint(x: size.width * 0.5, y: 0))
                    path.addLine(to: CGPoint(x: size.width * 0.45, y: size.height))
                }
                
                if progress > 0.6 {
                    // Third crack - diagonal from top-right
                    path.move(to: CGPoint(x: size.width * 0.7, y: 0))
                    path.addLine(to: CGPoint(x: size.width * 0.6, y: size.height))
                }
                
                if progress > 0.8 {
                    // Additional small cracks
                    path.move(to: CGPoint(x: size.width * 0.3, y: size.height * 0.3))
                    path.addLine(to: CGPoint(x: size.width * 0.35, y: size.height * 0.7))
                    
                    path.move(to: CGPoint(x: size.width * 0.65, y: size.height * 0.4))
                    path.addLine(to: CGPoint(x: size.width * 0.7, y: size.height * 0.8))
                }
            }
            
            context.stroke(
                crackPath,
                with: .color(.black.opacity(Double(progress))),
                lineWidth: 2
            )
        }
    }
}

// MARK: - Tower Background

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
