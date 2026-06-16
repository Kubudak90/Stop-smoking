import Foundation

/// Kayma/kriz anının tetikleyici kategorisi. Spec §5 (tetikleyici öğrenme),
/// §10 (kayma kaydı: "Ne zaman, nerede, hangi duyguyla?").
struct TriggerCategory: Identifiable, Hashable {
    let id: String
    let label: String
    let systemImage: String
}

/// Kayma anındaki duygu durumu — ceza değil, veri ve öğrenme. Spec §5.
enum SlipEmotion: String, Codable, CaseIterable, Identifiable {
    case stress
    case boredom
    case social
    case sadness
    case joy
    case anger
    case craving

    var id: String { rawValue }

    var label: String {
        switch self {
        case .stress: return "Stres"
        case .boredom: return "Can sıkıntısı"
        case .social: return "Sosyal ortam"
        case .sadness: return "Üzüntü"
        case .joy: return "Keyif / kutlama"
        case .anger: return "Öfke"
        case .craving: return "Saf istek"
        }
    }

    var systemImage: String {
        switch self {
        case .stress: return "bolt.fill"
        case .boredom: return "hourglass"
        case .social: return "person.2.fill"
        case .sadness: return "cloud.rain.fill"
        case .joy: return "party.popper.fill"
        case .anger: return "flame.fill"
        case .craving: return "brain.head.profile"
        }
    }
}
