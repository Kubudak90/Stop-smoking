import Foundation

/// İyileşme zaman çizelgesinin tek bir adımı (gamified). Spec §6.
///
/// Tıbbi sorumluluk sınırı: metinler bilgilendirir, "iyileştirir/garanti" dili taşımaz.
/// İçerik bilgilendirir, profesyonele yönlendirir (Spec §6 tıbbi sorumluluk sınırı).
struct HealthMilestone: Identifiable, Hashable {
    let id: String

    /// Bırakma anından itibaren bu kilometre taşına ulaşmak için geçmesi gereken süre.
    let timeOffset: TimeInterval

    /// Kısa başlık, kutlama bildiriminde de kullanılır.
    let title: String

    /// Hekim temelli açıklama.
    let detail: String

    /// Ücretsiz katmanda gösterilen ilk birkaç adım mı? Spec §8 (iyileşme takviminin ilk
    /// birkaç adımı ücretsiz, tamamı premium).
    let isFreeTier: Bool

    func isReached(since quitDate: Date, now: Date = .now) -> Bool {
        now.timeIntervalSince(quitDate) >= timeOffset
    }

    func reachedDate(since quitDate: Date) -> Date {
        quitDate.addingTimeInterval(timeOffset)
    }
}

extension TimeInterval {
    static func minutes(_ m: Double) -> TimeInterval { m * 60 }
    static func hours(_ h: Double) -> TimeInterval { h * 3600 }
    static func days(_ d: Double) -> TimeInterval { d * 86_400 }
}
