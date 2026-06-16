import SwiftUI
import SwiftData

/// Nefes — Sigarayı Bırakma & Alışkanlık Yenme Uygulaması.
/// Offline-first, SwiftData + StoreKit 2. Spec §9.
@main
struct NefesApp: App {
    @StateObject private var env = AppEnvironment()

    /// Offline-first kalıcı depo. Hassas sağlık verisi yalnızca cihazda (Spec §17 KVKK).
    let modelContainer: ModelContainer = {
        let schema = Schema([UserProfile.self, SlipRecord.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("ModelContainer oluşturulamadı: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(env)
                .environmentObject(env.store)
                .environmentObject(env.notifications)
                .environmentObject(env.prices)
                .tint(Theme.primary)
                .task { await env.bootstrap() }
        }
        .modelContainer(modelContainer)
    }
}
