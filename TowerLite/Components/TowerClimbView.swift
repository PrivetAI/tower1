import SwiftUI

struct TowerClimbView: View {
    let position: CGFloat // 0.0 to 1.0 (Platform position)
    let targetZoneStart: CGFloat // Unused in this visualization logic as player is fixed, but kept for interface consistency or future debug
    let targetZoneEnd: CGFloat // Unused in this visualization logic
    
    // Player is effectively fixed at the center horizontally
    // Platform moves left/right based on `position`
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            // Dimensions
            let platformWidth = width * GameSettings.targetZoneWidth
            let playerSize: CGFloat = 40
            
            ZStack {
                // Background Tower Wall (Stone Bricks)
                GeometryReader { bgGeo in
                    let brickHeight: CGFloat = 30
                    let brickWidth: CGFloat = 40
                    let rows = Int(bgGeo.size.height / brickHeight) + 1
                    let cols = Int(bgGeo.size.width / brickWidth) + 1
                    
                    VStack(spacing: 0) {
                        ForEach(0..<rows, id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<cols, id: \.self) { col in
                                    Rectangle()
                                        .fill(Color.white.opacity(0.05))
                                        .frame(width: brickWidth - 2, height: brickHeight - 2)
                                        .padding(1)
                                }
                            }
                            .offset(x: row % 2 == 0 ? 0 : brickWidth / 2) // Staggered bricks
                        }
                    }
                }
                .background(AppColors.towerBase.opacity(0.3))
                .cornerRadius(12)
                .frame(width: width * 0.8, height: height)
                
                // Moving Platform (A wooden beam or stone slab)
                let trackWidth = width * 0.8
                let minX = (width - trackWidth) / 2 + platformWidth/2
                let maxX = width - (width - trackWidth) / 2 - platformWidth/2
                let platformX = minX + (maxX - minX) * position
                
                ZStack {
                    // Main block
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(colors: [Color(hex: "8d6e63"), Color(hex: "6d4c41")], startPoint: .top, endPoint: .bottom)) // Wood-ish color
                        .frame(width: platformWidth, height: 25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.black.opacity(0.3), lineWidth: 1)
                        )
                    // Visual details (bolts/grain)
                    HStack {
                        Circle().fill(Color.black.opacity(0.2)).frame(width: 4, height: 4)
                        Spacer()
                        Circle().fill(Color.black.opacity(0.2)).frame(width: 4, height: 4)
                    }
                    .padding(.horizontal, 8)
                }
                .shadow(color: Color.black.opacity(0.4), radius: 4, y: 4)
                .position(x: platformX, y: height * 0.7)
                
                // Player Character (Climbing Figure)
                Image(systemName: "figure.climbing")
                    .resizable()
                    .scaledToFit()
                    .frame(width: playerSize, height: playerSize)
                    .foregroundColor(AppColors.gold)
                    .shadow(color: AppColors.gold.opacity(0.6), radius: 8)
                    .position(x: width / 2, y: height * 0.45)
                    // Make him look like he's hanging on the wall
                    .rotationEffect(.degrees(-10))
                
                // Rope/connection to top (Visual feedback for 'climbing')
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 2, height: height * 0.45)
                    .position(x: width / 2, y: height * 0.225) // Hangs from top to player
            }
        }
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        TowerClimbView(position: 0.5, targetZoneStart: 0.4, targetZoneEnd: 0.6)
            .frame(height: 300)
    }
}
