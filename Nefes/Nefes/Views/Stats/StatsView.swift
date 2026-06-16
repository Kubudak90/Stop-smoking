import SwiftUI
import SwiftData
import Charts

/// İstatistik. Spec §10.6: seri, tetikleyici örüntüleri, ilerleme grafiği (çoğu premium).
struct StatsView: View {
    let profile: UserProfile

    @EnvironmentObject private var store: StoreManager
    @Query(sort: \SlipRecord.date, order: .reverse) private var slips: [SlipRecord]

    @State private var now = Date.now
    @State private var showPaywall = false

    private var stats: QuitStats {
        QuitStatsCalculator.stats(profile: profile, slips: slips, now: now)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    summaryCards

                    if store.isPremium {
                        moneyProjectionCard
                        triggerPatternsCard
                        slipHistoryCard
                    } else {
                        PremiumLock(
                            title: "Detaylı istatistikler",
                            message: "Tetikleyici örüntülerin, biriken para projeksiyonun ve ilerleme grafiklerin premium ile açılır."
                        ) { showPaywall = true }
                    }
                }
                .padding()
            }
            .background(Theme.background)
            .navigationTitle("İstatistik")
            .sheet(isPresented: $showPaywall) {
                PaywallView(context: .stats, stats: stats)
            }
        }
    }

    private var summaryCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(icon: "flame.fill", title: "Temiz seri", value: "\(stats.cleanStreakDays) gün", tint: Theme.primary)
            StatCard(icon: "smoke.fill", title: "İçilmeyen", value: AppFormatters.count(stats.unitsNotConsumed), tint: Theme.primaryDark)
            StatCard(icon: "turkishlirasign.circle.fill", title: "Biriken", value: AppFormatters.money(stats.moneySaved), tint: Theme.accent)
            StatCard(icon: "arrow.uturn.backward", title: "Kayma sayısı", value: "\(slips.count)", tint: Theme.danger)
        }
    }

    // MARK: - Para projeksiyonu (premium) — Spec §7 para psikolojisi

    private var moneyProjectionCard: some View {
        let perDay = profile.pricePerUnit * Double(profile.unitsPerDay)
        let projections: [(String, Double)] = [
            ("1 ay", perDay * 30),
            ("6 ay", perDay * 182),
            ("1 yıl", perDay * 365),
            ("5 yıl", perDay * 365 * 5)
        ]
        return VStack(alignment: .leading, spacing: 12) {
            Text("Biriken para projeksiyonu").font(.headline)
            Text("Bu hızla devam edersen birikecek tutar:")
                .font(.caption).foregroundStyle(Theme.textSecondary)
            Chart(projections, id: \.0) { item in
                BarMark(x: .value("Dönem", item.0), y: .value("TL", item.1))
                    .foregroundStyle(Theme.accent.gradient)
                    .annotation(position: .top) {
                        Text(AppFormatters.money(item.1))
                            .font(.caption2)
                            .foregroundStyle(Theme.textSecondary)
                    }
            }
            .frame(height: 180)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }

    // MARK: - Tetikleyici örüntüleri (premium) — Spec §5

    private var triggerPatternsCard: some View {
        let counts = Dictionary(grouping: slips.compactMap(\.triggerCategoryID), by: { $0 })
            .mapValues(\.count)
            .sorted { $0.value > $1.value }

        return VStack(alignment: .leading, spacing: 12) {
            Text("Tetikleyici örüntülerin").font(.headline)
            if counts.isEmpty {
                Text("Henüz kayma kaydın yok. Olursa, tetikleyicilerin burada birikir — gelecekteki seni korumak için.")
                    .font(.subheadline).foregroundStyle(Theme.textSecondary)
            } else {
                ForEach(counts, id: \.key) { id, count in
                    if let trigger = SmokingHabit.triggerCategory(id: id) {
                        HStack {
                            Label(trigger.label, systemImage: trigger.systemImage)
                                .font(.subheadline)
                            Spacer()
                            Text("\(count)×")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.danger)
                        }
                    }
                }
                Text("En sık tetikleyicin için bir plan kur: o an gelmeden ne yapacağını önceden belirle.")
                    .font(.caption).foregroundStyle(Theme.textSecondary)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }

    // MARK: - Kayma geçmişi (premium)

    @ViewBuilder
    private var slipHistoryCard: some View {
        if !slips.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Kayma geçmişi").font(.headline)
                ForEach(slips.prefix(10)) { slip in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(slip.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.subheadline.weight(.medium))
                            HStack(spacing: 6) {
                                if let t = SmokingHabit.triggerCategory(id: slip.triggerCategoryID) {
                                    Text(t.label)
                                }
                                if let e = slip.emotion {
                                    Text("· \(e.label)")
                                }
                            }
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                        }
                        Spacer()
                        Text("\(slip.unitCount) sigara")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .padding(.vertical, 4)
                    if slip.id != slips.prefix(10).last?.id { Divider() }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .card()
        }
    }
}
