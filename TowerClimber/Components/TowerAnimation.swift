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
    
    @State private var showGlow = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            ZStack(alignment: .bottom) {
                // Tower glow effect
                if height > 0 {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [theme.topColor.opacity(0.5), theme.baseColor.opacity(0.3)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 80, height: height + 20)
                        .blur(radius: 20)
                        .opacity(showGlow ? 0.8 : 0.4)
                }
                
                // Tower body - SINGLE SOLID SHAPE (no separate blocks)
                VStack(spacing: 0) {
                    // Roof
                    if height > 20 {
                        Triangle()
                            .fill(theme.roofColor)
                            .frame(width: 50, height: 20)
                    }
                    
                    // Main tower body as ONE rectangle with brick pattern
                    ZStack {
                        // Base gradient
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [theme.topColor, theme.baseColor],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        // Brick pattern overlay
                        BrickPattern(theme: theme)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        // Windows column
                        VStack(spacing: 12) {
                            ForEach(0..<max(1, Int(height / 30)), id: \.self) { _ in
                                HStack(spacing: 8) {
                                    WindowGlow(color: theme.windowColor)
                                    WindowGlow(color: theme.windowColor)
                                }
                            }
                        }
                    }
                    .frame(width: 60, height: max(0, height - 20))
                }
            }
            .frame(height: height)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                showGlow = true
            }
        }
    }
}

// Simple brick pattern as overlay
struct BrickPattern: View {
    let theme: TowerTheme
    
    var body: some View {
        Canvas { context, size in
            let brickHeight: CGFloat = 12
            let brickWidth: CGFloat = 20
            let rows = Int(size.height / brickHeight) + 1
            
            for row in 0..<rows {
                let y = CGFloat(row) * brickHeight
                let offset: CGFloat = row % 2 == 0 ? 0 : brickWidth / 2
                let cols = Int(size.width / brickWidth) + 2
                
                for col in 0..<cols {
                    let x = CGFloat(col) * brickWidth + offset - brickWidth / 2
                    let rect = CGRect(x: x, y: y, width: brickWidth - 1, height: brickHeight - 1)
                    
                    // Draw brick outline
                    context.stroke(
                        Path(roundedRect: rect, cornerRadius: 1),
                        with: .color(.black.opacity(0.2)),
                        lineWidth: 0.5
                    )
                }
            }
        }
    }
}

// Window with glow
struct WindowGlow: View {
    let color: Color
    @State private var isLit = Bool.random()
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(isLit ? color.opacity(0.8) : Color.black.opacity(0.5))
            .frame(width: 10, height: 12)
            .onAppear {
                // Slower animation to reduce visual noise
                withAnimation(.easeInOut(duration: Double.random(in: 3...5)).repeatForever(autoreverses: true)) {
                    isLit.toggle()
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
