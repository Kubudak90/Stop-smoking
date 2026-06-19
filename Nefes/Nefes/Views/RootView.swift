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

    @State private var selection = MainTabView.defaultSelection

    /// Normalde Bugün (0). DEBUG ekran görüntüsü modunda istenen sekme.
    private static var defaultSelection: Int {
        #if DEBUG
        return UITestConfig.initialTab
        #else
        return 0
        #endif
    }

    var body: some View {
        TabView(selection: $selection) {
            CounterView(profile: profile)
                .tabItem { Label("Bugün", systemImage: "leaf.fill") }
                .tag(0)

            JourneyView(profile: profile)
                .tabItem { Label("Program", systemImage: "map.fill") }
                .tag(1)

            RecoveryTimelineView(profile: profile)
                .tabItem { Label("İyileşme", systemImage: "heart.text.square.fill") }
                .tag(2)

            StatsView(profile: profile)
                .tabItem { Label("İstatistik", systemImage: "chart.bar.fill") }
                .tag(3)

            SettingsView(profile: profile)
                .tabItem { Label("Ayarlar", systemImage: "gearshape.fill") }
                .tag(4)
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
