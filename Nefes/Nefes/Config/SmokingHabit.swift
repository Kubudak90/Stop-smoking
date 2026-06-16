import Foundation

/// Sigara alışkanlığının config'i — wedge-to-platform'un ilk ve tek konfigürasyonu.
/// Spec §6 (tıbbi içerik omurgası), §9 (veri modeli).
///
/// İYİLEŞME TAKVİMİ — TIBBİ SORUMLULUK NOTU:
/// Aşağıdaki metinler genel kabul görmüş sağlık bilgisidir, bilgilendirme amaçlıdır.
/// "İyileştirir / garanti" dili kullanılmaz; uygulama tedavi yerine geçmez, ona köprü olur
/// (Spec §6). Kişiye özel tıbbi durum için hekime / ALO 171'e yönlendirilir.
enum SmokingHabit {

    static let config = HabitConfig(
        id: .smoking,
        unitSingular: "sigara",
        unitPlural: "sigara",
        unitsPerPack: 20,
        lifeRegainedMinutesPerUnit: 11, // her sigara ≈ 11 dk
        healthMilestones: milestones,
        triggerCategories: triggers,
        displayName: "Sigara"
    )

    /// Spec §6 iyileşme zaman çizelgesi. İlk birkaç adım ücretsiz (Spec §8).
    static let milestones: [HealthMilestone] = [
        HealthMilestone(
            id: "m_20min",
            timeOffset: .minutes(20),
            title: "20 dakika",
            detail: "Kalp atış hızın ve tansiyonun düşmeye başlar; ellerinin ve ayaklarının sıcaklığı normale döner.",
            isFreeTier: true
        ),
        HealthMilestone(
            id: "m_12h",
            timeOffset: .hours(12),
            title: "12 saat",
            detail: "Kandaki karbonmonoksit seviyesi düşer, oksijen seviyesi normale yaklaşır.",
            isFreeTier: true
        ),
        HealthMilestone(
            id: "m_24h",
            timeOffset: .hours(24),
            title: "24 saat",
            detail: "Kalp krizi riskin azalmaya başlar. İlk tam günü geride bıraktın.",
            isFreeTier: true
        ),
        HealthMilestone(
            id: "m_48h",
            timeOffset: .hours(48),
            title: "48 saat",
            detail: "Sinir uçların yenilenmeye başlar; koku ve tat alma duyuların güçlenir.",
            isFreeTier: false
        ),
        HealthMilestone(
            id: "m_72h",
            timeOffset: .hours(72),
            title: "72 saat",
            detail: "Nikotin vücudundan büyük ölçüde atılır. En zor fiziksel dönem geride; nefes alıp vermek kolaylaşır.",
            isFreeTier: false
        ),
        HealthMilestone(
            id: "m_2w",
            timeOffset: .days(14),
            title: "2 hafta",
            detail: "Dolaşımın iyileşir, yürümek ve egzersiz yapmak kolaylaşmaya başlar.",
            isFreeTier: false
        ),
        HealthMilestone(
            id: "m_1m",
            timeOffset: .days(30),
            title: "1 ay",
            detail: "Akciğer fonksiyonların artar; öksürük ve nefes darlığı azalır.",
            isFreeTier: false
        ),
        HealthMilestone(
            id: "m_3m",
            timeOffset: .days(90),
            title: "3 ay",
            detail: "Dolaşım belirgin düzelir, akciğerlerin kendini temizleme kapasitesi artar.",
            isFreeTier: false
        ),
        HealthMilestone(
            id: "m_1y",
            timeOffset: .days(365),
            title: "1 yıl",
            detail: "Kalp-damar hastalığı riskin, içmeye devam eden birine kıyasla yaklaşık yarıya iner.",
            isFreeTier: false
        ),
        HealthMilestone(
            id: "m_5y",
            timeOffset: .days(365 * 5),
            title: "5 yıl",
            detail: "Birçok kansere ve inmeye bağlı risk belirgin biçimde azalır.",
            isFreeTier: false
        ),
        HealthMilestone(
            id: "m_10y",
            timeOffset: .days(365 * 10),
            title: "10 yıl",
            detail: "Akciğer kanseri riskin, içmeye devam eden birine kıyasla yaklaşık yarıya iner.",
            isFreeTier: false
        )
    ]

    /// Tetikleyici kategorileri — kayma kaydı ve tetikleyici yönetimi için. Spec §5, §10.
    static let triggers: [TriggerCategory] = [
        TriggerCategory(id: "stress", label: "Stres", systemImage: "bolt.fill"),
        TriggerCategory(id: "coffee", label: "Kahve / çay", systemImage: "cup.and.saucer.fill"),
        TriggerCategory(id: "meal", label: "Yemek sonrası", systemImage: "fork.knife"),
        TriggerCategory(id: "alcohol", label: "Alkol", systemImage: "wineglass.fill"),
        TriggerCategory(id: "social", label: "Sosyal ortam", systemImage: "person.2.fill"),
        TriggerCategory(id: "boredom", label: "Can sıkıntısı", systemImage: "hourglass"),
        TriggerCategory(id: "driving", label: "Araba / yol", systemImage: "car.fill"),
        TriggerCategory(id: "morning", label: "Sabah / uyanma", systemImage: "sunrise.fill"),
        TriggerCategory(id: "phone", label: "Telefon / ekran", systemImage: "iphone"),
        TriggerCategory(id: "break", label: "Mola", systemImage: "pause.circle.fill")
    ]

    static func triggerCategory(id: String?) -> TriggerCategory? {
        guard let id else { return nil }
        return triggers.first { $0.id == id }
    }
}
