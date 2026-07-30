import SwiftUI

/// Brand tokens for Breach Kit. Prefer semantic system colors for surfaces;
/// the accent carries calm trust — privacy-first, not neon payout hype.
enum Theme {
    /// Deep pacific blue — primary interactive accent.
    static let accent = Color(red: 0.11, green: 0.42, blue: 0.78)
    /// Soft teal — secondary brand note for positive claim states.
    static let accentAlt = Color(red: 0.14, green: 0.62, blue: 0.58)
    static let claimed = Color(red: 0.18, green: 0.68, blue: 0.45)
    static let dueSoon = Color(red: 0.92, green: 0.55, blue: 0.18)
    static let expired = Color(red: 0.72, green: 0.32, blue: 0.32)

    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.28, blue: 0.58),
                Color(red: 0.12, green: 0.45, blue: 0.72)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var softSurface: Color {
        Color(.secondarySystemGroupedBackground)
    }
}
