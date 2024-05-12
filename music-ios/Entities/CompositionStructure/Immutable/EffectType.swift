import Foundation

enum EffectType: String, Codable, CodingKeyRepresentable, CaseIterable {
    case distortion
    case delay
    case reverb
    case volume
    
    var name: String {
        switch self {
        case .distortion:
            "Distortion"
        case .delay:
            "Delay"
        case .reverb:
            "Reverb"
        case .volume:
            "Volume"
        }
    }

    var propertyTypes: [EffectPropertyType] {
        switch self {
        case .distortion:
            [.distortionPreGain, .distortionWetDryMix]
        case .delay:
            [.delayTime, .delayFeedback, .delayWetDryMix]
        case .reverb:
            [.reverbWetDryMix]
        case .volume:
            [.volumeValue]
        }
    }
}
