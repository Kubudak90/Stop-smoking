import SwiftUI
import SwiftData
import UIKit

/// Ayarlar. Spec §10.8:
/// marka/fiyat, bırakma tarihi düzenleme, bildirim tercihleri, ALO 171/poliklinik
/// yönlendirmesi, veri silme (KVKK §17).
struct SettingsView: View {
    let profile: UserProfile

    @Environment(\.modelContext) private var context
    @EnvironmentObject private var env: AppEnvironment
    @EnvironmentObject private var store: StoreManager
    @EnvironmentObject private var notifications: NotificationManager
    @EnvironmentObject private var prices: PriceCatalog
    @Query private var slips: [SlipRecord]

    @State private var showPaywall = false
    @State private var showDeleteConfirm = false
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            Form {
                premiumSection
                consumptionSection
                quitDateSection
                notificationSection
                assistanceSection
                privacySection
                aboutSection
            }
            .navigationTitle("Ayarlar")
            .sheet(isPresented: $showPaywall) {
                PaywallView(context: .stats, stats: nil)
            }
            .alert("Tüm verileri sil", isPresented: $showDeleteConfirm) {
                Button("Sil", role: .destructive) { deleteAllData() }
                Button("Vazgeç", role: .cancel) {}
            } message: {
                Text("Profilin, kayma kayıtların ve tüm ilerlemen kalıcı olarak silinir. Bu işlem geri alınamaz.")
            }
        }
    }

    // MARK: - Premium

    @ViewBuilder
    private var premiumSection: some View {
        Section {
            if store.isPremium {
                Label("Nefes Premium aktif", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(Theme.primary)
            } else {
                Button {
                    showPaywall = true
                } label: {
                    Label("Premium'a geç", systemImage: "sparkles")
                }
                Button("Satın alımları geri yükle") {
                    Task { await store.restorePurchases() }
                }
                .font(.subheadline)
            }
            #if DEBUG
            Toggle("DEBUG: Premium'u aç", isOn: $store.debugOverridePremium)
            #endif
        }
    }

    // MARK: - Tüketim (marka / fiyat)

    private var consumptionSection: some View {
        Section("Tüketim ve fiyat") {
            Stepper("Günde \(profile.unitsPerDay) sigara", value: bindingUnitsPerDay, in: 1...80)

            Picker("Marka", selection: bindingBrand) {
                ForEach(prices.data.entries) { entry in
                    Text(entry.brand).tag(entry.brand)
                }
            }

            HStack {
                Text("Paket fiyatı")
                Spacer()
                TextField("Fiyat", value: bindingPrice, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 90)
                Text("₺")
            }
        }
    }

    // MARK: - Bırakma tarihi

    private var quitDateSection: some View {
        Section("Bırakma anı") {
            DatePicker(
                "Bıraktığın an",
                selection: bindingQuitDate,
                in: ...Date.now,
                displayedComponents: [.date, .hourAndMinute]
            )
            Text("Tarihi değiştirirsen sayaç ve bildirimler yeniden hesaplanır.")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    // MARK: - Bildirimler

    private var notificationSection: some View {
        Section("Bildirimler") {
            HStack {
                Text("Durum")
                Spacer()
                Text(notificationStatusText)
                    .foregroundStyle(Theme.textSecondary)
            }
            if notifications.authorizationStatus == .notDetermined {
                Button("Bildirimlere izin ver") {
                    Task {
                        await notifications.requestAuthorization()
                        await notifications.reschedule(for: profile)
                    }
                }
            } else if notifications.authorizationStatus == .denied {
                Button("Ayarlardan aç") {
                    if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                }
            }
        }
    }

    // MARK: - Profesyonel destek (Spec §6, §17)

    private var assistanceSection: some View {
        Section("Profesyonel destek") {
            Button {
                if let url = URL(string: "tel://171") { openURL(url) }
            } label: {
                Label("ALO 171 Sigara Bırakma Hattı", systemImage: "phone.fill")
            }
            Text("Sigara bırakma poliklinikleri için aile hekimine başvurabilirsin. Nefes tedavi yerine geçmez, sürece eşlik eder.")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    // MARK: - Gizlilik / KVKK (Spec §17)

    private var privacySection: some View {
        Section("Gizlilik (KVKK)") {
            Text("Verilerin yalnızca bu cihazda tutulur. Hiçbir sağlık verin sunucuya gönderilmez.")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Label("Tüm verilerimi sil", systemImage: "trash")
            }
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Nefes")
                Spacer()
                Text("v0.1 (MVP)").foregroundStyle(Theme.textSecondary)
            }
            Text("Bir aile hekimi tarafından, Türkiye için tasarlandı.")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    // MARK: - Bindings (profil güncelleme + yan etkiler)

    private var bindingUnitsPerDay: Binding<Int> {
        Binding(get: { profile.unitsPerDay }, set: { profile.unitsPerDay = $0; save() })
    }
    private var bindingPrice: Binding<Double> {
        Binding(get: { profile.pricePerPack }, set: { profile.pricePerPack = $0; save() })
    }
    private var bindingBrand: Binding<String> {
        Binding(get: { profile.brand ?? "" }, set: { newValue in
            profile.brand = newValue
            if let price = prices.price(forBrand: newValue) { profile.pricePerPack = price }
            save()
        })
    }
    private var bindingQuitDate: Binding<Date> {
        Binding(get: { profile.quitDate }, set: { newValue in
            profile.quitDate = newValue
            save()
            Task { await notifications.reschedule(for: profile) }
        })
    }

    private var notificationStatusText: String {
        switch notifications.authorizationStatus {
        case .authorized, .provisional: return "Açık"
        case .denied: return "Kapalı"
        default: return "Belirlenmedi"
        }
    }

    private func save() { try? context.save() }

    private func deleteAllData() {
        for slip in slips { context.delete(slip) }
        context.delete(profile)
        try? context.save()
        notifications.cancelAll()
        env.hasSeenPostOnboardingPaywall = false
        env.hasUsedCravingSOS = false
    }
}
