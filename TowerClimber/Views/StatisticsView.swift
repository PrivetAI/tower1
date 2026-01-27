import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var statisticsManager: StatisticsManager
    @EnvironmentObject var achievementManager: AchievementManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Main stats grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            StatBox(title: "Games Played", value: "\(statisticsManager.stats.totalGames)", icon: "gamecontroller.fill")
                            StatBox(title: "Total Score", value: "\(statisticsManager.stats.totalScore)", icon: "star.fill")
                            StatBox(title: "Highest Floor", value: "\(statisticsManager.stats.highestFloor)", icon: "building.2.fill")
                            StatBox(title: "Best Score", value: "\(statisticsManager.stats.highestScore)", icon: "trophy.fill")
                            StatBox(title: "Success Rate", value: String(format: "%.1f%%", statisticsManager.stats.successRate), icon: "target")
                            StatBox(title: "Longest Combo", value: "\(statisticsManager.stats.longestCombo)", icon: "flame.fill")
                        }
                        .padding(.horizontal)
                        
                        // Averages section
                        VStack(spacing: 12) {
                            Text("Averages")
                                .font(AppFonts.body(14))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack(spacing: 20) {
                                VStack {
                                    Text(String(format: "%.1f", statisticsManager.stats.averageFloor))
                                        .font(AppFonts.number(28))
                                        .foregroundColor(.white)
                                    Text("Avg Floor")
                                        .font(AppFonts.body(12))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .frame(maxWidth: .infinity)
                                
                                VStack {
                                    Text(String(format: "%.0f", statisticsManager.stats.averageScore))
                                        .font(AppFonts.number(28))
                                        .foregroundColor(.white)
                                    Text("Avg Score")
                                        .font(AppFonts.body(12))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .frame(maxWidth: .infinity)
                                
                                VStack {
                                    Text(statisticsManager.formattedPlayTime())
                                        .font(AppFonts.number(28))
                                        .foregroundColor(.white)
                                    Text("Play Time")
                                        .font(AppFonts.body(12))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppColors.cardBackground)
                            )
                        }
                        .padding(.horizontal)
                        
                        // Achievements preview
                        VStack(spacing: 12) {
                            HStack {
                                Text("Achievements")
                                    .font(AppFonts.body(14))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Spacer()
                                
                                Text("\(achievementManager.unlockedCount)/\(achievementManager.totalCount)")
                                    .font(AppFonts.body(14))
                                    .foregroundColor(AppColors.gold)
                            }
                            
                            // Progress bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.1))
                                    
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(AppColors.gold)
                                        .frame(width: geometry.size.width * CGFloat(achievementManager.unlockedCount) / CGFloat(achievementManager.totalCount))
                                }
                            }
                            .frame(height: 12)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.gold)
                }
            }
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.gold)
            
            Text(value)
                .font(AppFonts.number(24))
                .foregroundColor(.white)
            
            Text(title)
                .font(AppFonts.body(12))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

#Preview {
    StatisticsView()
        .environmentObject(StatisticsManager())
        .environmentObject(AchievementManager())
}
