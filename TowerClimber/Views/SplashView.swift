import SwiftUI

struct SplashView: View {
    @Binding var showSplash: Bool
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var towerFloor: Int = 0
    @State private var showStartButton = false
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo
                VStack(spacing: 8) {
                    // Custom tower icon instead of emoji
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "7952b3"), Color(hex: "533483")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 50, height: 70)
                        
                        Triangle()
                            .fill(Color(hex: "e94560"))
                            .frame(width: 60, height: 25)
                            .offset(y: -47)
                        
                        // Windows
                        VStack(spacing: 8) {
                            HStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(AppColors.gold)
                                    .frame(width: 10, height: 12)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(AppColors.gold.opacity(0.7))
                                    .frame(width: 10, height: 12)
                            }
                            HStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(AppColors.gold.opacity(0.7))
                                    .frame(width: 10, height: 12)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(AppColors.gold)
                                    .frame(width: 10, height: 12)
                            }
                        }
                    }
                    .frame(width: 80, height: 100)
                    
                    Text("Tower Climber")
                        .font(AppFonts.title(42))
                        .foregroundColor(.white)
                    
                    Text("Tap to Climb")
                        .font(AppFonts.body(18))
                        .foregroundColor(AppColors.gold)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                // Animated Tower
                TowerAnimation(floor: towerFloor)
                    .frame(height: 150)
                
                Spacer()
                
                // Start Button
                if showStartButton {
                    Button(action: {
                        withAnimation(.spring()) {
                            showSplash = false
                        }
                    }) {
                        Text("Start")
                            .font(AppFonts.title(24))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(AppColors.accent)
                                    .shadow(color: AppColors.accent.opacity(0.5), radius: 10, y: 5)
                            )
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer()
                    .frame(height: 50)
            }
        }
        .onAppear {
            animateSplash()
        }
    }
    
    private func animateSplash() {
        // Logo animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Tower building animation
        withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
            towerFloor = 50
        }
        
        // Show start button
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring()) {
                showStartButton = true
            }
        }
    }
}


#Preview {
    SplashView(showSplash: .constant(true))
}
