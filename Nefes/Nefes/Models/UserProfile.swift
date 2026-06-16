import Foundation
import SwiftData

/// Kullanıcının bırakma profili. Offline-first: tüm veri cihazda (Spec §9, §17 KVKK).
///
/// Hassas sağlık verisi cihazda tutulur — KVKK avantajı (Spec §17).
@Model
final class UserProfile {
    /// Hangi alışkanlık? Wedge-to-platform: MVP'de daima `.smoking`. Spec §9.
    var habitTypeRaw: String

    /// Motivasyon kaydı — "neden bırakıyorum". Craving SOS'ta hatırlatılır. Spec §10, §4.
    var reasons: [String]

    /// Günde içilen birim (sigara) sayısı. Maliyet ve "içilmeyen sigara" hesabı.
    var unitsPerDay: Int

    /// Paket fiyatı (TL). Kullanıcı markasına göre ayarlar. Spec §9 (`unit_cost`).
    var pricePerPack: Double

    /// Pakette kaç birim var (sigara için 20).
    var unitsPerPack: Int

    /// Kullanıcının markası (opsiyonel, fiyat tablosu eşleştirmesi için).
    var brand: String?

    /// Bırakma anı. Sayaç bu andan itibaren işler. Spec §10.
    var quitDate: Date

    /// Profilin oluşturulma anı (onboarding tamamlama).
    var createdAt: Date

    /// Son "hâlâ temizim" check-in'i. Spec §13 retention proxy.
    var lastCleanCheckIn: Date?

    init(
        habitType: HabitType = .smoking,
        reasons: [String] = [],
        unitsPerDay: Int = 20,
        pricePerPack: Double = 0,
        unitsPerPack: Int = 20,
        brand: String? = nil,
        quitDate: Date = .now,
        createdAt: Date = .now
    ) {
        self.habitTypeRaw = habitType.rawValue
        self.reasons = reasons
        self.unitsPerDay = unitsPerDay
        self.pricePerPack = pricePerPack
        self.unitsPerPack = unitsPerPack
        self.brand = brand
        self.quitDate = quitDate
        self.createdAt = createdAt
        self.lastCleanCheckIn = nil
    }

    var habitType: HabitType {
        HabitType(rawValue: habitTypeRaw) ?? .smoking
    }

    /// Bir birimin (sigara) maliyeti.
    var pricePerUnit: Double {
        guard unitsPerPack > 0 else { return 0 }
        return pricePerPack / Double(unitsPerPack)
    }
}
