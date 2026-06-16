import Foundation

/// Tüm ekranlarda tutarlı biçimlendirme. Türkçe yerel ayar.
enum AppFormatters {

    static let locale = Locale(identifier: "tr_TR")

    /// "4.200 TL" gibi para biçimi.
    static func money(_ value: Double) -> String {
        let f = NumberFormatter()
        f.locale = locale
        f.numberStyle = .decimal
        f.maximumFractionDigits = value >= 100 ? 0 : 2
        let number = f.string(from: NSNumber(value: value)) ?? "0"
        return "\(number) ₺"
    }

    /// Büyük sayıları gruplar: "1.240".
    static func count(_ value: Int) -> String {
        let f = NumberFormatter()
        f.locale = locale
        f.numberStyle = .decimal
        return f.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    /// Geçen süreyi en anlamlı iki birimle verir: "12 gün 4 saat".
    static func duration(_ interval: TimeInterval) -> String {
        let total = Int(max(0, interval))
        let days = total / 86_400
        let hours = (total % 86_400) / 3600
        let minutes = (total % 3600) / 60

        if days > 0 {
            return hours > 0 ? "\(days) gün \(hours) saat" : "\(days) gün"
        } else if hours > 0 {
            return minutes > 0 ? "\(hours) saat \(minutes) dk" : "\(hours) saat"
        } else {
            return "\(minutes) dk"
        }
    }

    /// Canlı sayaç için tam ayrıştırma (gün/saat/dk/sn).
    static func clockComponents(_ interval: TimeInterval) -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let total = Int(max(0, interval))
        return (total / 86_400, (total % 86_400) / 3600, (total % 3600) / 60, total % 60)
    }

    /// Kazanılan ömrü insancıl ifade eder: "≈ 2 gün 6 saat".
    static func lifeRegained(_ interval: TimeInterval) -> String {
        interval < 60 ? "0 dk" : duration(interval)
    }
}
