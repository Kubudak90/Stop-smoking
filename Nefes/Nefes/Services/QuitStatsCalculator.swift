import Foundation

/// Sayaç istatistiklerini hesaplar. Spec §4 (Sayaç direği), §5 (kayma sıfırlamaz).
///
/// KRİTİK FELSEFE: Kayma sayacı SIFIRLAMAZ. İçilmeyen sigara sayısından yalnızca
/// gerçekten içilen birimler düşülür; geçen süre ve seri korunur (slip ≠ reset).
struct QuitStats {
    let elapsed: TimeInterval
    let unitsNotConsumed: Int
    let moneySaved: Double
    let lifeRegained: TimeInterval
    let reachedMilestones: [HealthMilestone]
    let currentMilestone: HealthMilestone?
    let nextMilestone: HealthMilestone?
    let progressToNext: Double // 0...1
    let cleanStreakDays: Int
}

enum QuitStatsCalculator {

    /// Tüm sayaç değerlerini hesaplar.
    /// - Parameters:
    ///   - profile: Kullanıcı profili.
    ///   - slips: Tüm kayma kayıtları.
    ///   - now: Şu an (test edilebilirlik için enjekte edilir).
    static func stats(
        profile: UserProfile,
        slips: [SlipRecord],
        config: HabitConfig = SmokingHabit.config,
        now: Date = .now
    ) -> QuitStats {
        let elapsed = max(0, now.timeIntervalSince(profile.quitDate))
        let elapsedDays = elapsed / 86_400

        // Bırakılsaydı içilecek toplam birim.
        let wouldHaveConsumed = elapsedDays * Double(profile.unitsPerDay)

        // Gerçekten içilen (kaymalar). Kayma cezası değil, yalnızca dürüst muhasebe.
        let slippedUnits = slips
            .filter { $0.date >= profile.quitDate }
            .reduce(0) { $0 + $1.unitCount }

        let unitsNotConsumed = max(0, Int(wouldHaveConsumed.rounded(.down)) - slippedUnits)

        let moneySaved = Double(unitsNotConsumed) * profile.pricePerUnit
        let lifeRegained = TimeInterval(unitsNotConsumed) * .minutes(config.lifeRegainedMinutesPerUnit)

        let reached = config.healthMilestones.filter { $0.isReached(since: profile.quitDate, now: now) }
        let current = reached.last
        let next = config.healthMilestones.first { !$0.isReached(since: profile.quitDate, now: now) }

        let progress: Double
        if let next {
            let lowerBound = current?.timeOffset ?? 0
            let span = next.timeOffset - lowerBound
            progress = span > 0 ? min(1, max(0, (elapsed - lowerBound) / span)) : 1
        } else {
            progress = 1
        }

        // Temiz seri: son kaymadan bu yana geçen tam günler (kayma varsa oradan, yoksa quitDate'ten).
        let streakAnchor = slips
            .filter { $0.date >= profile.quitDate }
            .map(\.date)
            .max() ?? profile.quitDate
        let cleanStreakDays = Int(max(0, now.timeIntervalSince(streakAnchor)) / 86_400)

        return QuitStats(
            elapsed: elapsed,
            unitsNotConsumed: unitsNotConsumed,
            moneySaved: moneySaved,
            lifeRegained: lifeRegained,
            reachedMilestones: reached,
            currentMilestone: current,
            nextMilestone: next,
            progressToNext: progress,
            cleanStreakDays: cleanStreakDays
        )
    }
}
