import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                if gameState.history.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.3))
                        
                        Text("No history yet")
                            .font(AppFonts.body(18))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("Complete a climb to see your history")
                            .font(AppFonts.body(14))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("No history yet. Complete a climb to see your history.")
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(gameState.history) { session in
                                HistoryRow(session: session)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("History")
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

struct HistoryRow: View {
    let session: GameSession
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(dateFormatter.string(from: session.date))
                    .font(AppFonts.body(14))
                    .foregroundColor(.white.opacity(0.7))
                
                HStack(spacing: 16) {
                    Label("Floor \(session.floorReached)", systemImage: "building.2")
                        .font(AppFonts.body(16))
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            Text("+\(session.scoreEarned)")
                .font(AppFonts.number(24))
                .foregroundColor(AppColors.gold)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(dateFormatter.string(from: session.date)). Floor \(session.floorReached). Score \(session.scoreEarned)")
    }
}

#Preview {
    HistoryView()
        .environmentObject(GameState())
}
