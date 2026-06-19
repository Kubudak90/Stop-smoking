import Foundation

/// Program/Journey (Spec §4.2) + Yoksunluk rehberi & NRT bilgisi (Spec §6) İÇERİĞİ.
///
/// ⚠️ TIBBİ İÇERİK — HEKİM ONAYINA HAZIR TASLAK:
/// Aşağıdaki metinler, kılavuz temelli (Sağlık Bakanlığı / WHO çizgisinde) ve
/// sorumlu bir dille yazılmış TASLAK'tır. Kurucu (aile hekimi) tarafından
/// yayından önce gözden geçirilip onaylanmalıdır (asıl hendek — Spec §2).
/// "İyileştirir/garanti" dili KULLANILMAZ; içerik bilgilendirir ve profesyonele
/// (ALO 171 / sigara bırakma polikliniği) yönlendirir (Spec §6 tıbbi sorumluluk sınırı).
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
                "Bir bırakma günü belirle ve o güne kadar evdeki sigara, çakmak ve kül tablalarını ortadan kaldır. Ortamı sigarasız hale getirmek isteği azaltır.",
                "En sık sigara içtiğin 3 anı (örneğin kahveyle, telefonda, araçta) önceden yaz ve her biri için alternatif bir davranış planla.",
                "Yakınlarına bıraktığını söyle. Destek istemek zayıflık değil, bir stratejidir; seninle birlikte bırakan biri olması şansını artırır."
            ],
            isFreeTier: true
        ),
        JourneyStage(
            id: "first72h",
            startOffset: 0,
            title: "İlk 72 saat",
            summary: "En kritik dönem. Nikotin vücuttan çıkarken istekler yoğun ama kısa sürer.",
            tips: [
                "İstek geldiğinde Craving SOS'taki nefes egzersizini uygula. İstek genellikle birkaç dakikada zirve yapıp geçer.",
                "Bol su iç, kısa yürüyüşler yap ve kafeini azalt. Bırakma sonrası kafeinin etkisi artabilir.",
                "İsteği bir dalga gibi düşün: her dalga yükselir ve geçer, üstelik zamanla zayıflar."
            ],
            isFreeTier: true
        ),
        JourneyStage(
            id: "week2",
            startOffset: .days(3),
            title: "İlk 2 hafta",
            summary: "Fiziksel bağımlılık geriler; alışkanlık ve rutin tetikleyicileri öne çıkar.",
            tips: [
                "Sigarayla eşleşmiş rutinleri değiştir: kahveni farklı bir yerde iç, yemek sonrası hemen masadan kalk, molanı kısa bir yürüyüşe çevir.",
                "Tetikleyici kayıtlarını gözden geçir; en çok hangi durumda zorlandığını gör ve o an için önceden somut bir plan hazırla."
            ],
            isFreeTier: false
        ),
        JourneyStage(
            id: "month1",
            startOffset: .days(14),
            title: "1 ay",
            summary: "Yeni normal oturuyor. Öz güven artar; dikkat dağınıklığı/iştah dengelenir.",
            tips: [
                "Biriken parayı görünür ve somut bir hedefe bağla. Neden biriktirdiğini görmek devam etmek için güçlü bir motivasyon olur.",
                "Nefes, tat ve koku gibi iyileşmeleri fark et. Küçük kazanımları not etmek kararlılığı besler."
            ],
            isFreeTier: false
        ),
        JourneyStage(
            id: "month3",
            startOffset: .days(30),
            title: "3 ay ve sonrası",
            summary: "Kalıcılık aşaması. Nadir gelen güçlü istekleri yönetmek esastır.",
            tips: [
                "'Tek sigaradan bir şey olmaz' düşüncesi en sık nüks nedenidir. Planını ve bıraktığın nedenleri önceden hatırla.",
                "Kayma olursa kendini suçlama; ne zaman ve neden olduğunu kaydet, öğren ve devam et. Bir kayma tüm ilerlemeni silmez (Spec §5)."
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
            whatToExpect: "İlk günlerde sık ve yoğun olabilir. Tek bir istek genellikle birkaç dakika içinde zirve yapar ve kendiliğinden geçer; ilerleyen günlerde seyrekleşir.",
            coping: "Nefes egzersizi, bir bardak su, kısa bir yürüyüş veya dikkat dağıtan bir uğraş yardımcı olur. İsteği bastırmaya çalışmak yerine bir dalga gibi geçmesini bekle."
        ),
        WithdrawalItem(
            symptom: "Sinirlilik / huzursuzluk",
            whatToExpect: "İlk 1-2 haftada belirgin olabilir; çoğu kişide birkaç hafta içinde azalır.",
            coping: "Hafif egzersiz, düzenli uyku ve kafeini azaltmak yardımcı olur. Yoğun ve sürekli sıkıntı halinde hekimine danış."
        ),
        WithdrawalItem(
            symptom: "Konsantrasyon güçlüğü / uyku değişimi",
            whatToExpect: "Genellikle geçicidir; vücut nikotinsiz dengeye uyum sağladıkça düzelir.",
            coping: "Gün içinde kısa molalar ver ve uyku düzenini koru. Belirtiler uzun sürer veya günlük yaşamını zorlaştırırsa hekimine danış."
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
            body: "Nikotin bandı, sakızı ve pastili gibi nikotin replasman ürünleri, yoksunluk "
                + "belirtilerini hafifletmeye yardımcı olabilen seçeneklerdir. Uygunluk, ürün tipi ve "
                + "doz kişiden kişiye değişir. Nefes ilaç önermez; doğru seçim için hekimine veya "
                + "eczacına danışmanı öneririz."
        ),
        InfoCard(
            title: "Reçeteli destek",
            body: "Bazı kişilerde, hekim değerlendirmesiyle reçeteli ilaç desteği bırakma sürecine "
                + "katkı sağlayabilir. Bu ilaçların uygunluğu, başlanması ve takibi yalnızca hekim "
                + "kararıyla olur. Karar ve takip hekime aittir."
        ),
        InfoCard(
            title: "ALO 171 & sigara bırakma poliklinikleri",
            body: "ALO 171 Sigara Bırakma Danışma Hattı ücretsiz ve gizlidir. Sigara bırakma "
                + "poliklinikleri için aile hekimine başvurabilirsin. Nefes tedavi yerine geçmez, sürece eşlik eder."
        )
    ]
}
