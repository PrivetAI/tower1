import SwiftUI
import AVFoundation

// MARK: - Haptic Feedback Manager

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    func tap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func failure() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    func achievement() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Double haptic for achievements
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
        }
    }
    
    func countdown() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func buttonPress() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

// MARK: - Sound Manager

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    @Published var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: "soundEnabled")
        }
    }
    
    @Published var isHapticEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isHapticEnabled, forKey: "hapticEnabled")
        }
    }
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    private init() {
        self.isSoundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        self.isHapticEnabled = UserDefaults.standard.object(forKey: "hapticEnabled") as? Bool ?? true
        
        // Configure audio session
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func playTap() {
        guard isSoundEnabled else { return }
        playSystemSound(id: 1104) // Tock
        if isHapticEnabled { HapticManager.shared.tap() }
    }
    
    func playSuccess() {
        guard isSoundEnabled else { return }
        playSystemSound(id: 1025) // Success sound
        if isHapticEnabled { HapticManager.shared.success() }
    }
    
    func playMiss() {
        guard isSoundEnabled else { return }
        playSystemSound(id: 1053) // Error/miss sound
        if isHapticEnabled { HapticManager.shared.failure() }
    }
    
    func playCountdown() {
        guard isSoundEnabled else { return }
        playSystemSound(id: 1103) // Tick
        if isHapticEnabled { HapticManager.shared.countdown() }
    }
    
    func playAchievement() {
        guard isSoundEnabled else { return }
        playSystemSound(id: 1026) // Achievement fanfare
        if isHapticEnabled { HapticManager.shared.achievement() }
    }
    
    func playButton() {
        guard isSoundEnabled else { return }
        playSystemSound(id: 1104) // Tock
        if isHapticEnabled { HapticManager.shared.buttonPress() }
    }
    
    private func playSystemSound(id: SystemSoundID) {
        AudioServicesPlaySystemSound(id)
    }
}
