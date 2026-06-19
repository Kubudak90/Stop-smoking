import SwiftUI
import SwiftData

/// Onboarding akışı. Spec §10:
/// neden bırakıyorsun → ne kadar/hangi marka → bırakma anı/tarihi → bildirim izni.
/// Değer-sonra-paywall (Spec §11): paywall onboarding'de DEĞİL, sayaç değeri görüldükten
/// sonra gösterilir.
struct OnboardingView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var prices: PriceCatalog
    @EnvironmentObject private var notifications: NotificationManager
    @EnvironmentObject private var store: StoreManager

    @State private var step = 0

    // Toplanan veriler
    @State private var selectedReasons: Set<String> = []
    @State private var customReason = ""
    @State private var unitsPerDay = 20
    @State private var brand = "Popüler marka"
    @State private var pricePerPack = 115.0
    @State private var quitDate = Date.now
    @State private var quitIsNow = true
    @State private var consentAccepted = false

    private let totalSteps = 5

    var body: some View {
        VStack(spacing: 0) {
            ProgressView(value: Double(step + 1), total: Double(totalSteps))
                .tint(Theme.primary)
                .padding()

            TabView(selection: Binding(
                get: { step },
                // Rıza verilmeden swipe ile rıza adımını (step 0) atlamayı engelle (KVKK gating).
                // Buton akışı zaten canProceed ile kilitli; bu, kaydırma jestini de kapatır.
                set: { newValue in
                    if newValue > 0, !consentAccepted { step = 0 } else { step = newValue }
                }
            )) {
                consentStep.tag(0)
                reasonsStep.tag(1)
                consumptionStep.tag(2)
                quitMomentStep.tag(3)
                notificationStep.tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: step)

            controls
        }
        .background(Theme.background)
        .onAppear {
            if let price = prices.price(forBrand: brand) { pricePerPack = price }
        }
    }

    // MARK: - 0. KVKK açık rıza (Spec §17) — hassas sağlık verisi toplanmadan önce

    /// Gizlilik politikası ve kullanım şartları (GitHub Pages — repo `docs/` klasörü).
    /// Kendi domainin (ör. nefes.app) hazır olduğunda bu iki URL'i onunla değiştir.
    static let privacyPolicyURL = URL(string: "https://kubudak90.github.io/Stop-smoking/gizlilik.html")!
    static let termsOfUseURL = URL(string: "https://kubudak90.github.io/Stop-smoking/sartlar.html")!

    private var consentStep: some View {
        OnboardingScaffold(
            title: "Gizliliğin bizde emanet",
            subtitle: "Başlamadan önce kısa ama önemli bir not — bu bir sağlık aracı."
        ) {
            VStack(alignment: .leading, spacing: 16) {
                ConsentBullet(icon: "iphone", text: "Verilerin (sigara kullanımın, kaymaların, ilerlemen) yalnızca bu cihazda saklanır.")
                ConsentBullet(icon: "lock.shield.fill", text: "Hiçbir sağlık verin sunucuya gönderilmez. Reklam ve üçüncü taraf takip yok.")
                ConsentBullet(icon: "trash.fill", text: "İstediğin an Ayarlar'dan tüm verini kalıcı olarak silebilirsin.")

                Toggle(isOn: $consentAccepted) {
                    Text("Sağlık verimin yukarıdaki şekilde, yalnızca cihazımda işlenmesine açık rıza veriyorum (KVKK).")
                        .font(.footnote)
                        .foregroundStyle(Theme.textPrimary)
                }
                .tint(Theme.primary)
                .padding(.top, 4)

                HStack(spacing: 16) {
                    Link("Gizlilik Politikası", destination: Self.privacyPolicyURL)
                    Link("Kullanım Şartları", destination: Self.termsOfUseURL)
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(Theme.primary)
            }
        }
    }

    // MARK: - 1. Neden bırakıyorsun (motivasyon kaydı)

    private var reasonsStep: some View {
        OnboardingScaffold(
            title: "Neden bırakıyorsun?",
            subtitle: "Zayıf bir anında bunları sana hatırlatacağız. İstediğin kadar seç."
        ) {
            let options = [
                "Sağlığım için", "Çocuklarım / ailem için", "Param için",
                "Daha iyi nefes almak", "Kontrolü geri almak", "Kötü kokmamak",
                "Birine söz verdim", "Spor / kondisyon"
            ]
            FlowChips(options: options, selection: $selectedReasons)

            TextField("Kendi nedenin (opsiyonel)", text: $customReason)
                .textFieldStyle(.roundedBorder)
                .padding(.top, 8)
        }
    }

    // MARK: - 2. Ne kadar / hangi marka (maliyet hesabı)

    private var consumptionStep: some View {
        OnboardingScaffold(
            title: "Tüketimin",
            subtitle: "Biriken paranı ve içilmeyen sigara sayını hesaplamak için."
        ) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Günde kaç sigara?").font(.subheadline.weight(.medium))
                    Stepper(value: $unitsPerDay, in: 1...80) {
                        Text("\(unitsPerDay) sigara / gün")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Theme.primaryDark)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Markan / paket fiyatın").font(.subheadline.weight(.medium))
                    Picker("Marka", selection: $brand) {
                        ForEach(prices.data.entries) { entry in
                            Text("\(entry.brand) — \(AppFormatters.money(entry.pricePerPack))")
                                .tag(entry.brand)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: brand) { _, newValue in
                        if let price = prices.price(forBrand: newValue) { pricePerPack = price }
                    }

                    HStack {
                        Text("Paket fiyatı")
                        Spacer()
                        TextField("Fiyat", value: $pricePerPack, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 90)
                        Text("₺")
                    }
                    .font(.subheadline)
                }

                // Anlık "para psikolojisi" önizlemesi. Spec §7.
                // Paket başına birim sayısı katalogdan gelir (sabit 20 değil).
                let unitsPerPack = max(1, prices.data.unitsPerPack)
                let yearly = pricePerPack / Double(unitsPerPack) * Double(unitsPerDay) * 365
                Text("Yıllık ≈ \(AppFormatters.money(yearly)) duman olup gidiyor.")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Theme.accent)
                    .padding(.top, 4)
            }
        }
    }

    // MARK: - 3. Bırakma anı / tarihi

    private var quitMomentStep: some View {
        OnboardingScaffold(
            title: "Ne zaman bıraktın?",
            subtitle: "Sayaç bu andan itibaren işlemeye başlayacak. Şimdi mi, yoksa daha önce mi bıraktın?"
        ) {
            VStack(spacing: 16) {
                Button {
                    quitDate = .now
                    quitIsNow = true
                } label: {
                    Label("Şimdi bırakıyorum", systemImage: "flag.checkered")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(quitIsNow ? Theme.primary.opacity(0.15) : Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.primary.opacity(quitIsNow ? 0.5 : 0)))
                }

                DatePicker(
                    "Bırakma anı",
                    selection: Binding(get: { quitDate }, set: { quitDate = $0; quitIsNow = false }),
                    in: ...Date.now,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
            }
        }
    }

    // MARK: - 4. Bildirim izni

    private var notificationStep: some View {
        OnboardingScaffold(
            title: "Yanında olabilmem için",
            subtitle: "İlk 72 saat en zor dönem. Kısa, destekleyici hatırlatmalarla yanında olurum — asla rahatsız etmeden."
        ) {
            VStack(spacing: 16) {
                FeatureRow(icon: "heart.fill", text: "Kilometre taşlarını kutlarım")
                FeatureRow(icon: "hand.raised.fill", text: "Zor anlarda nazik destek")
                FeatureRow(icon: "bell.slash.fill", text: "Spam yok, suçlama yok")

                Button {
                    Task { await notifications.requestAuthorization() }
                } label: {
                    Text("Bildirimlere izin ver")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.primary.opacity(0.12))
                        .foregroundStyle(Theme.primaryDark)
                        .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - Controls

    private var controls: some View {
        HStack {
            if step > 0 {
                Button("Geri") { withAnimation { step -= 1 } }
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            PrimaryButton(title: step == totalSteps - 1 ? "Başla" : "Devam") {
                if step == totalSteps - 1 {
                    finish()
                } else {
                    withAnimation { step += 1 }
                }
            }
            .frame(width: 160)
            .disabled(!canProceed)
            .opacity(canProceed ? 1 : 0.5)
        }
        .padding()
    }

    /// Rıza adımında (step 0) açık rıza verilmeden ilerlenemez (KVKK §17).
    private var canProceed: Bool {
        step == 0 ? consentAccepted : true
    }

    private func finish() {
        var reasons = Array(selectedReasons)
        let trimmed = customReason.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { reasons.append(trimmed) }

        // Fiyat doğrulama: 0/negatif/boş fiyat → "biriken para" kalıcı 0 olurdu.
        // Geçersizse katalog fiyatına, o da yoksa makul bir varsayılana düş.
        let validatedPrice: Double = {
            if pricePerPack.isFinite, pricePerPack > 0 { return pricePerPack }
            return prices.price(forBrand: brand) ?? 115
        }()
        let unitsPerPack = max(1, prices.data.unitsPerPack)

        let profile = UserProfile(
            habitType: .smoking,
            reasons: reasons,
            unitsPerDay: unitsPerDay,
            pricePerPack: validatedPrice,
            unitsPerPack: unitsPerPack,
            brand: brand,
            quitDate: quitDate,
            kvkkConsentAt: .now   // rıza adımı geçilmeden buraya gelinemez (canProceed)
        )
        context.insert(profile)
        do {
            try context.save()
        } catch {
            print("[Nefes] Onboarding profili kaydedilemedi: \(error)")
        }

        // İzni iste, SONUCU BEKLE, ardından bildirimleri kur. (Eski hali fire-and-forget'ti:
        // izin verilse bile reschedule yarış nedeniyle çoğu kez hiçbir şey kuramıyordu.)
        Task {
            _ = await notifications.requestAuthorization()
            await notifications.reschedule(for: profile, isPremium: store.isPremium)
        }
    }
}

// MARK: - Yardımcı parçalar

private struct OnboardingScaffold<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundStyle(Theme.textPrimary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                content
                    .padding(.top, 12)
            }
            .padding(24)
        }
    }
}

private struct FlowChips: View {
    let options: [String]
    @Binding var selection: Set<String>

    var body: some View {
        FlexibleWrap(options, spacing: 10) { option in
            let isOn = selection.contains(option)
            Button {
                if isOn { selection.remove(option) } else { selection.insert(option) }
            } label: {
                Text(option)
                    .font(.subheadline)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(isOn ? Theme.primary : Theme.surface)
                    .foregroundStyle(isOn ? .white : Theme.textPrimary)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Theme.primary.opacity(isOn ? 0 : 0.3)))
            }
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Theme.primary)
                .frame(width: 28)
            Text(text).font(.subheadline)
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

private struct ConsentBullet: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Theme.primary)
                .frame(width: 28)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Theme.textPrimary)
            Spacer(minLength: 0)
        }
    }
}
