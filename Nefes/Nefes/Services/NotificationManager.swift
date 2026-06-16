import Foundation
import UserNotifications

/// Yerel bildirim motoru — retention'ın kalbi. Spec §12 (Retention Motoru), §6.
///
/// BİLDİRİM FELSEFESİ (sessiz koç): destekleyici, azarlamayan, anksiyete üretmeyen.
/// Asla suçlama, korku pornografisi, agresif hatırlatma. İlk 72 saat en yoğun destek.
@MainActor
final class NotificationManager: ObservableObject {
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let center = UNUserNotificationCenter.current()

    func refreshStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await refreshStatus()
            return granted
        } catch {
            return false
        }
    }

    /// Profil için tüm planlı bildirimleri kurar. Bırakma tarihi değişince yeniden çağrılır.
    func reschedule(for profile: UserProfile, config: HabitConfig = SmokingHabit.config) async {
        center.removeAllPendingNotificationRequests()
        guard authorizationStatus == .authorized || authorizationStatus == .provisional else { return }

        scheduleMilestoneCelebrations(for: profile, config: config)
        scheduleFirst72HourSupport(for: profile)
        scheduleReturnHook(for: profile)
    }

    /// Her sağlık kilometre taşı geçilince kutlama. Spec §6, §12 (dopamin döngüsü).
    private func scheduleMilestoneCelebrations(for profile: UserProfile, config: HabitConfig) {
        let now = Date.now
        for milestone in config.healthMilestones {
            let fireDate = milestone.reachedDate(since: profile.quitDate)
            guard fireDate > now else { continue }

            let content = UNMutableNotificationContent()
            content.title = "🌿 \(milestone.title) doldu"
            content.body = milestone.detail
            content.sound = .default

            schedule(content, at: fireDate, id: "milestone_\(milestone.id)")
        }
    }

    /// İlk 72 saat = ölüm bölgesi. Sık, kısa, destekleyici. Spec §12, §15.
    private func scheduleFirst72HourSupport(for profile: UserProfile) {
        let messages: [(offset: TimeInterval, body: String)] = [
            (.hours(3),  "İlk saatler en yoğun an. İstek gelirse 4 dakika nefes — geçecek."),
            (.hours(8),  "Bugün iyi gidiyorsun. Bir bardak su, kısa bir yürüyüş çok işe yarar."),
            (.hours(24), "İlk 24 saati tamamladın. En zor kısım bu — sen bunu yapıyorsun."),
            (.hours(36), "İstek dalgaları kısalır ve seyrekleşir. Her dalga bir öncekinden zayıf."),
            (.hours(48), "İki gün oldu. Koku ve tat almaya yakında 'merhaba' diyeceksin."),
            (.hours(60), "Neredeyse 72 saat. Nikotin vücudundan çıkıyor; en sert dönem geride."),
            (.hours(72), "72 saat! Fiziksel bağımlılığın en sert kısmını geçtin. Devam.")
        ]
        for (i, msg) in messages.enumerated() {
            let fireDate = profile.quitDate.addingTimeInterval(msg.offset)
            guard fireDate > .now else { continue }
            let content = UNMutableNotificationContent()
            content.title = "Nefes — yanındayım"
            content.body = msg.body
            content.sound = .default
            schedule(content, at: fireDate, id: "support_\(i)")
        }
    }

    /// Geri dönüş kancası: 2 gün açılmazsa nazik tek hatırlatma. Spec §12.
    /// (Gerçek "açılmama" tespiti uygulama foreground'da yeniden planlanarak yapılır:
    /// her açılışta bu bildirim 48 saat ileri ötelenir.)
    private func scheduleReturnHook(for profile: UserProfile) {
        let content = UNMutableNotificationContent()
        content.title = "Nasıl gidiyor?"
        content.body = "Bir uğrayıp ilerlemene bakmak ister misin? Buradayım."
        content.sound = .default
        let fireDate = Date.now.addingTimeInterval(.days(2))
        schedule(content, at: fireDate, id: "return_hook")
    }

    private func schedule(_ content: UNNotificationContent, at date: Date, id: String) {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second], from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
}
