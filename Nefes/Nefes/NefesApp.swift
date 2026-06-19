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
        let container: ModelContainer
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Kalıcı depo açılamadı (ör. şema uyumsuzluğu, bozuk/dolu disk). Çökmek ve tüm
            // oturumu öldürmek yerine bellek-içi depoya düşüyoruz: uygulama çalışır kalır
            // (bu oturumda kayıt kalıcı olmaz). Diskteki veri silinmez, yalnızca yüklenmez.
            print("[Nefes] Kalıcı ModelContainer açılamadı, bellek-içi depoya düşülüyor: \(error)")
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            guard let memoryContainer = try? ModelContainer(for: schema, configurations: [fallback]) else {
                fatalError("Bellek-içi ModelContainer bile oluşturulamadı: \(error)")
            }
            container = memoryContainer
        }
        #if DEBUG
        UITestConfig.seedIfNeeded(container)   // App Store ekran görüntüleri için (no-op normalde)
        #endif
        return container
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(env)
                .environmentObject(env.store)
                .environmentObject(env.notifications)
                .environmentObject(env.prices)
                .tint(Theme.primary)
                // Nefes paleti tek bir açık tema üzerine kurulu (Theme.background/surface
                // sabit açık renkler). Sistem koyu moddayken renk belirtilmeyen metinler
                // beyaza döner ve açık zeminde okunmaz olur. Tüm uygulamayı (sheet'ler ve
                // Form'lar dahil) açık görünüme sabitleyerek kontrastı garanti altına alıyoruz.
                // (Tam koyu-mod desteği için ayrı bir koyu palet gerekir — Faz 2.)
                .preferredColorScheme(.light)
                .task {
                    await env.bootstrap()
                    #if DEBUG
                    if UITestConfig.wantsPremium { env.store.debugOverridePremium = true }
                    #endif
                }
        }
        .modelContainer(modelContainer)
    }
}
