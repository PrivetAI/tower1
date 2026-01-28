import SwiftUI

struct TowerAnimation: View {
    let floor: Int
    
    private var height: CGFloat {
        min(CGFloat(floor) * 3, 280)
    }
    
    @State private var glowOpacity: CGFloat = 0.4
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Canvas { context, size in
                let centerX = size.width / 2
                let towerWidth: CGFloat = 70
                let roofHeight: CGFloat = height > 20 ? 25 : 0
                let bodyHeight = max(0, height - roofHeight)
                let towerBottom = size.height
                let towerTop = towerBottom - height
                
                // Glow effect
                if height > 0 {
                    let glowRect = CGRect(
                        x: centerX - 50,
                        y: towerTop - 15,
                        width: 100,
                        height: height + 30
                    )
                    context.fill(
                        Path(roundedRect: glowRect, cornerRadius: 10),
                        with: .color(Color(hex: "7952b3").opacity(0.3 * glowOpacity))
                    )
                }
                
                // Roof (triangle)
                if roofHeight > 0 {
                    var roofPath = Path()
                    roofPath.move(to: CGPoint(x: centerX, y: towerTop))
                    roofPath.addLine(to: CGPoint(x: centerX + 35, y: towerTop + roofHeight))
                    roofPath.addLine(to: CGPoint(x: centerX - 35, y: towerTop + roofHeight))
                    roofPath.closeSubpath()
                    context.fill(roofPath, with: .color(Color(hex: "e94560")))
                }
                
                // Tower body
                let bodyTop = towerTop + roofHeight
                let bodyRect = CGRect(
                    x: centerX - towerWidth/2,
                    y: bodyTop,
                    width: towerWidth,
                    height: bodyHeight
                )
                
                // Base gradient
                let gradient = Gradient(colors: [Color(hex: "7952b3"), Color(hex: "533483")])
                context.fill(
                    Path(roundedRect: bodyRect, cornerRadius: 6),
                    with: .linearGradient(gradient, startPoint: CGPoint(x: 0, y: bodyTop), endPoint: CGPoint(x: 0, y: towerBottom))
                )
                
                // Brick pattern
                let brickHeight: CGFloat = 14
                let brickWidth: CGFloat = 22
                for row in 0..<Int(bodyHeight / brickHeight) + 1 {
                    let y = bodyTop + CGFloat(row) * brickHeight
                    let xOffset: CGFloat = row % 2 == 0 ? 0 : brickWidth / 2
                    
                    for col in 0..<4 {
                        let x = centerX - towerWidth/2 + CGFloat(col) * brickWidth + xOffset
                        if x < centerX + towerWidth/2 && y < towerBottom {
                            let brickRect = CGRect(x: x, y: y, width: brickWidth - 1, height: brickHeight - 1)
                            context.stroke(
                                Path(roundedRect: brickRect, cornerRadius: 1),
                                with: .color(.black.opacity(0.2)),
                                lineWidth: 0.5
                            )
                        }
                    }
                }
                
                // Windows
                let windowWidth: CGFloat = 12
                let windowHeight: CGFloat = 14
                let windowSpacing: CGFloat = 28
                let windowsCount = max(1, Int(bodyHeight / windowSpacing))
                
                for i in 0..<windowsCount {
                    let windowY = bodyTop + 12 + CGFloat(i) * windowSpacing
                    if windowY + windowHeight < towerBottom - 8 {
                        // Left window
                        let leftWindowRect = CGRect(x: centerX - 14, y: windowY, width: windowWidth, height: windowHeight)
                        context.fill(
                            Path(roundedRect: leftWindowRect, cornerRadius: 2),
                            with: .color(Color(hex: "ffd700").opacity(0.8))
                        )
                        
                        // Right window
                        let rightWindowRect = CGRect(x: centerX + 2, y: windowY, width: windowWidth, height: windowHeight)
                        context.fill(
                            Path(roundedRect: rightWindowRect, cornerRadius: 2),
                            with: .color(Color(hex: "ffd700").opacity(0.6))
                        )
                    }
                }
            }
            .frame(height: height)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowOpacity = 1.0
            }
        }
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()
        
        TowerAnimation(floor: 50)
            .frame(height: 300)
    }
}
