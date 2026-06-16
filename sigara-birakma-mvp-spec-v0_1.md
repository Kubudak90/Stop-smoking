# Nefes* — Sigarayı Bırakma & Alışkanlık Yenme Uygulaması

**MVP Ürün ve Teknik Spesifikasyonu — v0.1 (Taslak)**
*Çalışma adı. Adaylar: Nefes, Bırak, Temiz, Gün(ler), Sıfır. ASO ve tescil taraması Faz 0’da.

> **Strateji: Wedge-to-platform.** Mimari genel “alışkanlık yenme” platformu olarak kurulur; pazara **tek keskin uçtan (sigara)** girilir. App Store’da “sigara bırakma” diye bulunuruz, içeride motor genel çalışır. Alkol/vaping/şeker sonraki alışkanlıklar olarak config ile eklenir.
> **Konumlandırma:** Reklam dolu bedava sayaç uygulamaları var; *bir hekim tarafından tasarlanmış, tıbbi olarak doğru, kültürel olarak Türkiye’ye ait* premium bir bırakma aracı yok.
> **Tek cümle:** *Bıraktığın günden bugüne: nefesin, paran, ömrün.*

-----

## 1. Problem Tanımı

Türkiye dünyanın en yüksek sigara içme oranlarından birine sahip; devasa bir bırakmak isteyen kitle var. Mevcut Türkçe uygulamalar büyük ölçüde reklam dolu, basit gün sayan, motivasyonu ayakta tutamayan araçlar. İyi tasarlanmış, tıbbi temelli, kültürel olarak doğru konuşan premium bir ürün yok. Sigara fiyatları sürekli arttığı için (Haziran 2026: popüler markalar 105-120 TL, premium 285 TL’ye kadar) “biriken para” argümanı her geçen ay güçleniyor — günde bir paket ≈ yılda ~40.000 TL.

## 2. Neden Bu Ürün, Neden Sen

**Kurucu avantajı (asıl hendek):** Kurucu aile hekimi. Bu üç şeyi getiriyor: (1) tıbbi içerik güvenilirliği — “bir hekim tasarladı” App Store ve pazarlama kancası, (2) içeriği kendisi yazabilir — yoksunluk zaman çizelgesi, iyileşme takvimi, NRT (nikotin replasman tedavisi) bilgisi dışarıdan satın alınmaz, (3) ALO 171 Sigara Bırakma Danışma Hattı ve sigara bırakma poliklinikleriyle doğru, sorumlu entegrasyon. Hiçbir Türkçe rakipte bu yok.

**Round-up’a kıyasla neden çekici:** Partner yok, açık bankacılık yok, finansal regülasyon yok, para akışı/mutabakat/ledger yok. Tek başına 2-4 haftada App Store’da canlı ürün. Asıl savaş teknolojide değil — **retention, relapse yönetimi ve ASO’da.**

## 3. MVP Tezi (kanıtlanacak)

İlk 1.000 organik indirme ile şunu kanıtlamak: kullanıcı kurulumdan sonra **3. günü geçer** (retention uçurumunu aşar), bırakma takvimini değer olarak görür, ve **ücretsiz→trial→ödeme** hunisinin paywall’u install’ı öldürmeden çalışır. Bu kategoride ürün yapmak kolay, *insanı tutmak* zordur — tez budur.

## 4. Ürünün Üç Direği

1. **Sayaç (Counter):** Bıraktığın andan itibaren geçen süre, içilmeyen sigara, biriken para, kazanılan ömür. Gerçek zamanlı, somut, sürekli büyüyen.
1. **Program (Journey):** Yapılandırılmış bırakma yolculuğu — hazırlık, ilk 72 saat (en kritik), 2 hafta, 1 ay, 3 ay kilometre taşları. Hekim temelli içerik.
1. **Motivasyon (Engine):** Kullanıcıyı zayıf anında ayakta tutan mekanik — **kriz anı butonu (Craving SOS)**, nefes egzersizi, “neden bırakıyorum” hatırlatıcısı, ilerleme görselleştirme.

## 5. Asıl Farklılaştırıcı: Relapse’i (Nüks) Doğru Yönetmek

Bu kategorinin mezarlığı buradadır. Çoğu uygulama bir kez içince sayacı **sıfırlar** → kullanıcı yıkılır, suçluluk duyar, uygulamayı siler. Bizim mekanik:

