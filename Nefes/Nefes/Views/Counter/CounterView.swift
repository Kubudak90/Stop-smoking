import SwiftUI
import SwiftData

/// Ana ekran (sayaç). Spec §10.2, §4.
/// Gerçek zamanlı: geçen süre, içilmeyen sigara, biriken para, kazanılan ömür, kilometre taşı.
struct CounterView: View {
    let profile: UserProfile

    @EnvironmentObject private var env: AppEnvironment
    @EnvironmentObject private var store: StoreManager
    @Query(sort: \SlipRecord.date, order: .reverse) private var slips: [SlipRecord]

    @State private var now = Date.now
    @State private var showSOS = false
    @State private var showSlip = false
    @State private var showPaywall = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var stats: QuitStats {
        QuitStatsCalculator.stats(profile: profile, slips: slips, now: now)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    elapsedHeader
                    statGrid
                    currentMilestoneCard
                    MedicalDisclaimer()
                    cravingSOSButton
                    slipButton
                    reasonsReminder
                }
                .padding()
            }
            .background(Theme.background)
            .navigationTitle("Nefes")
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(timer) { now = $0 }
            .sheet(isPresented: $showSOS) {
                CravingSOSView(profile: profile)
            }
            .sheet(isPresented: $showSlip) {
                SlipLogView(profile: profile)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(context: .postOnboarding, stats: stats)
            }
            .onAppear(perform: onCounterAppear)
        }
    }

    private func onCounterAppear() {
        #if DEBUG
        switch UITestConfig.screen {
        case .sos: showSOS = true; return
        case .paywall: showPaywall = true; return
        case .none: break
        }
        // Ekran görüntüsü modunda doğal post-onboarding paywall'ı bastır.
        if UITestConfig.isActive { return }
        #endif
        maybeShowPostOnboardingPaywall()
    }

    // MARK: - Geçen süre başlığı (canlı)

    private var elapsedHeader: some View {
        let c = AppFormatters.clockComponents(stats.elapsed)
        return VStack(spacing: 6) {
            Text("Sigarasız")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
            HStack(alignment: .lastTextBaseline, spacing: 10) {
                clockUnit(c.days, "gün")
                clockUnit(c.hours, "saat")
                clockUnit(c.minutes, "dk")
                clockUnit(c.seconds, "sn")
            }
            if stats.streakFrozen {
                Text("Bir kayma kaydettin — serin korunuyor 🛡️")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.top, 2)
            } else if stats.cleanStreakDays != c.days, stats.cleanStreakDays >= 0 {
                Text("Güncel temiz seri: \(stats.cleanStreakDays) gün")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(Theme.calmGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func clockUnit(_ value: Int, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.85))
        }
    }

    // MARK: - İstatistik kartları

    private var statGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                icon: "smoke.fill",
                title: "İçilmeyen sigara",
                value: AppFormatters.count(stats.unitsNotConsumed),
                tint: Theme.primary
            )
            StatCard(
                icon: "turkishlirasign.circle.fill",
                title: "Biriken para",
                value: AppFormatters.money(stats.moneySaved),
                tint: Theme.accent
            )
            StatCard(
                icon: "heart.fill",
                title: "Kazanılan ömür",
                value: AppFormatters.lifeRegained(stats.lifeRegained),
                tint: Theme.danger
            )
            StatCard(
                icon: "flame.fill",
                title: "Temiz seri",
                value: "\(stats.cleanStreakDays) gün",
                tint: Theme.primaryDark
            )
        }
    }

    // MARK: - Mevcut kilometre taşı

    private var currentMilestoneCard: some View {
        // Premium kilometre taşının TIBBİ DETAYI ücretsiz kullanıcıya sızdırılmaz (gating).
        let milestone = stats.currentMilestone
        let canSeeDetail = (milestone?.isFreeTier ?? true) || store.isPremium
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.seal.fill").foregroundStyle(Theme.primary)
                Text(milestone?.title ?? "Yolculuk başladı")
                    .font(.headline)
                Spacer()
                if milestone != nil, !canSeeDetail {
                    Image(systemName: "lock.fill").font(.caption).foregroundStyle(Theme.textSecondary)
                }
            }
            Text(detailText(for: milestone, canSeeDetail: canSeeDetail))
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)

            if let next = stats.nextMilestone {
                Divider()
                HStack {
                    Text("Sıradaki: \(next.title)")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Theme.textSecondary)
                    Spacer()
                }
                ProgressView(value: stats.progressToNext)
                    .tint(Theme.primary)
            }
        }
        .card()
    }

    private func detailText(for milestone: HealthMilestone?, canSeeDetail: Bool) -> String {
        guard let milestone else {
            return "İlk dakikalar bile vücudunda iyileşmeyi başlatıyor."
        }
        return canSeeDetail
            ? milestone.detail
            : "Bu kilometre taşının ne anlama geldiğini görmek için İyileşme Takvimi'ni aç."
    }

    // MARK: - Craving SOS — kriz anı butonu (Spec §4, §10.4, §11)

    private var cravingSOSButton: some View {
        Button {
            showSOS = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "lifepreserver.fill")
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Şu an canım çekiyor")
                        .font(.headline)
                    Text("Kriz anı — 4 dakikada birlikte atlatalım")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.9))
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
            .foregroundStyle(.white)
            .padding(18)
            .background(LinearGradient(colors: [Theme.danger, Color(hex: 0xC9472F)], startPoint: .leading, endPoint: .trailing))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Theme.danger.opacity(0.3), radius: 10, y: 4)
        }
    }

    // MARK: - Kayma kaydı (Spec §5)

    private var slipButton: some View {
        Button {
            showSlip = true
        } label: {
            HStack {
                Image(systemName: "arrow.uturn.backward")
                Text("Bir sigara içtim")
                Spacer()
                Text("kaydet")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            .font(.subheadline)
            .foregroundStyle(Theme.textPrimary)
            .padding(16)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.textSecondary.opacity(0.15)))
        }
    }

    // MARK: - "Neden bırakıyorum" hatırlatıcısı (Spec §4)

    @ViewBuilder
    private var reasonsReminder: some View {
        if !profile.reasons.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Neden bıraktın")
                    .font(.headline)
                FlexibleWrap(profile.reasons, spacing: 8) { reason in
                    Text(reason)
                        .font(.footnote)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Theme.primary.opacity(0.1))
                        .foregroundStyle(Theme.primaryDark)
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .card()
        }
    }

    // MARK: - Değer-sonra-paywall (Spec §11)

    private func maybeShowPostOnboardingPaywall() {
        // Değeri göster: en az bir miktar para biriktiyse VE henüz gösterilmediyse VE premium değilse.
        guard !env.hasSeenPostOnboardingPaywall,
              !store.isPremium,
              stats.moneySaved > 0 else { return }
        env.hasSeenPostOnboardingPaywall = true
        // Kullanıcı sayacı bir an görsün, sonra paywall.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showPaywall = true
        }
    }
}
