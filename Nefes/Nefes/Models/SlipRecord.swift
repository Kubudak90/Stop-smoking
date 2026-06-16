import Foundation
import SwiftData

/// Bir "kayma" (slip) kaydı. ASIL FARKLILAŞTIRICI. Spec §5.
///
/// "Kayma" ≠ "Sıfırlama": tek sigara tüm ilerlemeyi silmez. Sistem bunu bir veri ve
/// öğrenme olarak ele alır, ceza olarak değil. Sayaç sıfırlanmaz; yalnızca içilmeyen
/// sigara sayısından düşülür ve tetikleyici örüntüsüne yakıt olur.
@Model
final class SlipRecord {
    var date: Date

    /// İçilen birim sayısı (genelde 1).
    var unitCount: Int

    /// Tetikleyici kategorisi id'si (TriggerCategory.id).
    var triggerCategoryID: String?

    /// Duygu durumu (SlipEmotion.rawValue).
    var emotionRaw: String?

    /// Serbest not — "ne zaman, nerede".
    var note: String?

    init(
        date: Date = .now,
        unitCount: Int = 1,
        triggerCategoryID: String? = nil,
        emotion: SlipEmotion? = nil,
        note: String? = nil
    ) {
        self.date = date
        self.unitCount = unitCount
        self.triggerCategoryID = triggerCategoryID
        self.emotionRaw = emotion?.rawValue
        self.note = note
    }

    var emotion: SlipEmotion? {
        get { emotionRaw.flatMap(SlipEmotion.init(rawValue:)) }
        set { emotionRaw = newValue?.rawValue }
    }
}
