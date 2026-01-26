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
    
    private var floorCount: Int {
        max(1, Int(height / 25))
    }
    
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
                
                // Tower body
                VStack(spacing: 2) {
                    // Roof
                    if height > 20 {
                        Triangle()
                            .fill(theme.roofColor)
                            .frame(width: 50, height: 20)
                    }
                    
                    // Tower blocks
                    ForEach(0..<floorCount, id: \.self) { index in
                        ThemedTowerBlock(theme: theme, isTop: index == floorCount - 1)
                    }
                }
                .frame(height: height)
                .clipped()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                showGlow = true
            }
        }
    }
}

struct ThemedTowerBlock: View {
    let theme: TowerTheme
    let isTop: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [theme.topColor, theme.baseColor],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Windows
            HStack(spacing: 8) {
                ThemedWindowView(color: theme.windowColor)
                ThemedWindowView(color: theme.windowColor)
            }
        }
        .frame(width: 60, height: 22)
    }
}

struct ThemedWindowView: View {
    let color: Color
    @State private var isLit = Bool.random()
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(isLit ? color.opacity(0.8) : Color.black.opacity(0.5))
            .frame(width: 10, height: 12)
            .onAppear {
                withAnimation(.easeInOut(duration: Double.random(in: 2...4)).repeatForever(autoreverses: true)) {
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
