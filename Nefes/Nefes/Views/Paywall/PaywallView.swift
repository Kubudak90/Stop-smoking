import SwiftUI
import StoreKit

/// Paywall. Spec §8, §11 (en kritik tasarım kararı: zamanlama).
///
/// Değer-sonra-paywall. Para karşılaştırması + sağlık vaadi. Bağlama göre üst mesaj değişir
/// (A/B test altyapısı için `context` ile basit varyasyon — Spec §11).
struct PaywallView: View {
    enum Context {
        case postOnboarding   // değer gösterildikten sonra
        case cravingSOS       // ilk kriz anı tetikleyicisi (en yüksek dönüşüm)
        case recoveryTimeline
        case stats

        var headline: String {
            switch self {
            case .postOnboarding: return "Bu sefer gerçekten bırak."
            case .cravingSOS: return "Bir daha bu kadar zorlanma."
            case .recoveryTimeline: return "İyileşmenin tamamını gör."
            case .stats: return "Kendini gerçekten tanı."
            }
        }

        var subhead: String {
            switch self {
            case .postOnboarding: return "Sayaç başlangıç. Asıl iş; tetikleyicilerini yenmek ve zor anı atlatmak."
            case .cravingSOS: return "Tetikleyici yönetimi ve kişisel kriz planı ile istekler seyrelir."
            case .recoveryTimeline: return "Tüm sağlık kilometre taşları, 20 dakikadan 10 yıla."
            case .stats: return "Tetikleyici örüntülerin, para projeksiyonun ve ilerleme grafiklerin."
            }
        }
    }

    let context: Context
    let stats: QuitStats?

    @EnvironmentObject private var store: StoreManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedProductID = StoreManager.ProductID.yearly

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                header
                moneyComparisonCard
                featureList
                planSelector
                purchaseButton
                footer
            }
            .padding(24)
        }
        .background(Theme.background)
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Theme.textSecondary.opacity(0.5))
            }
            .padding()
        }
        .task { if store.products.isEmpty { await store.loadProducts() } }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 44))
                .foregroundStyle(Theme.primary)
            Text(context.headline)
                .font(.system(.title, design: .rounded).weight(.bold))
                .multilineTextAlignment(.center)
            Text(context.subhead)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 12)
    }

    // MARK: - Para karşılaştırması (Spec §7, §11) — Türkiye'ye özel kanca

    private var moneyComparisonCard: some View {
        VStack(spacing: 8) {
            if let stats, stats.moneySaved > 0 {
                Text("Bıraktığından beri \(AppFormatters.money(stats.moneySaved)) biriktirdin.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            // Yıllık sigara maliyeti çapası (Spec §8 — ~40.000 TL karşısında abonelik gülünç ucuz)
            Text("Sigara sana yılda on binlerce TL'ye mal oluyor. Nefes Premium, bu paranın küçük bir kısmı — ve kendini ilk birkaç günde amorti eder.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(Theme.accent.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Self.features, id: \.self) { feature in
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.primary)
                    Text(feature).font(.subheadline)
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Plan seçimi (yıllık çapa — Spec §8)

    private var planSelector: some View {
        VStack(spacing: 10) {
            if store.products.isEmpty {
                // StoreKit ürünleri yüklenmediğinde (örn. config eksik) bilgilendirici metin.
                Text("Abonelik seçenekleri yükleniyor…")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            ForEach(store.products) { product in
                PlanRow(
                    product: product,
                    isSelected: selectedProductID == product.id,
                    isBestValue: product.id == StoreManager.ProductID.yearly
                ) {
                    selectedProductID = product.id
                }
            }
        }
    }

    private var purchaseButton: some View {
        VStack(spacing: 10) {
            Button {
                Task { await purchase() }
            } label: {
                Group {
                    if store.purchaseInFlight {
                        ProgressView().tint(.white)
                    } else {
                        Text(purchaseTitle)
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Theme.gradient)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .disabled(store.purchaseInFlight || store.products.isEmpty)

            Button("Satın alımları geri yükle") {
                Task { await store.restorePurchases(); if store.isPremium { dismiss() } }
            }
            .font(.caption)
            .foregroundStyle(Theme.textSecondary)
        }
    }

    private var purchaseTitle: String {
        if let product = store.products.first(where: { $0.id == selectedProductID }),
           let offer = product.subscription?.introductoryOffer, offer.paymentMode == .freeTrial {
            return "\(offer.period.unit.localizedTrial(offer.period.value)) ücretsiz dene"
        }
        return "Premium'a geç"
    }

    private var footer: some View {
        VStack(spacing: 6) {
            if let error = store.lastError {
                Text(error).font(.caption2).foregroundStyle(Theme.danger)
            }
            Text("Abonelik otomatik yenilenir, istediğin zaman App Store'dan iptal edebilirsin. Ödeme Apple hesabından alınır.")
                .font(.caption2)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 4)
    }

    private func purchase() async {
        guard let product = store.products.first(where: { $0.id == selectedProductID }) else { return }
        let success = await store.purchase(product)
        if success { dismiss() }
    }

    static let features = [
        "Tam Craving SOS araç seti ve kişisel kriz planı",
        "Tetikleyici yönetimi ve örüntü analizi",
        "Tam iyileşme takvimi (20 dk → 10 yıl)",
        "Detaylı istatistik ve para projeksiyonu",
        "Kişiselleştirilmiş, destekleyici bildirimler",
        "Reklamsız — her zaman"
    ]
}

private struct PlanRow: View {
    let product: Product
    let isSelected: Bool
    let isBestValue: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(isSelected ? Theme.primary : Theme.textSecondary)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(product.displayName).font(.subheadline.weight(.semibold))
                        if isBestValue {
                            Text("EN İYİ")
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Theme.accent)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    if let trial = product.subscription?.introductoryOffer, trial.paymentMode == .freeTrial {
                        Text("Önce ücretsiz dene")
                            .font(.caption2).foregroundStyle(Theme.primary)
                    }
                }
                Spacer()
                Text(product.displayPrice).font(.subheadline.weight(.bold))
            }
            .padding(16)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Theme.primary : Theme.textSecondary.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private extension Product.SubscriptionPeriod.Unit {
    func localizedTrial(_ count: Int) -> String {
        switch self {
        case .day: return "\(count) gün"
        case .week: return "\(count * 7) gün"
        case .month: return "\(count) ay"
        case .year: return "\(count) yıl"
        @unknown default: return "\(count) gün"
        }
    }
}
