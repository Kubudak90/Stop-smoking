# Nefes — App Store Yükleme Rehberi

Bu belge, uygulamayı App Store'a göndermek için gereken tüm değerleri ve adımları içerir.
🟢 = Claude tamamladı · 🟡 = Senin yapman gereken (hesap/portal işi)

---

## 0. Ön durum

| Öğe | Durum |
|---|---|
| Kod derleniyor (`BUILD SUCCEEDED`) | 🟢 |
| 9 ekran tam + retention motoru + StoreKit + KVKK | 🟢 |
| Tıbbi içerik (hekim onayına hazır taslak) | 🟢 — **hekim onayı bekliyor** |
| Uygulama ikonu (1024×1024, alfasız) | 🟢 |
| Sürüm 1.0 / build 1 | 🟢 |
| Gizlilik & Şartlar sayfaları | 🟢 (yayın için GitHub Pages açılmalı → §4) |
| Apple Developer üyeliği | 🟡 (var) |
| App Store Connect kaydı + abonelikler | 🟡 → §2, §3 |
| Ekran görüntüleri | 🟡 → §5 |

---

## 1. Xcode imzalama (ilk adım)

1. `Nefes/Nefes.xcodeproj`'i Xcode'da aç.
2. **Nefes target → Signing & Capabilities** sekmesi.
3. **Team**: kendi Apple Developer takımını seç (otomatik imzalama açık kalsın).
4. Bundle Identifier: `com.nefes.app` (gerekirse App Store Connect'te bu ID müsait olmalı; değilse benzersiz bir ID seç ve hem burada hem `.storekit`/StoreManager'da güncelle).
5. Capability eklemeye **gerek yok**: In-App Purchase entitlement gerektirmez; yalnızca yerel bildirim kullanılıyor (push yok).

---

## 2. App Store Connect — uygulama kaydı 🟡

App Store Connect → **My Apps → +** → New App

| Alan | Değer |
|---|---|
| Platform | iOS |
| Name | **Nefes: Sigara Bırakma** (30 karakter sınırı; bkz. §6 alternatifler) |
| Primary Language | Turkish (Türkçe) |
| Bundle ID | `com.nefes.app` |
| SKU | `nefes-ios-001` (serbest, benzersiz) |
| User Access | Full |

- **Primary Category:** Health & Fitness
- **Secondary Category:** Medical (opsiyonel)
- **Content Rights:** Üçüncü taraf içerik yok.

---

## 3. Abonelikler (In-App Purchases) 🟡

App Store Connect → uygulama → **Subscriptions** → yeni **Subscription Group**.

**Group:** `Nefes Premium` (referans ad)

İki ürün — **Product ID'ler kodla birebir aynı olmalı** (`StoreManager.swift` ve `Nefes.storekit`):

| Ürün | Product ID | Süre | Fiyat (öneri) | Deneme |
|---|---|---|---|---|
| Yıllık Premium | `com.nefes.app.premium.yearly` | 1 yıl | ~699,99 ₺ | 3 gün ücretsiz |
| Aylık Premium | `com.nefes.app.premium.monthly` | 1 ay | ~149,99 ₺ | yok |

Her ürün için Türkçe yerelleştirme (localizations):
- **Yıllık** — Görünen ad: `Yıllık Premium` · Açıklama: `Tüm program, Craving SOS, tetikleyici yönetimi ve tam iyileşme takvimi`
- **Aylık** — Görünen ad: `Aylık Premium` · Açıklama: `Aylık Nefes Premium`

Yıllık ürüne **Introductory Offer** ekle: 3 gün, ücretsiz (free), yeni aboneler.

> Not: Abonelikler "Ready to Submit" durumuna gelmeli ve ilk sürümle birlikte incelemeye gönderilmeli; yoksa uygulama reddedilebilir. Banka/vergi/anlaşma (Agreements, Tax, Banking) bilgilerini **Paid Apps** sözleşmesiyle tamamla — aksi halde IAP görünmez.

---

## 4. Gizlilik & Şartlar sayfalarını yayınla 🟡

Sayfalar repoda `docs/` klasöründe hazır. GitHub Pages'i aç:

1. GitHub → `Kubudak90/Stop-smoking` → **Settings → Pages**.
2. **Source:** Deploy from a branch → Branch: `main`, Folder: `/docs` → Save.
3. Birkaç dakika sonra şu adresler canlı olur:
   - Gizlilik: `https://kubudak90.github.io/Stop-smoking/gizlilik.html`
   - Şartlar: `https://kubudak90.github.io/Stop-smoking/sartlar.html`

Uygulama içindeki linkler zaten bu adreslere işaret ediyor (OnboardingView.swift). App Store Connect → App Privacy → **Privacy Policy URL** alanına gizlilik adresini gir.

⚠️ Sayfalarda doldurman gereken yer tutucular: `[VERİ SORUMLUSU ADI]`, `[E-POSTA]`, `[GÜNCELLE — tarih]`. Kendi domainin (nefes.app) hazır olduğunda URL'leri onunla değiştir.

---

## 5. Ekran görüntüleri 🟡 (Claude yardımcı olabilir)

Gerekli: **6.7" (iPhone 15/16 Pro Max)** zorunlu; 6.9" önerilir. En az 3, en fazla 10 görsel.

