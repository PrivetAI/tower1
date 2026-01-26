import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var soundManager: SoundManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Sound settings
                    VStack(spacing: 0) {
                        SettingsToggle(
                            title: "Sound Effects",
                            icon: "speaker.wave.2.fill",
                            isOn: $soundManager.isSoundEnabled
                        )
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        SettingsToggle(
                            title: "Haptic Feedback",
                            icon: "hand.tap.fill",
                            isOn: $soundManager.isHapticEnabled
                        )
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.cardBackground)
                    )
                    
                    // About section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About")
                            .font(AppFonts.body(14))
                            .foregroundColor(.white.opacity(0.7))
                        
                        VStack(spacing: 0) {
                            SettingsRow(title: "Version", value: "1.0")
                            Divider().background(Color.white.opacity(0.1))
                            SettingsRow(title: "Developer", value: "Tower Lite Team")
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppColors.cardBackground)
                        )
                    }
                    
                    Spacer()
                    
                    // App info
                    VStack(spacing: 8) {
                        Text("🏰")
                            .font(.system(size: 40))
                        Text("Tower Lite")
                            .font(AppFonts.body(16))
                            .foregroundColor(.white.opacity(0.7))
                        Text("A skill-based timing game")
                            .font(AppFonts.body(12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.bottom, 30)
                }
                .padding()
            }
            .navigationTitle("Settings")
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

struct SettingsToggle: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.gold)
                .frame(width: 30)
            
            Text(title)
                .font(AppFonts.body(16))
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(AppColors.gold)
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(isOn ? "On" : "Off")")
    }
}

struct SettingsRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppFonts.body(16))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(AppFonts.body(16))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
    }
}

#Preview {
    SettingsView()
        .environmentObject(SoundManager.shared)
}
