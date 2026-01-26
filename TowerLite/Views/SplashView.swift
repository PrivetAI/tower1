import SwiftUI

struct SplashView: View {
    @Binding var showSplash: Bool
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var towerHeight: CGFloat = 0
    @State private var showStartButton = false
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo
                VStack(spacing: 8) {
                    Text("🏰")
                        .font(.system(size: 80))
                    
                    Text("Tower Lite")
                        .font(AppFonts.title(42))
                        .foregroundColor(.white)
                    
                    Text("Quick Climb")
                        .font(AppFonts.body(18))
                        .foregroundColor(AppColors.gold)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                // Animated Tower
                TowerAnimation(height: towerHeight, maxHeight: 150)
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
            towerHeight = 150
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