- **“Kayma” (slip) ≠ “Sıfırlama”:** Tek sigara içmek tüm ilerlemeyi silmez. Kullanıcı kaymayı işaretler, sistem bunu bir **veri ve öğrenme** olarak ele alır, ceza olarak değil.
- **Tetikleyici öğrenme:** “Ne zaman, nerede, hangi duyguyla?” — kayma anını kaydetmek, gelecekteki tetikleyici yönetiminin yakıtı olur.
- **Azarlamayan dil:** *“Bir kez kaydın, yolculuk bitmedi. Çoğu insan birkaç denemede bırakır — bu da o denemelerden biri.”* Suçluluk değil, devamlılık.
- **Streak-freeze / esnek seri:** Sert “0’a döndün” yerine seriyi koruma/dondurma seçeneği.

Bu felsefe ürünün her yerine işler: **destekleyen koç, yargılayan bekçi değil.** (Round-up’taki “sessiz muhasebeci” ilkesinin kuzeni.)

## 6. Tıbbi İçerik Omurgası (hekim tarafından, sorumlu)

- **İyileşme zaman çizelgesi (gamified):** 20 dakika (kalp atışı/tansiyon normale döner) → 8-12 saat (kandaki karbonmonoksit düşer) → 24 saat → 48-72 saat (nikotin vücuttan çıkar, koku/tat döner) → 2 hafta-3 ay (dolaşım, akciğer) → 1 yıl → 5-10 yıl (risk azalması). Her kilometre taşı kullanıcıya bildirimle kutlanır.
- **Yoksunluk rehberi:** İlk 72 saatte ne hissedileceği, ne kadar süreceği, baş etme yöntemleri.
- **NRT ve profesyonel destek bilgisi:** Nikotin bandı/sakızı hakkında dengeli bilgi; **ALO 171** ve sigara bırakma polikliniklerine yönlendirme. Uygulama tedavi *yerine* geçmez, ona *köprü* olur — bu hem etik hem yasal olarak kritik.
- **Tıbbi sorumluluk sınırı:** Uygulama tanı/tedavi iddiası taşımaz; “iyileştirir/garanti” dili yasak (App Store sağlık iddiası incelemesi ve hekimlik etiği). İçerik bilgilendirir, profesyonele yönlendirir.

## 7. Türkiye’ye Özel Kancalar

- **Para psikolojisi:** Sigara fiyatı sürekli arttığı için “biriken para” hızla büyür. Paywall kancası: *“Bıraktığından beri 4.200 TL biriktirdin — bu uygulama kendini 3 günde amorti etti.”* Biriken parayı somut hedefe bağla (“bu parayla ne alırdın?”).
- **Aile/duygusal çerçeve:** Çocuklar, eş, “onlar için.” Kurucunun kendi hikayesi (iki kızı) otantik pazarlama anlatısı.
- **Ramazan kancası:** Milyonlarca kişi zaten gündüz içmiyor — yılın doğal “bırakma momenti.” Ramazan’a özel onboarding kampanyası ciddi bir organik dalga yaratabilir.
- **Sağlık baskısı:** Türkiye’de sigaraya bağlı hastalık yükü yüksek; hekim-temelli güvenilirlik burada satar.

## 8. Gelir Modeli

**Freemium + yıllık abonelik (StoreKit).**

- **Ücretsiz:** sayaç, temel seri, biriken para, iyileşme takviminin ilk birkaç adımı.
- **Premium:** tam program, Craving SOS aracı, tetikleyici yönetimi, tam iyileşme takvimi, detaylı istatistik/grafik, kişiselleştirilmiş bildirimler, (P1) topluluk.
- **Fiyat çapası:** Yıllık ~600-900 TL bandı. Sigaranın yıllık ~40.000 TL maliyeti karşısında bu rakam gülünç derecede kolay satılır — paywall’da bu karşılaştırma açıkça gösterilir. Aylık seçenek pahalı tutulur ki yıllık cazip olsun (davranışsal çapa).
- **Trial:** 3-7 gün ücretsiz deneme; ama paywall zamanlaması kritik (Bölüm 11).
- **Bilinçli yok:** Reklam yok. Reklam, premium konumlandırmayı ve “sağlık uygulaması” güvenini öldürür; rakiplerden ayrışmanın bir parçası reklamsızlık.

## 9. Mimari (wedge-to-platform)

```
[iOS — SwiftUI, offline-first]
   ├── StoreKit 2 (abonelik)
   ├── Yerel veri: SwiftData / Core Data (sayaç, kayıtlar, ilerleme)
   ├── Bildirim: yerel notifications (kilometre taşı, kriz desteği)
   └── (opsiyonel) Supabase: hesap senkronu + topluluk (P1)
```

**Wedge-to-platform veri modeli:** `habit_type` (smoking/alcohol/vaping/sugar…) config-driven. Smoking sadece ilk konfigürasyon: `unit` (sigara), `unit_cost` (paket fiyatı/20), `health_milestones` (sigaraya özel iyileşme takvimi), `trigger_categories`. Yeni alışkanlık = yeni config + içerik, kod değişmez. Bu, kullanıcının istediği “genel platform”u onurlandırır ama odaklı çıkarız.

