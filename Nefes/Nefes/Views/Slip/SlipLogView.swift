import SwiftUI
import SwiftData

/// Kayma kaydı — ASIL FARKLILAŞTIRICI. Spec §5, §10.5.
///
/// Azarlamayan dil, suçlamayan akış. Sayaç SIFIRLANMAZ. Kayma bir veri ve öğrenmedir.
/// Tetikleyici sorusu gelecekteki tetikleyici yönetiminin yakıtıdır.
struct SlipLogView: View {
    let profile: UserProfile

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var count = 1
    @State private var selectedTrigger: String?
    @State private var selectedEmotion: SlipEmotion?
    @State private var note = ""
    @State private var saved = false

    var body: some View {
        NavigationStack {
            if saved {
                confirmation
            } else {
                form
            }
        }
    }

    // MARK: - Form

    private var form: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // Azarlamayan giriş mesajı (Spec §5)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bir kez kaydın, yolculuk bitmedi.")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Çoğu insan birkaç denemede bırakır — bu da o denemelerden biri. Sayacın sıfırlanmaz. Şimdi bunu bir öğrenmeye çevirelim.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.primary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Kaç tane
                VStack(alignment: .leading, spacing: 8) {
                    Text("Kaç sigara?").font(.subheadline.weight(.semibold))
                    Stepper("\(count) sigara", value: $count, in: 1...40)
                }

                // Tetikleyici (Spec §5 tetikleyici öğrenme)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tetikleyen neydi?").font(.subheadline.weight(.semibold))
                    Text("Ne zaman, nerede? Bunu işaretlemek gelecekte seni korur.")
                        .font(.caption).foregroundStyle(Theme.textSecondary)
                    FlexibleWrap(SmokingHabit.triggers, spacing: 8) { trigger in
                        chip(
                            label: trigger.label,
                            icon: trigger.systemImage,
                            isOn: selectedTrigger == trigger.id
                        ) {
                            selectedTrigger = selectedTrigger == trigger.id ? nil : trigger.id
                        }
                    }
                }

                // Duygu
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hangi duyguyla?").font(.subheadline.weight(.semibold))
                    FlexibleWrap(SlipEmotion.allCases, spacing: 8) { emotion in
                        chip(
                            label: emotion.label,
                            icon: emotion.systemImage,
                            isOn: selectedEmotion == emotion
                        ) {
                            selectedEmotion = selectedEmotion == emotion ? nil : emotion
                        }
                    }
                }

                // Not
                VStack(alignment: .leading, spacing: 8) {
                    Text("Not (opsiyonel)").font(.subheadline.weight(.semibold))
                    TextField("Aklında kalanı yaz…", text: $note, axis: .vertical)
                        .lineLimit(2...4)
                        .textFieldStyle(.roundedBorder)
                }

                PrimaryButton(title: "Kaydet ve devam et", systemImage: "checkmark") {
                    save()
                }
            }
            .padding()
        }
        .background(Theme.background)
        .navigationTitle("Kayma kaydı")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Vazgeç") { dismiss() }
            }
        }
    }

    // MARK: - Onay (devamlılık vurgusu, suçluluk değil)

    private var confirmation: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "arrow.forward.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(Theme.primary)
            Text("Kaydedildi. Yolculuk devam ediyor.")
                .font(.title3.weight(.bold))
                .multilineTextAlignment(.center)
            Text("Sayacın sıfırlanmadı. Bir tetikleyiciyi tanıdın — bu, bir sonraki sefer için gerçek bir avantaj.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Spacer()
            PrimaryButton(title: "Geri dön") { dismiss() }
                .padding(.horizontal)
        }
        .padding()
        .background(Theme.background)
    }

    private func chip(label: String, icon: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(label, systemImage: icon)
                .font(.footnote)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(isOn ? Theme.primary : Theme.surface)
                .foregroundStyle(isOn ? .white : Theme.textPrimary)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Theme.primary.opacity(isOn ? 0 : 0.25)))
        }
    }

    private func save() {
        let record = SlipRecord(
            date: .now,
            unitCount: count,
            triggerCategoryID: selectedTrigger,
            emotion: selectedEmotion,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : note
        )
        context.insert(record)
        try? context.save()
        withAnimation { saved = true }
    }
}
