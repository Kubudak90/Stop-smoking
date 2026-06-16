import Foundation
import SwiftUI

/// Uygulama genelinde paylaşılan servisleri tek noktada toplar ve görünümlere enjekte eder.
@MainActor
final class AppEnvironment: ObservableObject {
    let store = StoreManager()
    let notifications = NotificationManager()
    let prices = PriceCatalog()

    /// Paywall'un ilk Craving SOS kullanımında tetiklenmesi için. Spec §11.
    @Published var hasUsedCravingSOS = false {
        didSet { UserDefaults.standard.set(hasUsedCravingSOS, forKey: Keys.usedSOS) }
    }

    /// Onboarding sonrası paywall'u tek sefer göstermek için. Spec §11 (değer-sonra-paywall).
    @Published var hasSeenPostOnboardingPaywall = false {
        didSet { UserDefaults.standard.set(hasSeenPostOnboardingPaywall, forKey: Keys.seenPaywall) }
    }

    private enum Keys {
        static let usedSOS = "nefes.hasUsedCravingSOS"
        static let seenPaywall = "nefes.hasSeenPostOnboardingPaywall"
    }

    init() {
        hasUsedCravingSOS = UserDefaults.standard.bool(forKey: Keys.usedSOS)
        hasSeenPostOnboardingPaywall = UserDefaults.standard.bool(forKey: Keys.seenPaywall)
    }

    /// Açılışta tüm servisleri hazırlar.
    func bootstrap() async {
        await prices.refresh()
        await store.bootstrap()
        await notifications.refreshStatus()
    }
}
