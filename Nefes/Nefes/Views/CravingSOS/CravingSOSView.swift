import SwiftUI

/// Craving SOS — kriz anı butonu. Spec §4, §10.4, §11, §12.
///
/// İçerik: nefes egzersizi + "neden bırakıyorum" hatırlatıcısı + "bu his 3-5 dakikada
/// geçer" + dikkat dağıtma. Nefes egzersizi her zaman ÜCRETSİZ (sağlık aracı paywall'lanmaz);
/// tam araç seti (tetikleyici yönetimi, kişiselleştirme) premium tetikleyicidir (Spec §11).
struct CravingSOSView: View {
    let profile: UserProfile

    @EnvironmentObject private var env: AppEnvironment
    @EnvironmentObject private var store: StoreManager
    @Environment(\.dismiss) private var dismiss

    @State private var phase: Screen = .reassure
    @State private var showPaywall = false

    enum Screen { case reassure, breathing, aftermath }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.calmGradient.ignoresSafeArea()
                content
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") { dismiss() }.foregroundStyle(.white)
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(context: .cravingSOS, stats: nil)
            }
            .onAppear { env.hasUsedCravingSOS = true }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .reassure: reassureScreen
        case .breathing: BreathingExercise { withAnimation { phase = .aftermath } }
        case .aftermath: aftermathScreen
        }
    }

    // MARK: - 1. Güvence: "bu his geçer"

    private var reassureScreen: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "wind")
                .font(.system(size: 60))
                .foregroundStyle(.white)
            Text("Bu his 3-5 dakikada geçer.")
                .font(.system(.title, design: .rounded).weight(.bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text("İstek bir dalga gibidir: yükselir, tepe yapar ve geçer. Sigara içmesen de geçer. Şimdi birlikte nefes alalım.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.95))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Spacer()
            Button {
                withAnimation { phase = .breathing }
            } label: {
                Text("Nefes egzersizine başla")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.white)
                    .foregroundStyle(Theme.primaryDark)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    // MARK: - 3. Sonrası: hatırlatma + dikkat dağıtma + premium tetikleyici

    private var aftermathScreen: some View {
        ScrollView {
            VStack(spacing: 18) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(.white)
                Text("Dalgayı atlattın.")
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                Text("İçmedin — ve istek şimdiden zayıfladı. Her atlattığın dalga, bir sonrakini kolaylaştırır.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.95))
                    .multilineTextAlignment(.center)

                // "Neden bırakıyorum" hatırlatıcısı
                if !profile.reasons.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bunun için bıraktın:")
                            .font(.subheadline.weight(.semibold))
                        ForEach(profile.reasons, id: \.self) { reason in
                            Label(reason, systemImage: "heart.fill")
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                // Dikkat dağıtma önerileri
                VStack(alignment: .leading, spacing: 10) {
                    Text("Şimdi şunu dene")
                        .font(.subheadline.weight(.semibold))
                    ForEach(Self.distractions, id: \.self) { tip in
                        Label(tip, systemImage: "sparkles")
                            .font(.subheadline)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .foregroundStyle(.white)

                // Premium tetikleyici: tetikleyici yönetimi (Spec §11)
                if !store.isPremium {
                    Button { showPaywall = true } label: {
                        VStack(spacing: 6) {
                            Text("Bu isteği tekrar yaşamamak için")
                                .font(.subheadline.weight(.semibold))
                            Text("Tetikleyicilerini öğren, kişisel kriz planını kur →")
                                .font(.caption)
                        }
                        .foregroundStyle(Theme.primaryDark)
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }

                Button("Tamam, geçti") { dismiss() }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.top, 4)
            }
            .foregroundStyle(.white)
            .padding(24)
        }
    }

    static let distractions = [
        "Bir bardak soğuk su iç",
        "10 derin nefes daha al",
        "2 dakika kısa bir yürüyüş yap",
        "Birine mesaj at veya ara",
        "Ellerini meşgul et: bir şey sık, çiz, düzenle"
    ]
}

/// Görsel nefes egzersizi: 4-4-6 (al-tut-ver) döngüsü, 4 tur. Spec §10.4.
struct BreathingExercise: View {
    var onFinish: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var instruction = "Hazır ol"
    @State private var roundsLeft = 4
    @State private var running = false

    private let inhale: Double = 4
    private let hold: Double = 4
    private let exhale: Double = 6

    var body: some View {
        VStack(spacing: 36) {
            Spacer()
            Text(instruction)
                .font(.system(.title, design: .rounded).weight(.bold))
                .foregroundStyle(.white)
                .contentTransition(.opacity)

            ZStack {
                Circle()
                    .fill(.white.opacity(0.15))
                    .frame(width: 260, height: 260)
                Circle()
                    .fill(.white.opacity(0.9))
                    .frame(width: 200, height: 200)
                    .scaleEffect(scale)
            }

            Text(roundsLeft > 0 ? "\(roundsLeft) tur kaldı" : "")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
            Spacer()
        }
        .onAppear { if !running { running = true; startRound() } }
    }

    private func startRound() {
        guard roundsLeft > 0 else {
            instruction = "Harika"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { onFinish() }
            return
        }

        instruction = "Burnundan yavaşça al"
        withAnimation(.easeInOut(duration: inhale)) { scale = 1.0 }

        DispatchQueue.main.asyncAfter(deadline: .now() + inhale) {
            instruction = "Tut"
            DispatchQueue.main.asyncAfter(deadline: .now() + hold) {
                instruction = "Ağzından yavaşça ver"
                withAnimation(.easeInOut(duration: exhale)) { scale = 0.5 }
                DispatchQueue.main.asyncAfter(deadline: .now() + exhale) {
                    roundsLeft -= 1
                    startRound()
                }
            }
        }
    }
}
