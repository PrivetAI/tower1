import SwiftUI

// MARK: - Upgrade Icons

struct UpgradeIconView: View {
    let iconType: UpgradeIconType
    let size: CGFloat
    
    var body: some View {
        Group {
            switch iconType {
            // Tap Power Icons
            case .paw:
                PawIcon()
            case .boots:
                BootsIcon()
            case .claws:
                ClawsIcon()
            case .rocket:
                RocketIcon()
            case .wings:
                WingsIcon()
                
            // Auto Tap Icons
            case .bird:
                BirdIcon()
            case .wind:
                WindIcon()
            case .elevator:
                ElevatorIcon()
            case .jet:
                JetIcon()
            case .drone:
                DroneIcon()
                
            // Multiplier Icons
            case .clover:
                CloverIcon()
            case .gem:
                GemIcon()
            case .crown:
                CrownIcon()
            case .diamond:
                DiamondIcon()
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Tap Power Icons

struct PawIcon: View {
    var body: some View {
        ZStack {
            // Main pad
            Ellipse()
                .fill(Color(hex: "e94560"))
                .frame(width: 14, height: 12)
                .offset(y: 4)
            
            // Toes
            HStack(spacing: 3) {
                Circle().fill(Color(hex: "e94560")).frame(width: 6, height: 6)
                Circle().fill(Color(hex: "e94560")).frame(width: 7, height: 7).offset(y: -2)
                Circle().fill(Color(hex: "e94560")).frame(width: 6, height: 6)
            }
            .offset(y: -5)
        }
    }
}

struct BootsIcon: View {
    var body: some View {
        ZStack {
            // Boot shape
            Path { path in
                path.move(to: CGPoint(x: 6, y: 2))
                path.addLine(to: CGPoint(x: 6, y: 16))
                path.addLine(to: CGPoint(x: 18, y: 16))
                path.addLine(to: CGPoint(x: 18, y: 12))
                path.addLine(to: CGPoint(x: 10, y: 12))
                path.addLine(to: CGPoint(x: 10, y: 2))
                path.closeSubpath()
            }
            .fill(Color(hex: "e94560"))
        }
    }
}

struct ClawsIcon: View {
    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "e94560"))
                    .frame(width: 4, height: 16)
                    .offset(x: CGFloat(i - 1) * 6, y: -2)
                    .rotationEffect(.degrees(Double(i - 1) * 8))
            }
        }
    }
}

struct RocketIcon: View {
    var body: some View {
        ZStack {
            // Body
            Capsule()
                .fill(Color(hex: "e94560"))
                .frame(width: 10, height: 18)
            
            // Tip
            Triangle()
                .fill(Color(hex: "ff6b6b"))
                .frame(width: 10, height: 6)
                .offset(y: -10)
            
            // Fins
            Triangle()
                .fill(Color(hex: "c73e54"))
                .frame(width: 6, height: 6)
                .offset(x: -6, y: 6)
            
            Triangle()
                .fill(Color(hex: "c73e54"))
                .frame(width: 6, height: 6)
                .offset(x: 6, y: 6)
        }
    }
}

struct WingsIcon: View {
    var body: some View {
        ZStack {
            // Left wing
            Ellipse()
                .fill(Color(hex: "e94560"))
                .frame(width: 12, height: 16)
                .rotationEffect(.degrees(-20))
                .offset(x: -5)
            
            // Right wing
            Ellipse()
                .fill(Color(hex: "e94560"))
                .frame(width: 12, height: 16)
                .rotationEffect(.degrees(20))
                .offset(x: 5)
        }
    }
}

// MARK: - Auto Tap Icons

struct BirdIcon: View {
    var body: some View {
        ZStack {
            // Body
            Ellipse()
                .fill(Color(hex: "4ade80"))
                .frame(width: 14, height: 10)
            
            // Head
            Circle()
                .fill(Color(hex: "4ade80"))
                .frame(width: 8, height: 8)
                .offset(x: 5, y: -4)
            
            // Beak
            Triangle()
                .fill(Color(hex: "fbbf24"))
                .frame(width: 5, height: 4)
                .rotationEffect(.degrees(90))
                .offset(x: 10, y: -4)
            
            // Wing
            Ellipse()
                .fill(Color(hex: "22c55e"))
                .frame(width: 8, height: 6)
                .offset(x: -2, y: -2)
        }
    }
}

