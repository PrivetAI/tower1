import SwiftUI

struct TowerAnimation: View {
    let height: CGFloat
    let maxHeight: CGFloat
    
    var body: some View {
        ThemedTowerAnimation(
            height: height,
            maxHeight: maxHeight,
            theme: TowerTheme.allThemes[0]
        )
    }
}

struct ThemedTowerAnimation: View {
    let height: CGFloat
    let maxHeight: CGFloat
    let theme: TowerTheme
    
    @State private var glowOpacity: CGFloat = 0.4
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Draw entire tower as single Canvas - no separate elements that can separate
            Canvas { context, size in
                let centerX = size.width / 2
                let towerWidth: CGFloat = 60
                let roofHeight: CGFloat = height > 20 ? 20 : 0
                let bodyHeight = max(0, height - roofHeight)
                let towerBottom = size.height
                let towerTop = towerBottom - height
                
                // Glow effect
                if height > 0 {
                    let glowRect = CGRect(
                        x: centerX - 40,
                        y: towerTop - 10,
                        width: 80,
                        height: height + 20
                    )
                    context.fill(
                        Path(roundedRect: glowRect, cornerRadius: 8),
                        with: .color(theme.topColor.opacity(0.3 * glowOpacity))
                    )
                }
                
                // Roof (triangle)
                if roofHeight > 0 {
                    var roofPath = Path()
                    roofPath.move(to: CGPoint(x: centerX, y: towerTop))
                    roofPath.addLine(to: CGPoint(x: centerX + 30, y: towerTop + roofHeight))
                    roofPath.addLine(to: CGPoint(x: centerX - 30, y: towerTop + roofHeight))
                    roofPath.closeSubpath()
                    context.fill(roofPath, with: .color(theme.roofColor))
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
                let gradient = Gradient(colors: [theme.topColor, theme.baseColor])
                context.fill(
                    Path(roundedRect: bodyRect, cornerRadius: 4),
                    with: .linearGradient(gradient, startPoint: CGPoint(x: 0, y: bodyTop), endPoint: CGPoint(x: 0, y: towerBottom))
                )
                
                // Brick pattern
                let brickHeight: CGFloat = 12
                let brickWidth: CGFloat = 20
                for row in 0..<Int(bodyHeight / brickHeight) + 1 {
                    let y = bodyTop + CGFloat(row) * brickHeight
                    let xOffset: CGFloat = row % 2 == 0 ? 0 : brickWidth / 2
                    
                    for col in 0..<4 {
                        let x = centerX - towerWidth/2 + CGFloat(col) * brickWidth + xOffset
                        if x < centerX + towerWidth/2 && y < towerBottom {
                            let brickRect = CGRect(x: x, y: y, width: brickWidth - 1, height: brickHeight - 1)
                            context.stroke(
                                Path(roundedRect: brickRect, cornerRadius: 1),
                                with: .color(.black.opacity(0.15)),
                                lineWidth: 0.5
                            )
                        }
                    }
                }
                
                // Windows (static, no animation)
                let windowWidth: CGFloat = 10
                let windowHeight: CGFloat = 12
                let windowSpacing: CGFloat = 25
                let windowsCount = max(1, Int(bodyHeight / windowSpacing))
                
                for i in 0..<windowsCount {
                    let windowY = bodyTop + 10 + CGFloat(i) * windowSpacing
                    if windowY + windowHeight < towerBottom - 5 {
                        // Left window
                        let leftWindowRect = CGRect(x: centerX - 12, y: windowY, width: windowWidth, height: windowHeight)
                        context.fill(
                            Path(roundedRect: leftWindowRect, cornerRadius: 2),
                            with: .color(theme.windowColor.opacity(0.7))
                        )
                        
                        // Right window
                        let rightWindowRect = CGRect(x: centerX + 2, y: windowY, width: windowWidth, height: windowHeight)
                        context.fill(
                            Path(roundedRect: rightWindowRect, cornerRadius: 2),
                            with: .color(theme.windowColor.opacity(0.5))
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
    ZStack {
        AppColors.background
            .ignoresSafeArea()
        
        VStack {
            ThemedTowerAnimation(height: 150, maxHeight: 200, theme: TowerTheme.allThemes[0])
                .frame(height: 200)
            
            ThemedTowerAnimation(height: 150, maxHeight: 200, theme: TowerTheme.allThemes[1])
                .frame(height: 200)
        }
    }
}
