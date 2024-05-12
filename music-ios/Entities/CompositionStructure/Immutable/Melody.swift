import Foundation

struct Melody {
    let name: String
    let keyboardId: Int
    let isPedalActive: Bool
    let effects: [EffectType: [EffectPropertyType : Float]]
    let measures: Int
    let notes: [Note]

    private enum CodingKeys: String, CodingKey {
        case name
        case keyboardId = "keyboard_id"
        case isPedalActive = "is_pedal_active"
        case effects
        case measures
        case notes
    }
}

extension Melody {
    static func empty(withName name: String) -> Melody {
        .init(name: name, keyboardId: 1, isPedalActive: true, effects: [:], measures: 2, notes: [])
    }
}

extension Melody {
    private struct Blueprint: Codable {
        let isPedalActive: Bool
        var effects: [EffectType: [EffectPropertyType : Float]]
        let measures: Int
        let notes: [Note]

        private enum CodingKeys: String, CodingKey {
            case isPedalActive = "is_pedal_active"
            case effects
            case measures
            case notes
        }
    }

    init(from melodyGetResponse: Requests.MelodyGet.Response) throws {
        guard
            let blueprintData = melodyGetResponse.blueprint.data(using: .utf8, allowLossyConversion: false),
            let blueprint = try? JSONDecoder().decode(Blueprint.self, from: blueprintData)
        else {
            throw RuntimeError("Ошибка декодирования макета мелодии")
        }

        self.init(
            name: melodyGetResponse.name,
            keyboardId: melodyGetResponse.keyboardId,
            isPedalActive: blueprint.isPedalActive,
            effects: blueprint.effects,
            measures: blueprint.measures,
            notes: blueprint.notes
        )
    }
}

