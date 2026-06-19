#if DEBUG
import Foundation
import SwiftData

/// YALNIZCA DEBUG — App Store ekran görüntüleri için deterministik durum kurar.
/// Release derlemesine HİÇ girmez. `SIMCTL_CHILD_UITEST_*` ortam değişkenleriyle sürülür:
///   UITEST_SEED=1     → demo profil tohumla (onboarding'i atla)
///   UITEST_PREMIUM=1  → premium içeriği açık göster
///   UITEST_TAB=0..4   → açılışta hangi sekme
///   UITEST_SCREEN=sos|paywall → Bugün sekmesinde ilgili sheet'i otomatik aç
enum UITestConfig {
    private static let env = ProcessInfo.processInfo.environment

    static var isActive: Bool { env["UITEST_SEED"] == "1" }
    static var wantsPremium: Bool { env["UITEST_PREMIUM"] == "1" }
    static var initialTab: Int { Int(env["UITEST_TAB"] ?? "") ?? 0 }

    enum Screen { case none, sos, paywall }
    static var screen: Screen {
        switch env["UITEST_SCREEN"] {
        case "sos": return .sos
        case "paywall": return .paywall
        default: return .none
        }
    }

    /// Onboarding tamamlanmış zengin bir profil tohumlar (yalnızca profil yoksa).
    /// Container kurulurken senkron çağrılır; ilk render doğrudan ana arayüzü gösterir.
    static func seedIfNeeded(_ container: ModelContainer) {
        guard isActive else { return }
        let ctx = ModelContext(container)
        let existing = (try? ctx.fetch(FetchDescriptor<UserProfile>())) ?? []
        guard existing.isEmpty else { return }

        let quit = Calendar.current.date(byAdding: .day, value: -12, to: .now) ?? .now
        let profile = UserProfile(
            habitType: .smoking,
            reasons: ["Çocuklarım", "Sağlığım", "Para biriktirmek", "Daha rahat nefes"],
            unitsPerDay: 20,
            pricePerPack: 110,
            unitsPerPack: 20,
            brand: "Marlboro",
            quitDate: quit,
            createdAt: quit,
            kvkkConsentAt: quit
        )
        ctx.insert(profile)
        try? ctx.save()
    }
}
#endif
