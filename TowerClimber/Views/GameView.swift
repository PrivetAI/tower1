import SwiftUI

struct GameView: View {
    @EnvironmentObject var gameState: GameState
    
    @State private var tapScale: CGFloat = 1.0
    @State private var showPlusFloors = false
    @State private var plusFloorsOffset: CGFloat = 0
    @State private var towerBounce: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background with gradient
            LinearGradient(
                colors: [Color(hex: "0f0f1a"), Color(hex: "1a1a2e"), Color(hex: "16213e")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Stars background
            StarsBackground()
            
            VStack(spacing: 0) {
                // Header Stats
                HStack(spacing: 10) {
                    StatCard(title: "Floor", value: formatNumber(gameState.currentFloor), icon: "tower")
                    StatCard(title: "Coins", value: formatNumber(gameState.coins), icon: "coin")
                    StatCard(title: "Best", value: formatNumber(gameState.bestFloor), icon: "star")
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                
                // Stats row with multiplier
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        TapPowerIcon()
                            .frame(width: 14, height: 14)
                        Text("+\(gameState.floorsPerTap)/tap")
                            .font(AppFonts.body(13))
                            .foregroundColor(AppColors.gold)
                    }
                    
                    if gameState.floorsPerSecond > 0 {
                        HStack(spacing: 4) {
                            AutoClimbIcon()
                                .frame(width: 14, height: 14)
                            Text("+\(formatNumber(Int(gameState.floorsPerSecond)))/sec")
                                .font(AppFonts.body(13))
                                .foregroundColor(AppColors.success)
                        }
                    }
                    
                    if gameState.multiplier > 1.0 {
                        HStack(spacing: 4) {
                            MultiplierBadge()
                                .frame(width: 14, height: 14)
                            Text("x\(String(format: "%.1f", gameState.multiplier))")
                                .font(AppFonts.body(13))
                                .foregroundColor(Color(hex: "a855f7"))
                        }
                    }
                }
                .padding(.top, 6)
                
                Spacer()
                
                // Tower with visual growth
                EnhancedTowerView(floor: gameState.currentFloor, bounce: towerBounce)
                    .frame(height: 280)
                    .padding(.horizontal, 20)
                
                Spacer()
                
                // +Floors Floating Text + TAP Button
                ZStack {
                    if showPlusFloors {
                        Text("+\(gameState.floorsPerTap)")
                            .font(AppFonts.title(32))
                            .foregroundColor(AppColors.gold)
                            .shadow(color: AppColors.gold.opacity(0.5), radius: 8)
                            .offset(y: plusFloorsOffset - 70)
                            .opacity(showPlusFloors ? 1 : 0)
                    }
                    
                    // TAP Button with glow
                    Button(action: handleTap) {
                        ZStack {
                            // Outer glow
                            Circle()
                                .fill(Color(hex: "e94560").opacity(0.3))
                                .frame(width: 140, height: 140)
                                .blur(radius: 15)
                            
                            // Main button
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "ff6b6b"), Color(hex: "e94560"), Color(hex: "c73e54")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 110, height: 110)
                                .shadow(color: Color(hex: "e94560").opacity(0.6), radius: 12, x: 0, y: 6)
                            
                            // Inner highlight
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.4), Color.white.opacity(0.1)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 2
                                )
                                .frame(width: 110, height: 110)
                            
                            VStack(spacing: 2) {
                                Text("CLIMB")
                                    .font(AppFonts.title(20))
                                    .foregroundColor(.white)
                                Text("+\(gameState.floorsPerTap)")
                                    .font(AppFonts.body(13))
                                    .foregroundColor(.white.opacity(0.85))
                            }
                        }
                    }
                    .scaleEffect(tapScale)
                }
                .frame(height: 130)
                
                // Bottom padding for tab bar
                Spacer()
                    .frame(height: 85)
            }
        }
    }
    
    private func handleTap() {
        SoundManager.shared.playTap()
        gameState.tap()
        
        // Button animation
        withAnimation(.easeOut(duration: 0.06)) {
            tapScale = 0.92
        }
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5).delay(0.06)) {
            tapScale = 1.0
        }
        
        // Tower bounce
        withAnimation(.easeOut(duration: 0.1)) {
            towerBounce = -8
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.4).delay(0.1)) {
            towerBounce = 0
        }
        
        // +Floors floating animation
        plusFloorsOffset = 0
        showPlusFloors = true
        withAnimation(.easeOut(duration: 0.35)) {
            plusFloorsOffset = -40
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            showPlusFloors = false
        }
    }
    
    private func formatNumber(_ num: Int) -> String {
        if num >= 1000000 {
            return String(format: "%.1fM", Double(num) / 1000000)
        } else if num >= 1000 {
            return String(format: "%.1fK", Double(num) / 1000)
        }
        return "\(num)"
    }
}

// MARK: - Stars Background