**MVP backendless olabilir:** İlk sürüm tamamen offline + StoreKit ile çıkabilir; backend yalnızca topluluk/senkron için (P1). Bu, lansmanı daha da hızlandırır ve sunucu maliyeti/karmaşası sıfırlanır.

**Fiyat güncelleme:** `unit_cost` kullanıcı tarafından markasına göre ayarlanır; sigara fiyatları sık değiştiği için uzaktan güncellenebilir bir varsayılan fiyat tablosu (basit JSON, uygulama açılışında çekilir) tutulur.

## 10. Ekranlar (MVP)

1. **Onboarding:** neden bırakıyorsun (motivasyon kaydı) → ne kadar/hangi marka içiyordun (maliyet hesabı) → bırakma anı/tarihi → bildirim izni
1. **Ana ekran (sayaç):** geçen süre, içilmeyen sigara, biriken para, kazanılan ömür, mevcut kilometre taşı
1. **İyileşme takvimi:** zaman çizelgesi, geçilen ve sıradaki sağlık kilometre taşları
1. **Craving SOS:** kriz anı butonu → nefes egzersizi + “neden bırakıyorum” hatırlatıcısı + “bu his 3-5 dakikada geçer” + dikkat dağıtma
1. **Kayma kaydı:** suçlamayan akış, tetikleyici sorusu
1. **İstatistik:** seri, tetikleyici örüntüleri, ilerleme grafiği (çoğu premium)
1. **Paywall:** para karşılaştırması + sağlık vaadi (Bölüm 11 zamanlamasıyla)
1. **Ayarlar:** marka/fiyat, bırakma tarihi düzenleme, bildirim tercihleri, ALO 171/poliklinik yönlendirmesi, veri silme

## 11. En Kritik Tasarım Kararı: Paywall Zamanlaması

Bu kategorinin gelir-ölüm-kalımı burada. İki yanlış: çok erken (install→açılış öldürür), çok geç (gelir öldürür). MVP yaklaşımı:

- Onboarding’i tamamlat, **değeri göster** (sayaç çalışsın, ilk para birikimi görünsün), sonra paywall.
- Craving SOS gibi en yüksek değerli aracı ilk kriz anında premium tetikleyici yap — kullanıcı ürünü en çok istediği anda dönüşür.
- A/B test altyapısı v1’de basit tutulur ama paywall varyantı denenebilir olmalı.

## 12. Retention Motoru (asıl savaş)

- **İlk 72 saat = ölüm bölgesi.** Yoksunluğun en sert olduğu dönem; uygulama bu dönemde en yoğun destek verir (sık, kısa, destekleyici bildirim + SOS erişimi).
- **Kilometre taşı kutlamaları:** her sağlık/para/seri eşiği bildirimle kutlanır — dopamin döngüsü.
- **Bildirim felsefesi (sessiz koç):** destekleyici, azarlamayan, anksiyete üretmeyen. *“3 gündür temizsin, en zor kısmı geçtin.”* Asla: suçlama, korku pornografisi, agresif hatırlatma.
- **Geri dönüş kancası:** kullanıcı uygulamayı 2 gün açmazsa nazik bir “nasıl gidiyor?” — bir kez, ısrarsız.

## 13. Hedefler ve Metrikler

|Metrik                               |Eşik|Hedef                     |
|-------------------------------------|----|--------------------------|
|D3 retention (3. günü geçen)         |%35 |%50                       |
|D7 retention                         |%25 |%40                       |
|Onboarding tamamlama                 |%60 |%75                       |
|Trial başlatma                       |%20 |%35                       |
|Trial → ödemeli dönüşüm              |%25 |%40                       |
|Craving SOS kullanımı (ilk hafta)    |—   |aktif kullanıcıların %40’ı|
|30 gün sonra hâlâ “temiz” işaretleyen|%20 |%35                       |

**Retention tanımı dikkatli:** Bu üründe “uygulamayı açmak” değil, “kullanıcının bırakmaya devam etmesi” başarıdır. İdeal olarak biri uygulamayı açmadan da sigarasız kalıyorsa bu zafer — ama o veriyi göremeyiz, o yüzden proxy olarak açılış + kilometre taşı + “hâlâ temiz” check-in’i izleriz.

## 14. Hedef Dışı (Non-Goals)

Android (Faz 2) · topluluk/sosyal (P1) · Apple Watch (P1) · alkol/vaping/diğer alışkanlıklar (config hazır ama içerik Faz 2) · giyilebilir/sağlık verisi entegrasyonu · canlı koçluk/insan desteği · backend-zorunlu özellikler (MVP offline).

