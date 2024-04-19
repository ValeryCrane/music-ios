import Foundation

enum EffectType {
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
}
