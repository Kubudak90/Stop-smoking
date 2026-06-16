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

    /// Uzak/gömülü veriyi matematiğe sokmadan önce doğrula: negatif/sıfır/NaN fiyat veya
    /// boş marka, "biriken para" hesabını bozardı.
    var isValid: Bool {
        unitsPerPack > 0
            && !entries.isEmpty
            && entries.allSatisfy {
                $0.pricePerPack.isFinite && $0.pricePerPack > 0 && !$0.brand.trimmingCharacters(in: .whitespaces).isEmpty
            }
    }
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

    /// Açılışta uzak tabloyu çekmeyi dener; başarısızsa gömülü tabloda kalır (offline-first).
    func refresh() async {
        guard let url = Self.remoteURL else { return }
        // Güvenlik: hassas olmayan da olsa, uzak içerik yalnızca HTTPS üzerinden çekilir
        // (düz HTTP / araya girme reddedilir). Gerçek endpoint eklenince ATS de sıkılaştırılmalı.
        guard url.scheme?.lowercased() == "https" else {
            print("[Nefes] Fiyat tablosu reddedildi: yalnızca HTTPS desteklenir (\(url.absoluteString)).")
            return
        }
        do {
            let (bytes, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(PriceCatalogData.self, from: bytes)
            guard decoded.isValid else {
                print("[Nefes] Uzak fiyat tablosu doğrulamadan geçemedi; gömülü tablo korunuyor.")
                return
            }
            self.data = decoded
        } catch {
            // Offline-first: gömülü tablo geçerli kalır. Teşhis için en azından logla.
            print("[Nefes] Uzak fiyat tablosu çekilemedi: \(error.localizedDescription)")
        }
    }

    func price(forBrand brand: String) -> Double? {
        data.entries.first { $0.brand.caseInsensitiveCompare(brand) == .orderedSame }?.pricePerPack
    }

    private static func loadBundled() -> PriceCatalogData {
        if let url = Bundle.main.url(forResource: "default_prices", withExtension: "json"),
           let bytes = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode(PriceCatalogData.self, from: bytes),
           decoded.isValid {
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
