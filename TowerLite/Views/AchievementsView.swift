import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var achievementManager: AchievementManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Progress header
                        HStack {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.gold)
                            
                            Text("\(achievementManager.unlockedCount) / \(achievementManager.totalCount)")
                                .font(AppFonts.title(24))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppColors.cardBackground)
                        )
                        
                        // Achievement list
                        ForEach(achievementManager.achievements) { achievement in
                            AchievementRow(achievement: achievement)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.gold)
                }
            }
            .toolbarBackground(Color.clear, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? AppColors.gold.opacity(0.2) : Color.white.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 22))
                    .foregroundColor(achievement.isUnlocked ? AppColors.gold : .white.opacity(0.3))
            }
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(AppFonts.body(16))
                    .foregroundColor(achievement.isUnlocked ? .white : .white.opacity(0.5))
                
                Text(achievement.description)
                    .font(AppFonts.body(13))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            // Status
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.success)
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
                .opacity(achievement.isUnlocked ? 1 : 0.6)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(achievement.title). \(achievement.description). \(achievement.isUnlocked ? "Unlocked" : "Locked")")
    }
}

// MARK: - Achievement Popup

struct AchievementPopup: View {
    let achievement: Achievement
    let onDismiss: () -> Void
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: achievement.icon)
                .font(.system(size: 50))
                .foregroundColor(AppColors.gold)
            
            Text("Achievement Unlocked!")
                .font(AppFonts.body(14))
                .foregroundColor(.white.opacity(0.7))
            
            Text(achievement.title)
                .font(AppFonts.title(24))
                .foregroundColor(.white)
            
            Text(achievement.description)
                .font(AppFonts.body(14))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(AppColors.gold, lineWidth: 2)
                )
        )
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Auto dismiss after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0
                    scale = 0.8
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss()
                }
            }
        }
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.2)) {
                opacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                onDismiss()
            }
        }
    }
}

#Preview {
    AchievementsView()
        .environmentObject(AchievementManager())
}