## 15. Riskler ve Mezarlık (bu kategori nerede ölür)

|Risk                                             |Şiddet    |Olasılık|Önlem                                                               |
|-------------------------------------------------|----------|--------|--------------------------------------------------------------------|
|Retention uçurumu (3 günde silinir)              |Çok yüksek|Yüksek  |İlk 72 saat yoğun destek + SOS + kilometre taşı dopamini            |
|ASO/keşfedilememe (partner yok = organik şart)   |Çok yüksek|Yüksek  |Bölüm 16 ASO stratejisi; hekim-temelli PR; Ramazan dalgası          |
|Paywall dönüşümü düşük                           |Yüksek    |Orta    |Değer-sonra-paywall; para karşılaştırması; SOS tetikleyici          |
|Relapse → churn                                  |Yüksek    |Yüksek  |Bölüm 5 nüks felsefesi                                              |
|Sayaç tek başına ödenmeye değmez algısı          |Yüksek    |Orta    |Program + SOS + tıbbi içerik derinliği                              |
|Apple sağlık iddiası incelemesi                  |Orta      |Orta    |“İyileştirir/garanti” dili yok; bilgilendirme + yönlendirme         |
|Rakip kopyalar (round-up’tan daha kopyalanabilir)|Orta      |Yüksek  |Hekim içeriği + kültürel derinlik + marka + hız; özellik değil bütün|
|Kurucunun zamanı (tek kişi, çok proje)           |Orta      |Orta    |Backendless MVP + dar kapsam                                        |

## 16. Dağıtım: ASO ve İlk 1.000 Kullanıcı

Partner yok demek **organik dağıtım şart** demek. Bu ürünün round-up’tan en büyük farkı: orada savaş partner masasındaydı, burada App Store arama sonuçlarında ve içerik pazarlamasında.

- **ASO:** “sigara bırakma”, “sigarayı bırak”, “bırakma sayacı” gibi yüksek hacimli Türkçe aramalar; başlık/alt başlık/anahtar kelime optimizasyonu; ilk yorumların kalitesi kritik.
- **Hekim-PR avantajı:** “Aile hekimi sigara bırakma uygulaması yaptı” hikayesi basın/sosyal medyada doğal ilgi çeker — para harcamadan erişim.
- **Ramazan zamanlaması:** lansmanı Ramazan öncesine denk getir; doğal bırakma dalgasına bin.
- **İçerik pazarlaması:** kısa video/Instagram (senin egebant pipeline tecrübenle örtüşür) — “bıraktıktan sonra vücudunda olanlar” gibi tıbbi-eğitici içerik organik büyütür.

## 17. KVKK ve Etik

Sağlık-ilişkili veri (sigara kullanımı) hassas veri sınıfında → açık rıza, veri minimizasyonu, mümkünse veriyi cihazda tut (offline-first burada KVKK avantajı). Tıbbi sorumluluk reddi net yazılır. ALO 171/poliklinik yönlendirmesi sorumlu şekilde sunulur. Topluluk (P1) gelirse moderasyon ve mahremiyet ayrı ele alınır.

## 18. Yol Haritası

|Faz          |Süre      |Çıktı                                                                                          |
|-------------|----------|-----------------------------------------------------------------------------------------------|
|0 — Hazırlık |1 hafta   |Marka/ASO taraması, tıbbi içerik taslağı (kurucu yazar), iyileşme takvimi verisi, fiyat tablosu|
|1 — MVP      |2-4 hafta |Offline iOS: sayaç + program + SOS + nüks + paywall + tıbbi içerik. TestFlight                 |
|2 — Lansman  |+1-2 hafta|App Store, ASO, Ramazan kampanyası (zamanlama uygunsa)                                         |
|3 — İterasyon|sürekli   |Paywall A/B, retention optimizasyonu, topluluk (P1), Android keşfi                             |
|4 — Platform |Q+2       |İkinci alışkanlık (alkol/vaping) config + içerik; “alışkanlık platformu”na genişleme           |

## 19. Açık Sorular

- Trial uzunluğu: 3 gün mü 7 gün mü? (dönüşüm vs. değer gösterme dengesi)
- Backendless mi başlanmalı, yoksa hafif Supabase senkronu baştan mı? (cihaz değiştiren kullanıcı verisini kaybeder)
- Tıbbi içeriğin kapsamı ilk sürümde ne kadar derin olmalı (MVP’yi şişirmeden güvenilirlik)?
- Ramazan zamanlaması lansmanı beklememeye değer mi, yoksa hıza mı odaklanılmalı?
- Marka: “sigara” kelimesi isimde olsun mu (ASO avantajı) yoksa platform vizyonu için jenerik mi (Nefes)?