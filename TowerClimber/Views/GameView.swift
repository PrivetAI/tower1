import SwiftUI

struct GameView: View {
    @EnvironmentObject var gameState: GameState
    
    @State private var tapScale: CGFloat = 1.0
    @State private var showPlusFloors = false
    @State private var plusFloorsOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Stats
                HStack(spacing: 12) {
                    StatCard(title: "Floor", value: formatNumber(gameState.currentFloor), icon: "tower")
                    StatCard(title: "Coins", value: formatNumber(gameState.coins), icon: "coin")
                    StatCard(title: "Best", value: formatNumber(gameState.bestFloor), icon: "star")
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                // Stats row
                HStack(spacing: 20) {
                    Text("+\(gameState.floorsPerTap)/tap")
                        .font(AppFonts.body(14))
                        .foregroundColor(AppColors.gold)
                    
                    if gameState.floorsPerSecond > 0 {
                        Text("+\(formatNumber(Int(gameState.floorsPerSecond)))/sec")
                            .font(AppFonts.body(14))
                            .foregroundColor(AppColors.success)
                    }
                }
                .padding(.top, 8)
                
                Spacer()
                
                // Tower - grows infinitely with scroll effect
                TowerView(floor: gameState.currentFloor)
                    .frame(height: 260)
                    .padding(.horizontal, 30)
                
                Spacer()
                
                // +Floors Floating Text + TAP Button
                ZStack {
                    if showPlusFloors {
                        Text("+\(gameState.floorsPerTap)")
                            .font(AppFonts.title(36))
                            .foregroundColor(AppColors.gold)
                            .offset(y: plusFloorsOffset - 80)
                            .opacity(showPlusFloors ? 1 : 0)
                    }
                    
                    // TAP Button
                    Button(action: handleTap) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "e94560"), Color(hex: "c73e54")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .shadow(color: Color(hex: "e94560").opacity(0.5), radius: 15, x: 0, y: 8)
                            
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 3)
                                .frame(width: 120, height: 120)
                            
                            VStack(spacing: 2) {
                                Text("CLIMB")
                                    .font(AppFonts.title(22))
                                    .foregroundColor(.white)
                                Text("+\(gameState.floorsPerTap)")
                                    .font(AppFonts.body(14))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    .scaleEffect(tapScale)
                }
                .frame(height: 140)
                
                // Bottom padding for tab bar
                Spacer()
                    .frame(height: 90)
            }
        }
    }
    
    private func handleTap() {
        SoundManager.shared.playTap()
        gameState.tap()
        
        // Button animation
        withAnimation(.easeOut(duration: 0.08)) {
            tapScale = 0.9
        }
        withAnimation(.spring(response: 0.25, dampingFraction: 0.5).delay(0.08)) {
            tapScale = 1.0
        }
        
        // +Floors floating animation
        plusFloorsOffset = 0
        showPlusFloors = true
        withAnimation(.easeOut(duration: 0.4)) {
            plusFloorsOffset = -50
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
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

// MARK: - Tower View (infinite growth with floor counter)

struct TowerView: View {
    let floor: Int
    
    @State private var glowOpacity: CGFloat = 0.4
    
    // Tower grows logarithmically - always visible growth
    private var displayHeight: CGFloat {
        let base: CGFloat = 60
        let growth = CGFloat(log10(Double(max(floor, 1)) + 1)) * 60
        return min(base + growth, 240)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Floor counter at top
            Text("Floor \(formatNumber(floor))")
                .font(AppFonts.title(18))
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            Spacer()
            
            // Tower building
            ZStack {
                // Glow
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "7952b3").opacity(0.2 * glowOpacity))
                    .frame(width: 90, height: displayHeight + 30)
                    .blur(radius: 10)
                
                VStack(spacing: 0) {
                    // Roof
                    Triangle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "e94560"), Color(hex: "c73e54")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 80, height: 30)
                    
                    // Tower body
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "7952b3"), Color(hex: "533483")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        // Windows grid
                        VStack(spacing: 12) {
                            ForEach(0..<windowRows, id: \.self) { _ in
                                HStack(spacing: 10) {
                                    WindowView()
                                    WindowView()
                                }
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    .frame(width: 70, height: displayHeight)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowOpacity = 1.0
            }
        }
    }
    
    private var windowRows: Int {
        max(1, min(Int(displayHeight / 30), 7))
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

// MARK: - Window View

struct WindowView: View {
    @State private var isLit = Bool.random()
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(AppColors.gold.opacity(isLit ? 0.9 : 0.3))
            .frame(width: 12, height: 14)
            .onAppear {
                // Random window lighting
                Timer.scheduledTimer(withTimeInterval: Double.random(in: 2...5), repeats: true) { _ in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isLit.toggle()
                    }
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
        VStack(spacing: 6) {
            iconView
                .frame(width: 24, height: 24)
            
            Text(value)
                .font(AppFonts.number(20))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(title)
                .font(AppFonts.body(11))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppColors.cardBackground)
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
                .frame(width: 12, height: 18)
            
            Triangle()
                .fill(Color(hex: "e94560"))
                .frame(width: 16, height: 8)
                .offset(y: -12)
        }
    }
}

struct CoinIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(AppColors.gold)
                .frame(width: 20, height: 20)
            
            Circle()
                .stroke(Color(hex: "c5a000"), lineWidth: 2)
                .frame(width: 20, height: 20)
            
            Text("$")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "8b7500"))
        }
    }
}

struct StarIcon: View {
    var body: some View {
        Star()
            .fill(AppColors.gold)
            .frame(width: 22, height: 22)
    }
}

struct Star: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        let points = 5
        
        var path = Path()
        
        for i in 0..<points * 2 {
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let angle = Double(i) * .pi / Double(points) - .pi / 2
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        path.closeSubpath()
        return path
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    GameView()
        .environmentObject(GameState())
        .environmentObject(SoundManager.shared)
}
