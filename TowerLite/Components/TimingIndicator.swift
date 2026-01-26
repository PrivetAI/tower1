import SwiftUI

struct TimingIndicator: View {
    let position: CGFloat // 0.0 to 1.0
    let targetZoneStart: CGFloat
    let targetZoneEnd: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let indicatorWidth: CGFloat = 8
            
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.white.opacity(0.1))
                
                // Target zone
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.targetZone)
                    .frame(width: width * (targetZoneEnd - targetZoneStart))
                    .offset(x: width * targetZoneStart)
                
                // Target zone borders
                Rectangle()
                    .fill(AppColors.success)
                    .frame(width: 3)
                    .offset(x: width * targetZoneStart)
                
                Rectangle()
                    .fill(AppColors.success)
                    .frame(width: 3)
                    .offset(x: width * targetZoneEnd - 3)
                
                // Moving indicator
                RoundedRectangle(cornerRadius: indicatorWidth / 2)
                    .fill(AppColors.indicator)
                    .frame(width: indicatorWidth)
                    .shadow(color: AppColors.indicator.opacity(0.8), radius: 8)
                    .offset(x: (width - indicatorWidth) * position)
            }
        }
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()
        
        TimingIndicator(
            position: 0.5,
            targetZoneStart: 0.4,
            targetZoneEnd: 0.6
        )
        .frame(height: 60)
        .padding(.horizontal, 30)
    }
}
