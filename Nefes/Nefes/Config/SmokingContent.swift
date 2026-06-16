import Foundation

/// Program/Journey (Spec §4.2) + Yoksunluk rehberi & NRT bilgisi (Spec §6) İÇERİĞİ.
///
/// ⚠️ TIBBİ İÇERİK — HEKİM TARAFINDAN DOLDURULACAK:
/// Aşağıdaki metinler İSKELET/PLACEHOLDER'dır. Kurucu (aile hekimi) tarafından
/// gözden geçirilip yazılacaktır (asıl hendek — Spec §2). "İyileştirir/garanti" dili
/// KULLANILMAZ; içerik bilgilendirir ve profesyonele (ALO 171 / poliklinik) yönlendirir
/// (Spec §6 tıbbi sorumluluk sınırı). Yayından önce her madde hekim onayından geçmelidir.
enum SmokingContent {

    // MARK: - Program aşamaları (zaman temelli yolculuk) — Spec §4.2

    struct JourneyStage: Identifiable, Hashable {
        let id: String
        /// Aşamanın başladığı bırakma-sonrası süre (sıralama ve "şu an buradasın" için).
        let startOffset: TimeInterval
        let title: String
        let summary: String
        /// Hekim temelli, eyleme dönük kısa maddeler.
        let tips: [String]
        /// Ücretsiz katmanda görünür mü? (Hazırlık + ilk 72 saat ücretsiz; gerisi premium — Spec §8.)
        let isFreeTier: Bool
    }

    static let journeyStages: [JourneyStage] = [
        JourneyStage(
            id: "prep",
            startOffset: .hours(-24),   // bırakmadan önceki hazırlık (negatif = "bugün/öncesi")
            title: "Hazırlık",
            summary: "Bırakmaya hazırlanmak, başarının yarısıdır. Ortamını ve zihnini hazırla.",
            tips: [
                "TODO(hekim): Bırakma gününü seç ve evdeki sigara/çakmak/kül tablalarını temizle.",
                "TODO(hekim): En sık içtiğin 3 anı (tetikleyici) önceden belirle ve alternatif planla.",
                "TODO(hekim): Yakınlarına haber ver; destek istemek zayıflık değil, strateji."
            ],
            isFreeTier: true
        ),
        JourneyStage(
            id: "first72h",
            startOffset: 0,
            title: "İlk 72 saat",
            summary: "En kritik dönem. Nikotin vücuttan çıkarken istekler yoğun ama kısa sürer.",
            tips: [
                "TODO(hekim): İstek geldiğinde 4 dakikalık nefes egzersizini kullan (Craving SOS).",
                "TODO(hekim): Bol su iç, kısa yürüyüşler yap, kafeini azalt.",
                "TODO(hekim): Bu his geçicidir — her dalga bir öncekinden zayıf."
            ],
            isFreeTier: true
        ),
        JourneyStage(
            id: "week2",
            startOffset: .days(3),
            title: "İlk 2 hafta",
            summary: "Fiziksel bağımlılık geriler; alışkanlık ve rutin tetikleyicileri öne çıkar.",
            tips: [
                "TODO(hekim): Rutinlerini değiştir (kahve, mola, yemek sonrası).",
                "TODO(hekim): Tetikleyici kaydını gözden geçir ve plan kur."
            ],
            isFreeTier: false
        ),
        JourneyStage(
            id: "month1",
            startOffset: .days(14),
            title: "1 ay",
            summary: "Yeni normal oturuyor. Öz güven artar; dikkat dağınıklığı/iştah dengelenir.",
            tips: [
                "TODO(hekim): Biriken parayı somut bir hedefe bağla.",
                "TODO(hekim): Egzersiz ve nefes kapasitesindeki iyileşmeyi fark et."
            ],
            isFreeTier: false
        ),
        JourneyStage(
            id: "month3",
            startOffset: .days(30),
            title: "3 ay ve sonrası",
            summary: "Kalıcılık aşaması. Nadir gelen güçlü istekleri yönetmek esastır.",
            tips: [
                "TODO(hekim): 'Tek sigaradan bir şey olmaz' tuzağına karşı planını hatırla.",
                "TODO(hekim): Kayma olursa kendini suçlama; kaydet, öğren, devam et (Spec §5)."
            ],
            isFreeTier: false
        )
    ]

    // MARK: - Yoksunluk rehberi (Spec §6 "Yoksunluk rehberi")

    struct WithdrawalItem: Identifiable, Hashable {
        var id: String { symptom }
        let symptom: String
        let whatToExpect: String
        let coping: String
    }

    static let withdrawalGuide: [WithdrawalItem] = [
        WithdrawalItem(
            symptom: "Sigara isteği (craving)",
            whatToExpect: "TODO(hekim): İlk günlerde sık ve yoğun; genelde 3-5 dakikada zirve yapıp geçer.",
            coping: "TODO(hekim): Nefes egzersizi, su, dikkat dağıtma; isteği bir dalga gibi izle."
        ),
        WithdrawalItem(
            symptom: "Sinirlilik / huzursuzluk",
            whatToExpect: "TODO(hekim): İlk 1-2 hafta belirgin; zamanla azalır.",
            coping: "TODO(hekim): Hafif egzersiz, uyku düzeni, kafein azaltımı."
        ),
        WithdrawalItem(
            symptom: "Konsantrasyon güçlüğü / uyku değişimi",
            whatToExpect: "TODO(hekim): Geçici; beyin nikotinsiz dengeyi yeniden kurar.",
            coping: "TODO(hekim): Kısa molalar, düzenli uyku; gerekirse hekime danış."
        )
    ]

    // MARK: - NRT ve profesyonel destek (Spec §6) — dengeli, yönlendiren

    struct InfoCard: Identifiable, Hashable {
        var id: String { title }
        let title: String
        let body: String
    }

    static let supportInfo: [InfoCard] = [
        InfoCard(
            title: "Nikotin replasman tedavisi (NRT)",
            body: "TODO(hekim): Bant/sakız/pastil hakkında dengeli, tarafsız bilgi. Nefes ilaç önermez; "
                + "uygunluk ve doz için hekime/eczacıya yönlendirir."
        ),
        InfoCard(
            title: "Reçeteli destek",
            body: "TODO(hekim): Bazı kişilerde hekim kontrolünde ilaç desteği faydalı olabilir. "
                + "Karar ve takip hekime aittir."
        ),
        InfoCard(
            title: "ALO 171 & sigara bırakma poliklinikleri",
            body: "ALO 171 Sigara Bırakma Danışma Hattı ücretsiz ve gizlidir. Sigara bırakma "
                + "poliklinikleri için aile hekimine başvurabilirsin. Nefes tedavi yerine geçmez, sürece eşlik eder."
        )
    ]
}
