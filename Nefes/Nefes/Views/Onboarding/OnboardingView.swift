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

    @State private var step = 0

    // Toplanan veriler
    @State private var selectedReasons: Set<String> = []
    @State private var customReason = ""
    @State private var unitsPerDay = 20
    @State private var brand = "Popüler marka"
    @State private var pricePerPack = 115.0
    @State private var quitDate = Date.now

    private let totalSteps = 4

    var body: some View {
        VStack(spacing: 0) {
            ProgressView(value: Double(step + 1), total: Double(totalSteps))
                .tint(Theme.primary)
                .padding()

            TabView(selection: $step) {
                reasonsStep.tag(0)
                consumptionStep.tag(1)
                quitMomentStep.tag(2)
                notificationStep.tag(3)
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
                let yearly = pricePerPack / 20 * Double(unitsPerDay) * 365
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
                } label: {
                    Label("Şimdi bırakıyorum", systemImage: "flag.checkered")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(abs(quitDate.timeIntervalSinceNow) < 60 ? Theme.primary.opacity(0.15) : Theme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                DatePicker(
                    "Bırakma anı",
                    selection: $quitDate,
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
        }
        .padding()
    }

    private func finish() {
        var reasons = Array(selectedReasons)
        let trimmed = customReason.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { reasons.append(trimmed) }

        let profile = UserProfile(
            habitType: .smoking,
            reasons: reasons,
            unitsPerDay: unitsPerDay,
            pricePerPack: pricePerPack,
            unitsPerPack: 20,
            brand: brand,
            quitDate: quitDate
        )
        context.insert(profile)
        try? context.save()

        Task { await notifications.reschedule(for: profile) }
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
