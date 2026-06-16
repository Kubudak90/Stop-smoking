import SwiftUI

/// Sayaç ekranındaki büyük istatistik kartı.
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(tint)
            Text(value)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundStyle(Theme.textPrimary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(title)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }
}

/// Premium içeriği kilitleyen örtü. Spec §8 (ücretsiz/premium ayrımı).
struct PremiumLock: View {
    let title: String
    let message: String
    var onUnlock: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .foregroundStyle(Theme.primary)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
            Button(action: onUnlock) {
                Text("Premium'u Keşfet")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Theme.gradient)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                .stroke(Theme.primary.opacity(0.2), lineWidth: 1)
        )
    }
}

/// Tıbbi sorumluluk reddi. Spec §6, §17. "İyileştirir/garanti" dili yok.
struct MedicalDisclaimer: View {
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle")
                .foregroundStyle(Theme.textSecondary)
            Text("Bu bilgiler genel sağlık bilgilendirmesidir, kişiye özel tıbbi tavsiye değildir. Nefes bir tedavi yöntemi değil, bırakma sürecinde sana eşlik eden bir araçtır.")
                .font(.caption2)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(12)
        .background(Theme.background)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

/// ALO 171 ve sigara bırakma polikliniği yönlendirmesi. Spec §6, §10, §17.
/// Sorumlu entegrasyon: uygulama profesyonele KÖPRÜ olur.
struct AssistanceFooter: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Profesyonel destek")
                .font(.headline)
            Text("Yoksunluk zorlaşırsa yalnız değilsin. ALO 171 Sigara Bırakma Danışma Hattı ücretsiz ve gizlidir.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)

            Button {
                if let url = URL(string: "tel://171") { openURL(url) }
            } label: {
                Label("ALO 171'i Ara", systemImage: "phone.fill")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Theme.primary.opacity(0.12))
                    .foregroundStyle(Theme.primaryDark)
                    .clipShape(Capsule())
            }

            Text("Sigara bırakma poliklinikleri için aile hekimine veya en yakın sağlık kuruluşuna başvurabilirsin.")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .card()
    }
}

/// Birincil buton stili.
struct PrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let systemImage { Image(systemName: systemImage) }
                Text(title)
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.gradient)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}