Simülatörden çekmek için (Claude bunu otomatikleştirebilir):
```
xcrun simctl boot "iPhone 17 Pro Max"
xcrun simctl install booted <Nefes.app yolu>
xcrun simctl launch booted com.nefes.app
xcrun simctl io booted screenshot ~/Desktop/nefes-01.png
```
Önerilen kareler: ① canlı sayaç, ② iyileşme takvimi, ③ Craving SOS nefes egzersizi, ④ kayma kaydı (azarlamayan), ⑤ paywall (para karşılaştırması).

---

## 6. ASO / Mağaza metni (Türkçe)

**App Name (30 char) — adaylar:**
- `Nefes: Sigara Bırakma` (21)
- `Nefes — Sigarayı Bırak` (22)

**Subtitle (30 char):**
- `Bırak, say, nefes al` (20)
- `Hekim temelli bırakma koçu` (26)

**Promotional Text (170 char):**
> Bıraktığın günden bugüne: nefesin, paran, ömrün. Bir aile hekimi tarafından tasarlanan, reklamsız, tıbbi temelli sigara bırakma koçun. Kayma seni geri atmaz.

**Keywords (100 char, virgülle, boşluksuz):**
```
sigara,bırakma,sigarayı bırak,bırakma sayacı,nikotin,nefes,sağlık,koç,duman,içme,tütün,bağımlılık,ALO 171
```

**Description:**
```
Nefes, sigarayı bırakma yolculuğunda yanında olan, bir aile hekimi tarafından
tasarlanmış premium bir destek aracıdır. Reklam yok, suçlama yok — yalnızca
seni ayakta tutan, tıbbi temelli bir koç.

BIRAKTIĞIN ANDAN İTİBAREN
• Canlı sayaç: geçen süre, içilmeyen sigara, biriken para, kazanılan zaman
• Her şey somut ve sürekli büyüyor

İYİLEŞME TAKVİMİ
• 20 dakikadan 10 yıla, vücudunda olan bitenler
• Her kilometre taşı bildirimle kutlanır

KRİZ ANI (CRAVING SOS)
• Tek dokunuşla nefes egzersizi
• "Bu his birkaç dakikada geçer" — neden bıraktığını hatırlatır

KAYMA SENİ GERİ ATMAZ
• Tek sigara tüm ilerlemeni silmez
• Kaymayı suçlama değil, öğrenme olarak ele alırız

PROFESYONEL DESTEĞE KÖPRÜ
• ALO 171 ve sigara bırakma poliklinikleri yönlendirmesi
• Dengeli NRT (nikotin replasman) bilgisi

GİZLİLİK ÖNCE
• Verilerin yalnızca cihazında, sunucu yok, reklam yok (KVKK)

Nefes tedavi yerine geçmez; sürece eşlik eder ve seni profesyonele yönlendirir.

Premium (Craving SOS, tam program, detaylı istatistik) yıllık veya aylık
abonelikle açılır; 3 gün ücretsiz deneme. Abonelik Apple Kimliğinden tahsil
edilir ve dönem bitiminden 24 saat önce iptal edilmezse otomatik yenilenir.
Yönetim: Ayarlar → Abonelikler.
```

**What's New (1.0):**
```
İlk sürüm. Bıraktığın günden bugüne: nefesin, paran, ömrün.
```

---

## 7. App Privacy (gizlilik etiketi) 🟡

App Store Connect → App Privacy:
- **Data Collection: "Data Not Collected"** (hiçbir veri toplanmıyor — her şey cihazda).
- Tracking: Hayır.
- Privacy Policy URL: §4'teki gizlilik adresi.

> `PrivacyInfo.xcprivacy` zaten bunu yansıtıyor: izleme yok, toplanan veri tipi yok, yalnızca UserDefaults (CA92.1) erişimi.

---

## 8. Yaş sınıfı (Age Rating) 🟡

Anketi doldur. Beklenen sonuç: **17+** veya **12+** — "Madde kullanımı/tütün referansı" sorusuna dürüst yanıt ver (içerik tütün bırakmayı konu alır). Apple'ın sağlık/tütün kategorisi için 17+ çıkması olağandır; sorun değildir.

---

## 9. İncelemeye gönderme 🟡

1. Xcode → **Product → Archive** (hedef: Any iOS Device / generic).
2. Organizer → **Distribute App → App Store Connect → Upload**.
3. ASC → uygulama sürümü → build'i seç, metinleri/görselleri ekle, abonelikleri ekle.
4. **Review Notes**: incelemeciye "tıbbi içerik bir aile hekimi tarafından yazılmıştır; tedavi iddiası yoktur; ALO 171'e yönlendirir" notunu ekle. Gerekirse premium'u görmeleri için demo not bırak (uygulama StoreKit deneme ile test edilebilir).
5. **Submit for Review.**

---

## 10. Yayından önce senin kontrol listen

- [ ] Tıbbi içeriği hekim olarak onayla (`SmokingContent.swift`).
- [ ] `docs/` sayfalarındaki `[VERİ SORUMLUSU]`, `[E-POSTA]`, tarih yer tutucularını doldur.
- [ ] GitHub Pages'i aç ve iki URL'in açıldığını tarayıcıda doğrula.
- [ ] Xcode'da Team seç, gerçek cihazda bir kez çalıştır (bildirim izni + paywall akışı).
- [ ] App Store Connect'te abonelikleri ve Paid Apps sözleşmesini tamamla.
- [ ] Ekran görüntülerini ekle.
```
