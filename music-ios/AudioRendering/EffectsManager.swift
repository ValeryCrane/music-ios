import Foundation
import UIKit
import AVFoundation

protocol EffectsManagerRenderDelegate: AnyObject {
    func effectsManagerDidUpdateComposition(_ effectsManager: EffectsManager)
}

final class EffectsManager {
    weak var renderDelegate: EffectsManagerRenderDelegate?

    var inputNode: AVAudioNode {
        delayAudioUnit
    }

    var outputNode: AVAudioNode {
        mixerNode
    }

    private let effects: MutableEffects

    private let audioEngineManager = AudioEngineManager()
    private let delayAudioUnit = AVAudioUnitDelay()
    private let distortionAudioUnit = AVAudioUnitDistortion()
    private let reverbAudioUnit = AVAudioUnitReverb()
    private let mixerNode = AVAudioMixerNode()

    init(effects: MutableEffects) {
        self.effects = effects

        audioEngineManager.attachNode(delayAudioUnit)
        audioEngineManager.attachNode(distortionAudioUnit)
        audioEngineManager.attachNode(reverbAudioUnit)
        audioEngineManager.attachNode(mixerNode)
        audioEngineManager.connect(delayAudioUnit, to: distortionAudioUnit)
        audioEngineManager.connect(distortionAudioUnit, to: reverbAudioUnit)
        audioEngineManager.connect(reverbAudioUnit, to: mixerNode)

        applyEffects()
    }

    func update(effectPropertyType: EffectPropertyType, value: Float) {
        apply(value: value, to: effectPropertyType)
        renderDelegate?.effectsManagerDidUpdateComposition(self)
    }

    func getValueOfPropertyType(_ effectPropertyType: EffectPropertyType) -> Float {
        switch effectPropertyType {
        case .distortionWetDryMix:
            distortionAudioUnit.wetDryMix
        case .distortionPreGain:
            distortionAudioUnit.preGain
        case .delayTime:
            Float(delayAudioUnit.delayTime)
        case .delayFeedback:
            delayAudioUnit.feedback
        case .delayWetDryMix:
            delayAudioUnit.wetDryMix
        case .reverbWetDryMix:
            reverbAudioUnit.wetDryMix
        case .volumeValue:
            mixerNode.outputVolume
        }
    }

    private func applyEffects() {
        for effectType in EffectType.allCases {
            for propertyType in effectType.propertyTypes {
                apply(
                    value: effects.value[effectType]?[propertyType] ?? propertyType.defaultValue,
                    to: propertyType
                )
            }
        }
    }

    private func apply(value: Float, to effectPropertyType: EffectPropertyType) {
        switch effectPropertyType {
        case .distortionWetDryMix:
            distortionAudioUnit.wetDryMix = value
            effects.value[.distortion] = effects.value[.distortion] ?? [:]
            effects.value[.distortion]?[.delayWetDryMix] = value
        case .distortionPreGain:
            distortionAudioUnit.preGain = value
            effects.value[.distortion] = effects.value[.distortion] ?? [:]
            effects.value[.distortion]?[.distortionPreGain] = value
        case .delayTime:
            delayAudioUnit.delayTime = TimeInterval(value)
            effects.value[.delay] = effects.value[.delay] ?? [:]
            effects.value[.delay]?[.delayTime] = value
        case .delayFeedback:
            delayAudioUnit.feedback = value
            effects.value[.delay] = effects.value[.delay] ?? [:]
            effects.value[.delay]?[.delayFeedback] = value
        case .delayWetDryMix:
            delayAudioUnit.wetDryMix = value
            effects.value[.delay] = effects.value[.delay] ?? [:]
            effects.value[.delay]?[.delayWetDryMix] = value
        case .reverbWetDryMix:
            reverbAudioUnit.wetDryMix = value
            effects.value[.reverb] = effects.value[.reverb] ?? [:]
            effects.value[.reverb]?[.reverbWetDryMix] = value
        case .volumeValue:
            mixerNode.outputVolume = value
            effects.value[.volume] = effects.value[.volume] ?? [:]
            effects.value[.volume]?[.volumeValue] = value
        }
    }
}