struct StarsBackground: View {
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<30, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.3...0.7)))
                    .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: 0...geo.size.height * 0.5)
                    )
            }
        }
    }
}

// MARK: - Enhanced Tower View

struct EnhancedTowerView: View {
    let floor: Int
    let bounce: CGFloat
    
    @State private var glowPulse: CGFloat = 0.6
    
    // Calculate floor segments (each segment = 100 floors visually)
    private var segments: Int {
        min(max(1, floor / 50 + 1), 8)
    }
    
    private var towerHeight: CGFloat {
        CGFloat(60 + segments * 22)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Floor counter with style
            VStack(spacing: 2) {
                Text("FLOOR")
                    .font(AppFonts.body(11))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(2)
                
                Text(formatNumber(floor))
                    .font(AppFonts.number(32))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 12)
            
            Spacer()
            
            // Tower
            ZStack {
                // Base glow
                Ellipse()
                    .fill(Color(hex: "7952b3").opacity(0.3 * glowPulse))
                    .frame(width: 100, height: 30)
                    .blur(radius: 15)
                    .offset(y: towerHeight / 2 + 10)
                
                // Tower structure
                VStack(spacing: 0) {
                    // Antenna/Spire
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [Color(hex: "e94560"), Color(hex: "ff6b6b")],
                            startPoint: .bottom,
                            endPoint: .top
                        ))
                        .frame(width: 4, height: 20)
                    
                    // Roof
                    Triangle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "ff6b6b"), Color(hex: "e94560"), Color(hex: "c73e54")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 70, height: 28)
                    
                    // Tower body with floors
                    ZStack {
                        // Main body
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "9b59b6"), Color(hex: "7952b3"), Color(hex: "533483")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        // Left edge highlight
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Windows
                        VStack(spacing: 8) {
                            ForEach(0..<segments, id: \.self) { row in
                                HStack(spacing: 6) {
                                    ForEach(0..<2, id: \.self) { _ in
                                        AnimatedWindow()
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .frame(width: 60, height: towerHeight)
                    
                    // Base
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: "4a3483"))
                        .frame(width: 80, height: 12)
                }
                .offset(y: bounce)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowPulse = 1.0
            }
        }
    }
    
    private func formatNumber(_ num: Int) -> String {
        if num >= 1000000 {
            return String(format: "%.1fM", Double(num) / 1000000)
        } else if num >= 1000 {
            return String(format: "%.1fK", Double(num) / 1000)
        }
        return "\(num)"
    }
}

// MARK: - Animated Window

struct AnimatedWindow: View {
    @State private var brightness: Double = 0.5
    
    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(AppColors.gold.opacity(brightness))
            .frame(width: 10, height: 12)
            .onAppear {
                brightness = Double.random(in: 0.3...0.9)
                withAnimation(.easeInOut(duration: Double.random(in: 1.5...3)).repeatForever(autoreverses: true)) {
                    brightness = Double.random(in: 0.4...1.0)
                }
            }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 5) {
            iconView
                .frame(width: 22, height: 22)
            
            Text(value)
                .font(AppFonts.number(18))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(title)
                .font(AppFonts.body(10))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }
    
    @ViewBuilder
    var iconView: some View {
        switch icon {
        case "tower":
            TowerIcon()
        case "coin":
            CoinIcon()
        case "star":
            StarIcon()
        default:
            Circle().fill(AppColors.gold)
        }
    }
}

// MARK: - Custom Icons

struct TowerIcon: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "7952b3"))
                .frame(width: 10, height: 16)
            
            Triangle()
                .fill(Color(hex: "e94560"))
                .frame(width: 14, height: 7)
                .offset(y: -10)
        }
    }
}

struct CoinIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(AppColors.gold)
                .frame(width: 18, height: 18)
            
            Circle()
                .stroke(Color(hex: "c5a000"), lineWidth: 1.5)
                .frame(width: 18, height: 18)
            
            Text("$")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color(hex: "8b7500"))
        }
    }
}

struct StarIcon: View {
    var body: some View {
        Star()
            .fill(AppColors.gold)
            .frame(width: 20, height: 20)
    }
}

// MARK: - Small Icons for Stats Row

struct TapPowerIcon: View {
    var body: some View {
        Circle()
            .fill(AppColors.gold)
            .overlay(
                Circle()
                    .stroke(Color(hex: "c5a000"), lineWidth: 1)
            )
    }
}

struct AutoClimbIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColors.success, lineWidth: 1.5)
            
            Triangle()
                .fill(AppColors.success)
                .frame(width: 6, height: 6)
                .rotationEffect(.degrees(0))
        }
    }
}

struct MultiplierBadge: View {
    var body: some View {
        Text("x")
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(Color(hex: "a855f7"))
    }
}

#Preview {
    GameView()
        .environmentObject(GameState())
        .environmentObject(SoundManager.shared)
}
