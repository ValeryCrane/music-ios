import Foundation
import UIKit

enum EffectPropertyType {
    case distortionWetDryMix
    case delayTime
    case delayFeedback
    case delayWetDryMix
    case reverbWetDryMix
    case volumeValue
    
    var image: UIImage? {
        switch self {
        case .distortionWetDryMix:
            .init(systemName: "arrow.triangle.merge")
        case .delayTime:
            .init(systemName: "timer")
        case .delayFeedback:
            .init(systemName: "gobackward")
        case .delayWetDryMix:
            .init(systemName: "arrow.triangle.merge")
        case .reverbWetDryMix:
            .init(systemName: "arrow.triangle.merge")
        case .volumeValue:
            .init(systemName: "speaker.plus")
        }
    }
    
    var minValue: Float {
        switch self {
        case .distortionWetDryMix:
            0
        case .delayTime:
            0
        case .delayFeedback:
            -100
        case .delayWetDryMix:
            0
        case .reverbWetDryMix:
            0
        case .volumeValue:
            0
        }
    }
    
    var maxValue: Float {
        switch self {
        case .distortionWetDryMix:
            100
        case .delayTime:
            2
        case .delayFeedback:
            100
        case .delayWetDryMix:
            100
        case .reverbWetDryMix:
            100
        case .volumeValue:
            1
        }
    }
}
