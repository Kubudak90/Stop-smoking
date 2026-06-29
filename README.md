# Nefes — Sigarayı Bırakma & Alışkanlık Yenme Uygulaması

> *Bıraktığın günden bugüne: nefesin, paran, ömrün.*

Bir aile hekimi tarafından, Türkiye için tasarlanmış; tıbbi olarak doğru, reklamsız,
premium bir sigara bırakma aracı. **Wedge-to-platform**: motor genel bir "alışkanlık
yenme" platformudur, pazara tek keskin uçtan (sigara) girer.

Bu depo, [`sigara-birakma-mvp-spec-v0_1.md`](./sigara-birakma-mvp-spec-v0_1.md)
spesifikasyonunun **MVP iOS uygulaması** olarak hayata geçirilmiş halidir.

## Teknoloji

- **SwiftUI** (iOS 17+) — `Nefes/` altında
- **SwiftData** — offline-first kalıcı depo (tüm veri cihazda; KVKK avantajı)
- **StoreKit 2** — freemium + yıllık abonelik
- **UserNotifications** — yerel, "sessiz koç" bildirimleri
- **Swift Charts** — istatistik grafikleri
- Backend **yok** (MVP tamamen offline). Senkron/topluluk Faz 2 / P1.

## Açmak ve çalıştırmak

```bash
open Nefes/Nefes.xcodeproj
```

1. Xcode 16+ ile `Nefes.xcodeproj`'i aç.
2. Bir iOS 17+ simülatörü seç ve **⌘R**.
3. Abonelik akışını test etmek için şema zaten **`Nefes.storekit`** yapılandırmasına
   bağlıdır (StoreKit Configuration). Gerçek satın alma olmadan paywall denenebilir.
4. Geliştirme sırasında premium içeriği görmek için: **Ayarlar → "DEBUG: Premium'u aç"**
   (yalnızca Debug derlemelerinde görünür).

> Not: Proje, Xcode 16 dosya-sistemi senkronize gruplarını (`objectVersion = 77`)
> kullanır; `Nefes/` klasörüne eklenen yeni `.swift` dosyaları otomatik derlemeye dahil
> olur, `.pbxproj` elle düzenlenmez.

## Mimari (wedge-to-platform)

```
Nefes/Nefes/
├── NefesApp.swift            # @main, ModelContainer, environment enjeksiyonu
├── Models/                   # HabitConfig, HealthMilestone, TriggerCategory
│   ├── UserProfile.swift     # @Model (SwiftData) — bırakma profili
│   └── SlipRecord.swift      # @Model — kayma kaydı (slip ≠ reset)
├── Config/
│   └── SmokingHabit.swift    # Sigaranın config'i: iyileşme takvimi + tetikleyiciler
├── Services/
│   ├── QuitStatsCalculator   # Sayaç matematiği (kayma sıfırlamaz)
│   ├── NotificationManager   # İlk 72 saat desteği + kilometre taşı kutlamaları
│   ├── StoreManager          # StoreKit 2 entitlement
│   ├── PriceCatalog          # Uzaktan güncellenebilir fiyat tablosu (offline-first)
│   └── Formatters            # Türkçe biçimlendirme
├── State/
│   ├── AppEnvironment.swift  # Servisleri toplar
│   └── Theme.swift           # Marka kimliği
└── Views/
    ├── Onboarding/           # neden → tüketim → bırakma anı → bildirim
    ├── Counter/              # ana ekran (canlı sayaç)
    ├── Recovery/             # iyileşme takvimi
    ├── CravingSOS/           # kriz anı: nefes egzersizi + hatırlatıcı
    ├── Slip/                 # azarlamayan kayma kaydı
    ├── Stats/                # seri, tetikleyici örüntüleri (çoğu premium)
    ├── Paywall/              # değer-sonra-paywall, para karşılaştırması
    └── Settings/             # marka/fiyat, ALO 171, veri silme (KVKK)
```

**Yeni alışkanlık eklemek** (alkol/vaping/şeker) = yeni bir `HabitConfig` + içerik.
Motor kodu değişmez (Spec §9).

## Spec → kod izlenebilirliği

| Spec direği | Nerede |
|---|---|
| §4 Sayaç | `QuitStatsCalculator`, `CounterView` |
| §5 Nüks (slip ≠ reset) | `SlipRecord`, `SlipLogView`, `QuitStatsCalculator` |
| §6 Tıbbi içerik / iyileşme | `SmokingHabit.milestones`, `RecoveryTimelineView`, `MedicalDisclaimer`, `AssistanceFooter` (ALO 171) |
| §8 Gelir modeli | `StoreManager`, `PaywallView`, `Nefes.storekit` |
| §11 Paywall zamanlaması | `CounterView.maybeShowPostOnboardingPaywall`, `CravingSOSView` premium tetikleyici |
| §12 Retention motoru | `NotificationManager` (72 saat + kilometre taşı + geri dönüş kancası) |
| §17 KVKK | offline-first SwiftData, `SettingsView` veri silme |

## Tıbbi sorumluluk

İçerik bilgilendirir, "iyileştirir / garanti" dili taşımaz. Uygulama tedavi yerine
geçmez; ALO 171 ve sigara bırakma polikliniklerine **köprü** olur.

## Yol haritası (sonraki)

- StoreKit ürün ID'lerini App Store Connect'te oluşturmak (`com.nefesapp.ios.premium.*`)
- Uygulama ikonu ve App Store görselleri (ASO)
- Paywall A/B varyantları (altyapı `PaywallView.Context` ile hazır)
- Faz 2: ikinci alışkanlık config'i, opsiyonel Supabase senkronu, topluluk
