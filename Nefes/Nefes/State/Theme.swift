import SwiftUI

/// Nefes görsel kimliği — sakin, premium, "hekim tasarladı" güveni. Spec konumlandırma.
/// Reklam yok, klişe yok; nefes/temizlik çağrışımı (teal-yeşil + yumuşak nötrler).
enum Theme {
    // Marka renkleri
    static let primary = Color(hex: 0x16A394)      // nefes yeşili (teal)
    static let primaryDark = Color(hex: 0x0E7A6E)
    static let accent = Color(hex: 0xF4A259)       // sıcak vurgu (para/kutlama)
    static let danger = Color(hex: 0xE0654E)       // kriz/kayma (yumuşak, agresif değil)

    static let background = Color(hex: 0xF6F8F7)
    static let surface = Color.white
    static let textPrimary = Color(hex: 0x14201E)
    static let textSecondary = Color(hex: 0x5E6B68)

    static let gradient = LinearGradient(
        colors: [primary, primaryDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let calmGradient = LinearGradient(
        colors: [Color(hex: 0x16A394), Color(hex: 0x118AB2)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cardCornerRadius: CGFloat = 20
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

/// Tutarlı kart stili.
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
    }
}

extension View {
    func card() -> some View { modifier(CardModifier()) }
}
