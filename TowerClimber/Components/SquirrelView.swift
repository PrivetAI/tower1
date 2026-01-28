import SwiftUI

struct SquirrelView: View {
    @State private var tailWag: Double = 0
    
    var body: some View {
        ZStack {
            // Body
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "d4a574"), Color(hex: "8b5a2b")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 30, height: 35)
            
            // Belly
            Ellipse()
                .fill(Color(hex: "f5deb3"))
                .frame(width: 18, height: 22)
                .offset(y: 3)
            
            // Head
            Circle()
                .fill(Color(hex: "d4a574"))
                .frame(width: 22, height: 22)
                .offset(y: -20)
            
            // Ears
            Ellipse()
                .fill(Color(hex: "d4a574"))
                .frame(width: 8, height: 12)
                .offset(x: -8, y: -30)
            
            Ellipse()
                .fill(Color(hex: "d4a574"))
                .frame(width: 8, height: 12)
                .offset(x: 8, y: -30)
            
            // Eyes
            Circle()
                .fill(Color.black)
                .frame(width: 5, height: 5)
                .offset(x: -5, y: -22)
            
            Circle()
                .fill(Color.black)
                .frame(width: 5, height: 5)
                .offset(x: 5, y: -22)
            
            // Eye shine
            Circle()
                .fill(Color.white)
                .frame(width: 2, height: 2)
                .offset(x: -4, y: -23)
            
            Circle()
                .fill(Color.white)
                .frame(width: 2, height: 2)
                .offset(x: 6, y: -23)
            
            // Nose
            Ellipse()
                .fill(Color(hex: "4a3728"))
                .frame(width: 4, height: 3)
                .offset(y: -17)
            
            // Tail
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "d4a574"), Color(hex: "8b5a2b")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 20, height: 40)
                .rotationEffect(.degrees(-30 + tailWag))
                .offset(x: 18, y: -10)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                tailWag = 15
            }
        }
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        SquirrelView()
    }
}
