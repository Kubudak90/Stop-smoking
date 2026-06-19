import SwiftUI

/// Program / Journey — Spec §4.2 (ürünün ikinci direği: yapılandırılmış bırakma yolculuğu).
///
/// Hazırlık → ilk 72 saat → 2 hafta → 1 ay → 3 ay aşamaları. Hazırlık ve ilk 72 saat
/// ücretsiz; sonraki aşamalar premium (Spec §8). Ayrıca §6 yoksunluk rehberi + NRT/profesyonel
/// destek bilgisi ve tıbbi sorumluluk reddi burada toplanır.
///
/// İÇERİK NOTU: Aşama/yoksunluk/NRT metinleri `SmokingContent` içinde hekim onayına hazır
/// TASLAK olarak yazılmıştır; yayından önce kurucu (aile hekimi) onayından geçer (Spec §2, §6).
struct JourneyView: View {
    let profile: UserProfile

    @EnvironmentObject private var store: StoreManager
    @State private var showPaywall = false

    private var elapsed: TimeInterval { max(0, Date.now.timeIntervalSince(profile.quitDate)) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    intro
                    ForEach(SmokingContent.journeyStages) { stage in
                        stageCard(stage)
                    }
                    withdrawalSection
                    supportSection
                    MedicalDisclaimer()
                }
                .padding()
            }
            .background(Theme.background)
            .navigationTitle("Program")
            .sheet(isPresented: $showPaywall) {
                PaywallView(context: .postOnboarding, stats: nil)
            }
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Bırakma yolculuğun")
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.textPrimary)
            Text("Adım adım, hekim temelli bir program. Şu an neredesin ve sırada ne var?")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func stageCard(_ stage: SmokingContent.JourneyStage) -> some View {
        let isCurrent = isCurrentStage(stage)
        let locked = !stage.isFreeTier && !store.isPremium

        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: isCurrent ? "location.fill" : "circle.fill")
                    .font(.caption)
                    .foregroundStyle(isCurrent ? Theme.primary : Theme.textSecondary.opacity(0.4))
                Text(stage.title)
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                if isCurrent {
                    Text("şu an")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Theme.primary.opacity(0.15))
                        .foregroundStyle(Theme.primaryDark)
                        .clipShape(Capsule())
                }
                Spacer()
                if locked {
                    Image(systemName: "lock.fill").font(.caption).foregroundStyle(Theme.textSecondary)
                }
            }

            Text(stage.summary)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)

            if locked {
                Button { showPaywall = true } label: {
                    Text("Bu aşamayı Premium ile aç")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.primaryDark)
                }
                .padding(.top, 2)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(stage.tips, id: \.self) { tip in
                        Label(tip, systemImage: "checkmark.circle")
                            .font(.footnote)
                            .foregroundStyle(Theme.textPrimary)
                    }
                }
                .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }

    private var withdrawalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Yoksunlukta ne hissedeceksin?")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)
            ForEach(SmokingContent.withdrawalGuide) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.symptom).font(.subheadline.weight(.semibold))
                    Text(item.whatToExpect).font(.caption).foregroundStyle(Theme.textSecondary)
                    Label(item.coping, systemImage: "lightbulb")
                        .font(.caption).foregroundStyle(Theme.primaryDark)
                }
                if item.id != SmokingContent.withdrawalGuide.last?.id { Divider() }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Destek ve bilgi")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)
            ForEach(SmokingContent.supportInfo) { card in
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.title).font(.subheadline.weight(.semibold))
                    Text(card.body).font(.caption).foregroundStyle(Theme.textSecondary)
                }
                if card.id != SmokingContent.supportInfo.last?.id { Divider() }
            }
            AssistanceFooter()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }

    /// Geçen süre, bu aşamanın başlangıcı ile bir sonrakinin başlangıcı arasında mı?
    private func isCurrentStage(_ stage: SmokingContent.JourneyStage) -> Bool {
        let stages = SmokingContent.journeyStages
        guard let idx = stages.firstIndex(of: stage) else { return false }
        let start = stage.startOffset
        let nextStart = idx + 1 < stages.count ? stages[idx + 1].startOffset : .greatestFiniteMagnitude
        return elapsed >= start && elapsed < nextStart
    }
}
