import Foundation
import StoreKit

/// StoreKit 2 abonelik yönetimi. Spec §8 (Gelir Modeli: Freemium + yıllık abonelik).
///
/// Premium: tam program, Craving SOS tam set, tetikleyici yönetimi, tam iyileşme takvimi,
/// detaylı istatistik, kişiselleştirilmiş bildirimler. Ücretsiz: sayaç, temel seri,
/// biriken para, iyileşme takviminin ilk birkaç adımı.
@MainActor
final class StoreManager: ObservableObject {

    /// Ürün id'leri. App Store Connect ve Nefes.storekit ile eşleşmeli.
    enum ProductID {
        static let yearly = "com.nefes.app.premium.yearly"
        static let monthly = "com.nefes.app.premium.monthly"
        static let all = [yearly, monthly]
    }

    @Published private(set) var products: [Product] = []
    @Published private(set) var isPremium = false
    @Published private(set) var purchaseInFlight = false
    @Published var lastError: String?

    /// Geliştirme/önizleme için premium'u elle açmaya yarar (StoreKit yokken).
    /// Üretimde gerçek entitlement bunu ezer.
    @Published var debugOverridePremium = false {
        didSet { recomputeEntitlement() }
    }

    private var updatesTask: Task<Void, Never>?
    private var hasEntitlement = false

    init() {
        updatesTask = listenForTransactions()
    }

    deinit { updatesTask?.cancel() }

    func bootstrap() async {
        await loadProducts()
        await refreshEntitlements()
    }

    func loadProducts() async {
        do {
            let storeProducts = try await Product.products(for: ProductID.all)
            // Yıllık önce: davranışsal çapa (Spec §8 — aylık pahalı, yıllık cazip).
            products = storeProducts.sorted { lhs, rhs in
                (lhs.id == ProductID.yearly ? 0 : 1) < (rhs.id == ProductID.yearly ? 0 : 1)
            }
        } catch {
            lastError = "Ürünler yüklenemedi: \(error.localizedDescription)"
        }
    }

    var yearlyProduct: Product? { products.first { $0.id == ProductID.yearly } }
    var monthlyProduct: Product? { products.first { $0.id == ProductID.monthly } }

    @discardableResult
    func purchase(_ product: Product) async -> Bool {
        purchaseInFlight = true
        defer { purchaseInFlight = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshEntitlements()
                return isPremium
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            lastError = "Satın alma tamamlanamadı: \(error.localizedDescription)"
            return false
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            lastError = "Geri yükleme başarısız: \(error.localizedDescription)"
        }
    }

    func refreshEntitlements() async {
        var entitled = false
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               ProductID.all.contains(transaction.productID),
               transaction.revocationDate == nil {
                entitled = true
            }
        }
        hasEntitlement = entitled
        recomputeEntitlement()
    }

    private func recomputeEntitlement() {
        isPremium = hasEntitlement || debugOverridePremium
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            for await update in Transaction.updates {
                guard let self else { continue }
                if let transaction = try? self.checkVerified(update) {
                    await transaction.finish()
                    await self.refreshEntitlements()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error): throw error
        case .verified(let safe): return safe
        }
    }
}
