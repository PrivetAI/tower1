import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var soundManager: SoundManager
    
    @State private var showResetAlert = false
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                Text("Settings")
                    .font(AppFonts.title(28))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Statistics Section
                        SettingsSection(title: "Statistics") {
                            StatRow(label: "Total Taps", value: formatNumber(gameState.totalTaps))
                            StatRow(label: "Floors Climbed", value: formatNumber(gameState.totalFloorsClimbed))
                            StatRow(label: "Best Floor", value: formatNumber(gameState.bestFloor))
                            StatRow(label: "Play Time", value: formatTime(gameState.playTimeSeconds))
                            StatRow(label: "Floors/Tap", value: "+\(gameState.floorsPerTap)")
                            StatRow(label: "Floors/Sec", value: String(format: "+%.1f", gameState.floorsPerSecond))
                        }
                        
                        // Sound Section
                        SettingsSection(title: "Sound & Haptics") {
                            ToggleRow(label: "Sound Effects", isOn: $soundManager.isSoundEnabled)
                            ToggleRow(label: "Haptic Feedback", isOn: $soundManager.isHapticEnabled)
                        }
                        
                        // Reset Section
                        SettingsSection(title: "Data") {
                            Button(action: { showResetAlert = true }) {
                                HStack {
                                    Text("Reset All Progress")
                                        .font(AppFonts.body(16))
                                        .foregroundColor(AppColors.danger)
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        // About Section
                        SettingsSection(title: "About") {
                            StatRow(label: "Version", value: "1.0")
                        }
                    }
                    .padding(.horizontal, 16)
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
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(AppFonts.body(12))
                .foregroundColor(.white.opacity(0.5))
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            
            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.cardBackground)
            )
        }
    }
}

// MARK: - Stat Row

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppFonts.body(16))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(AppFonts.body(16))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Toggle Row

struct ToggleRow: View {
    let label: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppFonts.body(16))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AppColors.accent)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

#Preview {
    SettingsView()
        .environmentObject(GameState())
        .environmentObject(SoundManager.shared)
}
