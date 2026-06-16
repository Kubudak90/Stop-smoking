import Foundation

/// Marka → paket fiyatı varsayılan tablosu. Spec §9 (Fiyat güncelleme).
///
/// Sigara fiyatları sık değiştiği için tablo uzaktan güncellenebilir basit bir JSON'dur:
/// uygulama açılışında çekilmeye çalışılır, başarısız olursa pakete gömülü kopya kullanılır
/// (offline-first). Kullanıcı her zaman kendi fiyatını elle ayarlayabilir.
struct PriceEntry: Codable, Identifiable, Hashable {
    let brand: String
    let pricePerPack: Double
    var id: String { brand }
}

struct PriceCatalogData: Codable {
    let updatedAt: String
    let currency: String
    let unitsPerPack: Int
    let entries: [PriceEntry]
}

@MainActor
final class PriceCatalog: ObservableObject {
    @Published private(set) var data: PriceCatalogData

    /// Uzak tablo adresi. Boş bırakılırsa yalnızca gömülü tablo kullanılır.
    /// Faz 0/1'de basit bir static JSON host'una işaret edebilir.
    static let remoteURL: URL? = nil

    init() {
        self.data = Self.loadBundled()
    }

    /// Açılışta uzak tabloyu çekmeyi dener; başarısızsa sessizce gömülü tabloda kalır.
    func refresh() async {
        guard let url = Self.remoteURL else { return }
        do {
            let (bytes, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(PriceCatalogData.self, from: bytes)
            self.data = decoded
        } catch {
            // Offline-first: hata yutulur, gömülü tablo geçerli kalır.
        }
    }

    func price(forBrand brand: String) -> Double? {
        data.entries.first { $0.brand.caseInsensitiveCompare(brand) == .orderedSame }?.pricePerPack
    }

    private static func loadBundled() -> PriceCatalogData {
        if let url = Bundle.main.url(forResource: "default_prices", withExtension: "json"),
           let bytes = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode(PriceCatalogData.self, from: bytes) {
            return decoded
        }
        // Son çare: minimal gömülü varsayılan (Haziran 2026 bandı, Spec §1).
        return PriceCatalogData(
            updatedAt: "2026-06-01",
            currency: "TRY",
            unitsPerPack: 20,
            entries: [PriceEntry(brand: "Ortalama", pricePerPack: 110)]
        )
    }
}
