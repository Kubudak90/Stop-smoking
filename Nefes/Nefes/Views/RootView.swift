import SwiftUI
import SwiftData

/// Onboarding tamamlanmış mı diye bakar; tamamlanmadıysa onboarding, tamamlandıysa
/// ana sekmeli arayüzü gösterir.
struct RootView: View {
    // En erken oluşturulan profili deterministik biçimde seç (birden fazla olsa bile
    // her açılışta aynısı gelsin — `profiles.first` sırasız ve belirsizdi).
    @Query(sort: \UserProfile.createdAt, order: .forward) private var profiles: [UserProfile]

    var body: some View {
        if let profile = profiles.first {
            MainTabView(profile: profile)
        } else {
            OnboardingView()
        }
    }
}

/// Ana sekmeler. Spec §10 ekranları.
struct MainTabView: View {
    let profile: UserProfile

    @EnvironmentObject private var store: StoreManager
    @EnvironmentObject private var notifications: NotificationManager
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            CounterView(profile: profile)
                .tabItem { Label("Bugün", systemImage: "leaf.fill") }

            JourneyView(profile: profile)
                .tabItem { Label("Program", systemImage: "map.fill") }

            RecoveryTimelineView(profile: profile)
                .tabItem { Label("İyileşme", systemImage: "heart.text.square.fill") }

            StatsView(profile: profile)
                .tabItem { Label("İstatistik", systemImage: "chart.bar.fill") }

            SettingsView(profile: profile)
                .tabItem { Label("Ayarlar", systemImage: "gearshape.fill") }
        }
        // Her foreground'da bildirimleri yeniden kur: izin sonradan açıldıysa plan dolar,
        // "geri dönüş kancası" 48 saat ileri ötelenir (Spec §12) ve rozet temizlenir.
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            notifications.clearBadge()
            Task {
                await notifications.refreshStatus()
                await notifications.reschedule(for: profile, isPremium: store.isPremium)
            }
        }
    }
}
