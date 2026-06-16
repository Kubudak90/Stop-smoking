import SwiftUI
import SwiftData

/// İyileşme takvimi. Spec §6, §10.3.
/// Geçilen ve sıradaki sağlık kilometre taşları. İlk birkaç adım ücretsiz, tamamı premium (§8).
struct RecoveryTimelineView: View {
    let profile: UserProfile

    @EnvironmentObject private var store: StoreManager
    @Query(sort: \SlipRecord.date, order: .reverse) private var slips: [SlipRecord]

    @State private var now = Date.now
    @State private var showPaywall = false
    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    private let milestones = SmokingHabit.config.healthMilestones

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(milestones.enumerated()), id: \.element.id) { index, milestone in
                        let reached = milestone.isReached(since: profile.quitDate, now: now)
                        let locked = !milestone.isFreeTier && !store.isPremium

                        TimelineRow(
                            milestone: milestone,
                            reached: reached,
                            locked: locked,
                            isLast: index == milestones.count - 1,
                            reachedDate: milestone.reachedDate(since: profile.quitDate)
                        ) {
                            showPaywall = true
                        }
                    }

                    MedicalDisclaimer().padding(.top, 16)
                    AssistanceFooter().padding(.top, 16)
                }
                .padding()
            }
            .background(Theme.background)
            .navigationTitle("İyileşme Takvimi")
            .onReceive(timer) { now = $0 }
            .sheet(isPresented: $showPaywall) {
                PaywallView(context: .recoveryTimeline, stats: nil)
            }
        }
    }
}

private struct TimelineRow: View {
    let milestone: HealthMilestone
    let reached: Bool
    let locked: Bool
    let isLast: Bool
    let reachedDate: Date
    var onUnlock: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Sol çizgi + nokta
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(reached ? Theme.primary : Theme.surface)
                        .frame(width: 28, height: 28)
                        .overlay(Circle().stroke(reached ? Theme.primary : Theme.textSecondary.opacity(0.3), lineWidth: 2))
                    Image(systemName: reached ? "checkmark" : (locked ? "lock.fill" : "circle"))
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(reached ? .white : Theme.textSecondary)
                }
                if !isLast {
                    Rectangle()
                        .fill(reached ? Theme.primary.opacity(0.4) : Theme.textSecondary.opacity(0.15))
                        .frame(width: 2)
                        .frame(minHeight: 40)
                }
            }

            // İçerik
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(milestone.title)
                        .font(.headline)
                        .foregroundStyle(reached ? Theme.textPrimary : Theme.textSecondary)
                    if reached {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundStyle(Theme.primary)
                    }
                }

                if locked {
                    Button(action: onUnlock) {
                        Label("Premium ile aç", systemImage: "lock.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.primaryDark)
                    }
                } else {
                    Text(milestone.detail)
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                    if reached {
                        Text(reachedDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption2)
                            .foregroundStyle(Theme.primary)
                    }
                }
            }
            .padding(.bottom, isLast ? 0 : 16)
            Spacer()
        }
    }
}