struct WindIcon: View {
    var body: some View {
        VStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(Color(hex: "4ade80"))
                    .frame(width: CGFloat(16 - i * 3), height: 3)
                    .offset(x: CGFloat(i * 2))
            }
        }
    }
}

struct ElevatorIcon: View {
    var body: some View {
        ZStack {
            // Shaft
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "22c55e"))
                .frame(width: 14, height: 20)
            
            // Doors
            Rectangle()
                .fill(Color(hex: "4ade80"))
                .frame(width: 5, height: 14)
                .offset(x: -2)
            
            Rectangle()
                .fill(Color(hex: "4ade80"))
                .frame(width: 5, height: 14)
                .offset(x: 2)
            
            // Gap
            Rectangle()
                .fill(Color(hex: "166534"))
                .frame(width: 1, height: 14)
        }
    }
}

struct JetIcon: View {
    var body: some View {
        ZStack {
            // Flame
            Ellipse()
                .fill(Color(hex: "fbbf24"))
                .frame(width: 8, height: 12)
                .offset(y: 8)
            
            // Body
            Capsule()
                .fill(Color(hex: "4ade80"))
                .frame(width: 12, height: 16)
            
            // Tip
            Triangle()
                .fill(Color(hex: "22c55e"))
                .frame(width: 12, height: 6)
                .offset(y: -9)
        }
    }
}

struct DroneIcon: View {
    var body: some View {
        ZStack {
            // Body
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: "4ade80"))
                .frame(width: 10, height: 8)
            
            // Arms
            Rectangle()
                .fill(Color(hex: "22c55e"))
                .frame(width: 20, height: 2)
            
            // Rotors
            ForEach([-8, 8], id: \.self) { x in
                Circle()
                    .stroke(Color(hex: "4ade80"), lineWidth: 2)
                    .frame(width: 8, height: 8)
                    .offset(x: CGFloat(x), y: 0)
            }
        }
    }
}

// MARK: - Multiplier Icons

struct CloverIcon: View {
    var body: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { i in
                Circle()
                    .fill(Color(hex: "a855f7"))
                    .frame(width: 8, height: 8)
                    .offset(y: -5)
                    .rotationEffect(.degrees(Double(i) * 90))
            }
            
            // Stem
            Rectangle()
                .fill(Color(hex: "7c3aed"))
                .frame(width: 2, height: 8)
                .offset(y: 6)
        }
    }
}

struct GemIcon: View {
    var body: some View {
        ZStack {
            // Top
            Triangle()
                .fill(Color(hex: "c084fc"))
                .frame(width: 16, height: 8)
            
            // Bottom
            Triangle()
                .fill(Color(hex: "a855f7"))
                .frame(width: 16, height: 12)
                .rotationEffect(.degrees(180))
                .offset(y: 10)
        }
    }
}

struct CrownIcon: View {
    var body: some View {
        ZStack {
            // Base
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "a855f7"))
                .frame(width: 18, height: 8)
                .offset(y: 4)
            
            // Points
            HStack(spacing: 2) {
                Triangle().fill(Color(hex: "c084fc")).frame(width: 6, height: 10)
                Triangle().fill(Color(hex: "a855f7")).frame(width: 6, height: 12)
                Triangle().fill(Color(hex: "c084fc")).frame(width: 6, height: 10)
            }
            .offset(y: -6)
        }
    }
}

struct DiamondIcon: View {
    var body: some View {
        ZStack {
            // Diamond shape
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "c084fc"), Color(hex: "a855f7"), Color(hex: "7c3aed")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 14, height: 14)
                .rotationEffect(.degrees(45))
            
            // Shine
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 3, height: 8)
                .rotationEffect(.degrees(45))
                .offset(x: -3, y: -3)
        }
    }
}
