import SwiftUI
import SwiftData

/// Onboarding tamamlanmış mı diye bakar; tamamlanmadıysa onboarding, tamamlandıysa
/// ana sekmeli arayüzü gösterir.
struct RootView: View {
    @Query private var profiles: [UserProfile]

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

    var body: some View {
        TabView {
            CounterView(profile: profile)
                .tabItem { Label("Bugün", systemImage: "leaf.fill") }

            RecoveryTimelineView(profile: profile)
                .tabItem { Label("İyileşme", systemImage: "heart.text.square.fill") }

            StatsView(profile: profile)
                .tabItem { Label("İstatistik", systemImage: "chart.bar.fill") }

            SettingsView(profile: profile)
                .tabItem { Label("Ayarlar", systemImage: "gearshape.fill") }
        }
    }
}
