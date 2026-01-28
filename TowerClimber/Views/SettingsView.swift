import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var soundManager: SoundManager
    
    @State private var showResetAlert = false
    
    var body: some View {
        GeometryReader { geo in
            let isIPad = geo.size.width > 500
            let scale: CGFloat = isIPad ? 1.2 : 1.0
            
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    Text("Settings")
                        .font(AppFonts.title(28 * scale))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, isIPad ? 40 : 20)
                        .padding(.top, isIPad ? 20 : 16)
                    
                    ScrollView {
                        VStack(spacing: 16 * scale) {
                            // Statistics Section
                            SettingsSection(title: "Statistics", scale: scale) {
                                StatRow(label: "Total Taps", value: formatNumber(gameState.totalTaps), scale: scale)
                                StatRow(label: "Floors Climbed", value: formatNumber(gameState.totalFloorsClimbed), scale: scale)
                                StatRow(label: "Best Floor", value: formatNumber(gameState.bestFloor), scale: scale)
                                StatRow(label: "Play Time", value: formatTime(gameState.playTimeSeconds), scale: scale)
                                StatRow(label: "Floors/Tap", value: "+\(gameState.floorsPerTap)", scale: scale)
                                StatRow(label: "Floors/Sec", value: String(format: "+%.1f", gameState.floorsPerSecond), scale: scale)
                            }
                            
                            // Sound Section
                            SettingsSection(title: "Sound & Haptics", scale: scale) {
                                ToggleRow(label: "Sound Effects", isOn: $soundManager.isSoundEnabled, scale: scale)
                                ToggleRow(label: "Haptic Feedback", isOn: $soundManager.isHapticEnabled, scale: scale)
                            }
                            
                            // Reset Section
                            SettingsSection(title: "Data", scale: scale) {
                                Button(action: { showResetAlert = true }) {
                                    HStack {
                                        Text("Reset All Progress")
                                            .font(AppFonts.body(16 * scale))
                                            .foregroundColor(AppColors.danger)
                                        Spacer()
                                    }
                                    .padding(.vertical, 12 * scale)
                                    .padding(.horizontal, 16 * scale)
                                }
                            }
                            
                            // About Section
                            SettingsSection(title: "About", scale: scale) {
                                StatRow(label: "Version", value: "1.0", scale: scale)
                            }
                        }
                        .padding(.horizontal, isIPad ? 40 : 16)
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
            .alert("Reset Progress?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    gameState.resetProgress()
                }
            } message: {
                Text("This will delete all your progress including floors, coins, upgrades and milestones. This cannot be undone.")
            }
        }
    }
    
    private func formatNumber(_ num: Int) -> String {
        if num >= 1000000 {
            return String(format: "%.1fM", Double(num) / 1000000)
        } else if num >= 1000 {
            return String(format: "%.1fK", Double(num) / 1000)
        }
        return "\(num)"
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Settings Section

struct SettingsSection<Content: View>: View {
    let title: String
    var scale: CGFloat = 1.0
    let content: Content
    
    init(title: String, scale: CGFloat = 1.0, @ViewBuilder content: () -> Content) {
        self.title = title
        self.scale = scale
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(AppFonts.body(12 * scale))
                .foregroundColor(.white.opacity(0.5))
                .padding(.horizontal, 16 * scale)
                .padding(.bottom, 8)
            
            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 16 * scale)
                    .fill(AppColors.cardBackground)
            )
        }
    }
}

// MARK: - Stat Row

struct StatRow: View {
    let label: String
    let value: String
    var scale: CGFloat = 1.0
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppFonts.body(16 * scale))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(AppFonts.body(16 * scale))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16 * scale)
        .padding(.vertical, 12 * scale)
    }
}

// MARK: - Toggle Row

struct ToggleRow: View {
    let label: String
    @Binding var isOn: Bool
    var scale: CGFloat = 1.0
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppFonts.body(16 * scale))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AppColors.accent)
        }
        .padding(.horizontal, 16 * scale)
        .padding(.vertical, 10 * scale)
    }
}

#Preview {
    SettingsView()
        .environmentObject(GameState())
        .environmentObject(SoundManager.shared)
}
