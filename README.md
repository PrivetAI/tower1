# Tower Lite — Quick Climb

Casual iOS game with one-tap timing challenges. Pure SwiftUI, iOS 15+.

## Features

- 🏰 **Tower Climbing** — Progress through floors with skill-based challenges
- ⏱️ **Timing Mini-game** — Tap when the indicator is in the target zone
- 📊 **Score Tracking** — Track your best scores and game history
- 🎨 **Animated UI** — Dark theme with smooth animations
- ♿ **Accessible** — VoiceOver support included

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## Getting Started

1. Open `TowerLite.xcodeproj` in Xcode
2. Select your development team in Signing & Capabilities
3. Build and run on simulator or device

## Project Structure

```
TowerLite/
├── TowerLiteApp.swift       # App entry point
├── Models/
│   └── GameState.swift      # Game state with UserDefaults persistence
├── Views/
│   ├── SplashView.swift     # Splash screen
│   ├── HomeView.swift       # Main menu
│   ├── GameView.swift       # Timing mini-game
│   ├── ResultView.swift     # Round results
│   └── HistoryView.swift    # Game history
├── Components/
│   ├── TimingIndicator.swift # Timing bar component
│   └── TowerAnimation.swift  # Animated tower
└── Utilities/
    └── Constants.swift       # Colors, fonts, settings
```

## Gameplay

1. Tap **Climb** to start a challenge
2. Wait for the countdown
3. Tap when the moving indicator is in the green zone
4. Success = earn score and advance to next floor
5. Miss = try again (no penalty!)
6. Save your progress anytime to record your score

## App Store Submission

### Required Before Submission

1. **App Icon** — Add 1024x1024 icon to `Assets.xcassets/AppIcon.appiconset/`
2. **Privacy Policy URL** — Add to App Store Connect (see below)
3. **Screenshots** — 6.7" and 5.5" iPhone screenshots

### Age Rating

- **4+** — No objectionable content
- No gambling, no simulated gambling
- No in-app purchases
- Pure skill-based gameplay

### Privacy Policy

This app does not collect, store, or share any personal data. All game progress is stored locally on the device using UserDefaults.

**Sample Privacy Policy text you can host:**

```
Privacy Policy for Tower Lite

Last updated: [DATE]

Tower Lite does not collect, transmit, or share any personal information.

Data Storage:
- Game progress (score, floor level, history) is stored locally on your device
- No data is sent to external servers
- No analytics or tracking is used

Contact:
[Your email]
```

### App Store Texts

**Title:** Tower Lite — Quick Climb  
**Subtitle:** Short skill challenges. No gambling.

**Description:**
```
Tower Lite is a simple casual game with short timing challenges and quick floor-by-floor progression. 

Features:
• Pure skill-based gameplay — time your taps perfectly
• Progressive difficulty — higher floors = faster challenges
• Track your best scores and climb history
• Beautiful dark theme with smooth animations
• No ads, no in-app purchases, no gambling

How to play:
1. Tap Climb to start
2. Watch the moving indicator
3. Tap when it's in the green zone
4. Climb higher, score more!

Perfect for quick gaming sessions. Challenge yourself to reach the highest floor!
```

**Keywords:** tower, climb, timing, skill, casual, game, tap, reaction, challenge, free

### Notes for App Review

```
This app is a casual skill-based game with single-tap timing challenges.

- There is NO gambling of any kind
- There is NO real-money wagering
- There is NO simulated gambling
- There are NO in-app purchases
- There is NO virtual currency that can be exchanged

The game uses a simple scoring system based purely on player skill (timing accuracy). Players can save their score at any time and start a new climb. Missing the target zone simply prompts "Try Again" with no penalty.

All game data is stored locally on the device using UserDefaults. No personal data is collected or transmitted.
```

## License

MIT
