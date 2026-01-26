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
            return LinearGradient(colors: [Color(hex: "e74c3c"), Color(hex: "c0392b")], startPoint: .top, endPoint: .bottom)
        case .moving:
            return LinearGradient(colors: [Color(hex: "3498db"), Color(hex: "2980b9")], startPoint: .top, endPoint: .bottom)
        case .slippery:
            return LinearGradient(colors: [Color(hex: "1abc9c"), Color(hex: "16a085")], startPoint: .top, endPoint: .bottom)
        }
    }
    
    var icon: String? {
        switch self {
        case .normal: return nil
        case .breaking: return "⚠️"
        case .moving: return "↔️"
        case .slippery: return "💨"
        }
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
                PlatformView(width: platformWidth, type: .normal)
                    .position(
                        x: calculateX(for: currentPosition, width: width, platformWidth: platformWidth),
                        y: height * 0.75 + scrollOffset
                    )
                
                // 2. Target Platform (Top) - with type indicator
                PlatformView(width: platformWidth, type: targetPlatformType)
                    .position(
                        x: calculateX(for: targetPosition, width: width, platformWidth: platformWidth),
                        y: height * 0.35 + scrollOffset
                    )
                
                // 3. Player - Squirrel drawn with SwiftUI
                SquirrelView()
                    .frame(width: playerSize * 1.4, height: playerSize * 1.4)
                    .shadow(color: Color.black.opacity(0.4), radius: 6, y: 4)
                    .position(x: width / 2, y: height * 0.75 - playerSize * 0.7 + playerYOffset + scrollOffset)
                    
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
    
    var body: some View {
        ZStack {
            // Main block
            RoundedRectangle(cornerRadius: 8)
                .fill(type.color)
                .frame(width: width, height: 28)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black.opacity(0.4), lineWidth: 2)
                )
            
            // Type indicator
            if let icon = type.icon {
                Text(icon)
                    .font(.system(size: 14))
                    .offset(y: -18)
            }
            
            // Visual details
            HStack {
                Circle().fill(Color.black.opacity(0.2)).frame(width: 5, height: 5)
                Spacer()
                Circle().fill(Color.black.opacity(0.2)).frame(width: 5, height: 5)
            }
            .padding(.horizontal, 10)
        }
        .shadow(color: Color.black.opacity(0.5), radius: 5, y: 5)
    }
}

// MARK: - Squirrel Character

struct SquirrelView: View {
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            
            ZStack {
                // Tail
                Ellipse()
                    .fill(LinearGradient(colors: [Color(hex: "d35400"), Color(hex: "e67e22")], startPoint: .bottom, endPoint: .top))
                    .frame(width: size * 0.5, height: size * 0.7)
                    .rotationEffect(.degrees(-30))
                    .offset(x: size * 0.25, y: -size * 0.1)
                
                // Body
                Ellipse()
                    .fill(LinearGradient(colors: [Color(hex: "e67e22"), Color(hex: "f39c12")], startPoint: .bottom, endPoint: .top))
                    .frame(width: size * 0.55, height: size * 0.6)
                    .offset(y: size * 0.1)
                
                // Belly
                Ellipse()
                    .fill(Color(hex: "fdebd0"))
                    .frame(width: size * 0.35, height: size * 0.4)
                    .offset(y: size * 0.15)
                
                // Head
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: "e67e22"), Color(hex: "f39c12")], startPoint: .bottom, endPoint: .top))
                    .frame(width: size * 0.5, height: size * 0.5)
                    .offset(y: -size * 0.2)
                
                // Face
                Circle()
                    .fill(Color(hex: "fdebd0"))
                    .frame(width: size * 0.3, height: size * 0.25)
                    .offset(y: -size * 0.15)
                
                // Eyes
                HStack(spacing: size * 0.08) {
                    Circle().fill(Color.black).frame(width: size * 0.08)
                    Circle().fill(Color.black).frame(width: size * 0.08)
                }
                .offset(y: -size * 0.22)
                
                // Nose
                Circle()
                    .fill(Color(hex: "2d2d2d"))
                    .frame(width: size * 0.06)
                    .offset(y: -size * 0.12)
                
                // Ears
                HStack(spacing: size * 0.25) {
                    Circle()
                        .fill(Color(hex: "d35400"))
                        .frame(width: size * 0.15)
                    Circle()
                        .fill(Color(hex: "d35400"))
                        .frame(width: size * 0.15)
                }
                .offset(y: -size * 0.4)
                
                // Helmet
                Capsule()
                    .fill(LinearGradient(colors: [Color(hex: "e74c3c"), Color(hex: "c0392b")], startPoint: .top, endPoint: .bottom))
                    .frame(width: size * 0.45, height: size * 0.2)
                    .offset(y: -size * 0.35)
            }
        }
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
