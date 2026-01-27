import SwiftUI

struct ResultView: View {
    @EnvironmentObject var gameState: GameState
    let result: GameResult
    let combo: Int
    let onContinue: () -> Void
    let onSaveProgress: () -> Void
    let onExit: () -> Void
    
    @State private var showContent = false
    @State private var iconScale: CGFloat = 0.5
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Result Icon
            Group {
                if result.isSuccess {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(AppColors.success)
                } else {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(AppColors.gold)
                }
            }
            .scaleEffect(iconScale)
            .accessibilityHidden(true)
            
            // Result Text
            VStack(spacing: 10) {
                if case .success(let score) = result {
                    Text("Great!")
                        .font(AppFonts.title(36))
                        .foregroundColor(.white)
                    
                    Text("+\(score) points")
                        .font(AppFonts.number(28))
                        .foregroundColor(AppColors.gold)
                    
                    // Show combo if > 1
                    if combo > 1 {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("\(combo) combo!")
                                .font(AppFonts.body(18))
                                .foregroundColor(.orange)
                        }
                        .padding(.top, 4)
                    }
                } else {
                    Text("Try Again!")
                        .font(AppFonts.title(36))
                        .foregroundColor(.white)
                    
                    Text("Keep practicing!")
                        .font(AppFonts.body(18))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .opacity(showContent ? 1 : 0)
            .accessibilityElement(children: .combine)
            
            // Stats
            HStack(spacing: 30) {
                VStack {
                    Text("\(gameState.currentFloor)")
                        .font(AppFonts.number(32))
                        .foregroundColor(.white)
                    Text("Floor")
                        .font(AppFonts.body(14))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                VStack {
                    Text("\(gameState.currentScore)")
                        .font(AppFonts.number(32))
                        .foregroundColor(AppColors.gold)
                    Text("Score")
                        .font(AppFonts.body(14))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                VStack {
                    Text("\(gameState.bestScore)")
                        .font(AppFonts.number(32))
                        .foregroundColor(.white)
                    Text("Best")
                        .font(AppFonts.body(14))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.cardBackground)
            )
            .opacity(showContent ? 1 : 0)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Floor \(gameState.currentFloor), Score \(gameState.currentScore), Best \(gameState.bestScore)")
            
            Spacer()
            
            // Buttons
            VStack(spacing: 16) {
                // Show that progress was saved
                if gameState.currentScore > 0 {
                    Text("Progress saved!")
                        .font(AppFonts.body(14))
                        .foregroundColor(AppColors.gold.opacity(0.8))
                        .padding(.bottom, 8)
                }
                
                Button(action: {
                    SoundManager.shared.playButton()
                    onContinue()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise.circle.fill")
                        Text("Try Again")
                    }
                    .font(AppFonts.title(20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.towerTop, AppColors.towerBase],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .accessibilityLabel("Try again")
                
                Button(action: {
                    SoundManager.shared.playButton()
                    onExit()
                }) {
                    Text("Exit to Menu")
                        .font(AppFonts.body(16))
                        .foregroundColor(.white.opacity(0.6))
                }
                .accessibilityLabel("Exit to menu")
            }
            .padding(.horizontal, 30)
            .opacity(showContent ? 1 : 0)
            
            Spacer()
                .frame(height: 30)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                iconScale = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
                showContent = true
            }
        }
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()
        
        ResultView(
            result: .success(score: 50),
            combo: 5,
            onContinue: {},
            onSaveProgress: {},
            onExit: {}
        )
    }
    .environmentObject(GameState())
}
