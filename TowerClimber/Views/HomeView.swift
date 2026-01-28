import SwiftUI

struct HomeView: View {
    @EnvironmentObject var gameState: GameState
    
    @State private var tapScale: CGFloat = 1.0
    @State private var showPlusOne = false
    @State private var plusOneOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Stats
                HStack(spacing: 20) {
                    StatCard(title: "Floor", value: "\(gameState.currentFloor)")
                    StatCard(title: "Best", value: "\(gameState.bestFloor)")
                    StatCard(title: "Taps", value: formatNumber(gameState.totalTaps))
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Tower Visual
                TowerAnimation(floor: gameState.currentFloor)
                    .frame(height: 300)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // +1 Floating Text
                ZStack {
                    if showPlusOne {
                        Text("+1")
                            .font(AppFonts.title(32))
                            .foregroundColor(AppColors.gold)
                            .offset(y: plusOneOffset)
                            .opacity(showPlusOne ? 1 : 0)
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
                                .frame(width: 140, height: 140)
                                .shadow(color: Color(hex: "e94560").opacity(0.5), radius: 20, x: 0, y: 10)
                            
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 3)
                                .frame(width: 140, height: 140)
                            
                            VStack(spacing: 4) {
                                Text("TAP")
                                    .font(AppFonts.title(28))
                                    .foregroundColor(.white)
                                Text("to climb")
                                    .font(AppFonts.body(14))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    .scaleEffect(tapScale)
                }
                .frame(height: 180)
                
                Spacer()
                    .frame(height: 60)
            }
        }
    }
    
    private func handleTap() {
        SoundManager.shared.playTap()
        gameState.tap()
        
        // Button animation
        withAnimation(.easeOut(duration: 0.1)) {
            tapScale = 0.9
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.1)) {
            tapScale = 1.0
        }
        
        // +1 floating animation
        plusOneOffset = 0
        showPlusOne = true
        withAnimation(.easeOut(duration: 0.5)) {
            plusOneOffset = -60
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showPlusOne = false
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

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(AppFonts.number(24))
                .foregroundColor(.white)
            
            Text(title)
                .font(AppFonts.body(12))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(GameState())
        .environmentObject(SoundManager.shared)
}
