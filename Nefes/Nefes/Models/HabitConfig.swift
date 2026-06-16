import Foundation

/// Wedge-to-platform çekirdek modeli.
///
/// Uygulama genel bir "alışkanlık yenme" motoru olarak kurulur; pazara tek keskin
/// uçtan (sigara) girilir. Yeni bir alışkanlık eklemek = yeni bir `HabitConfig` +
/// içerik. Motor kodu değişmez.
///
/// Spec §9 (Mimari — wedge-to-platform veri modeli).
enum HabitType: String, Codable, CaseIterable, Identifiable {
    case smoking
    case alcohol
    case vaping
    case sugar

    var id: String { rawValue }
}

/// Bir alışkanlığa özel tüm yapılandırma. Sigara yalnızca ilk konfigürasyondur.
struct HabitConfig: Identifiable, Hashable {
    let id: HabitType

    /// Tüketim birimi, tekil/çoğul (ör. "sigara", "sigara").
    let unitSingular: String
    let unitPlural: String

    /// Bir "paket" içindeki birim sayısı (sigara için 20). Maliyet hesabı bunun üzerinden.
    let unitsPerPack: Int

    /// Her bir birimin geri kazandırdığı dakika (sigara ≈ 11 dk). Spec §10 "kazanılan ömür".
    let lifeRegainedMinutesPerUnit: Double

    /// Sigaraya özel iyileşme takvimi. Spec §6.
    let healthMilestones: [HealthMilestone]

    /// Tetikleyici kategorileri. Spec §5 (tetikleyici öğrenme), §10 (kayma kaydı).
    let triggerCategories: [TriggerCategory]

    /// ASO / pazarlama metinleri için kısa etiket.
    let displayName: String

    func unitLabel(for count: Int) -> String {
        count == 1 ? unitSingular : unitPlural
    }
}
