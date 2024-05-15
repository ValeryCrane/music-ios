import Foundation
import UIKit
import AVFoundation

protocol RecordSampleViewModelInput {
    func getInitialMeasures() -> Int
    func setMeasures(_ measures: Int)
    func startButtonTapped()
    func stopButtonTapped()
    func playButtonTapped()
    func clearButtonTapped()
    func saveButtonTapped()
    func effectsButtonTapped()
    func closeButtonTapped()
}

protocol RecordSampleViewModelOutput: UIViewController {
    func setState(_ state: RecordSampleViewController.State)
    func startAnimation(forBeat beat: Int, delay: TimeInterval, duration: TimeInterval)
    func finishAllAnimations()
}

final class RecordSampleViewModel {
    weak var view: RecordSampleViewModelOutput?

    private let bpm: Double
    private let recordSampleManager: RecordSampleManager

    private let audioEngineManager = AudioEngineManager()
    private let playerNode = AVAudioPlayerNode()
    private let createSampleHandler: (Sample) async -> Void

    private var measures = 2
    private var recordingURL: URL?

    private var saveSampleAlertAction: UIAlertAction?

    init(
        bpm: Double,
        recordSampleManager: RecordSampleManager,
        createSampleHandler: @escaping (Sample) async -> Void
    ) {
        self.bpm = bpm
        self.recordSampleManager = recordSampleManager
        self.createSampleHandler = createSampleHandler

        audioEngineManager.attachNode(playerNode)
    }

    private func showSaveSampleAlert() {
        let alertViewController = UIAlertController(title: "Сохранение сэмпла", message: "Введите название сэмпла", preferredStyle: .alert)
        alertViewController.addTextField { [weak self] textField in
            textField.placeholder = "Легкие барабаны"
            if let self = self {
                textField.addTarget(self, action: #selector(onSaveSampleAlertTextFieldEdited(_:)), for: .editingChanged)
            }
        }

        let saveSampleAlertAction = UIAlertAction(
            title: "Сохранить",
            style: .default
        ) { [weak self] _ in
            if let text = alertViewController.textFields?.first?.text, !text.isEmpty {
                self?.createSample(withName: text)
            }
        }

        alertViewController.addAction(.init(title: "Отмена", style: .cancel))
        alertViewController.addAction(saveSampleAlertAction)
        saveSampleAlertAction.isEnabled = false
        self.saveSampleAlertAction = saveSampleAlertAction

        view?.present(alertViewController, animated: true)
    }

    @objc
    private func onSaveSampleAlertTextFieldEdited(_ sender: UITextField) {
        if let text = sender.text, !text.isEmpty {
            saveSampleAlertAction?.isEnabled = true
        } else {
            saveSampleAlertAction?.isEnabled = false
        }
    }

    private func createSample(withName name: String) {
        view?.startLoader()
        Task {
            let sampleId = try await recordSampleManager.uploadSampleToServer(name: name, beats: measures * .beatsInMeasure)
            await MainActor.run {
                view?.stopLoader()
            }
            await createSampleHandler(.init(
                sampleId: sampleId,
                name: name,
                beats: measures * .beatsInMeasure, 
                effects: AudioEngineManager.effectsManager.getEffects()
            ))
            await MainActor.run {
                view?.dismiss(animated: true)
            }
        }
    }
}

extension RecordSampleViewModel: RecordSampleViewModelInput {
    func getInitialMeasures() -> Int {
        measures
    }

    func setMeasures(_ measures: Int) {
        self.measures = measures
    }

    func startButtonTapped() {
        try? recordSampleManager.startRecording()
        view?.setState(.recording)

        let beatDuration = 60.0 / bpm
        for i in 0 ..< measures * .beatsInMeasure {
            view?.startAnimation(forBeat: i, delay: Double(i) * beatDuration, duration: beatDuration)
        }
    }
    
    func stopButtonTapped() {
        view?.finishAllAnimations()
        view?.setState(.finished)
        recordingURL = try? recordSampleManager.endRecording(cutToDuration: 60.0 / bpm * Double(measures * .beatsInMeasure))
    }

    func playButtonTapped() {
        guard let recordingURL = recordingURL, let recordingBuffer = try? AVAudioPCMBuffer(from: recordingURL) else { return }

        playerNode.stop()
        audioEngineManager.disconnect(playerNode)
        audioEngineManager.addNodeToMainMixer(playerNode, format: recordingBuffer.format)
        playerNode.scheduleBuffer(recordingBuffer)
        playerNode.play()
    }

    func clearButtonTapped() {
        recordingURL = nil
        recordSampleManager.clear()
        view?.setState(.initial)
    }

    func saveButtonTapped() {
        showSaveSampleAlert()
    }

    func effectsButtonTapped() {
        let effectEditor = EffectEditor(effectsManager: AudioEngineManager.effectsManager)
        let viewController = effectEditor.getViewController()
        view?.present(viewController, animated: true)
    }

    func closeButtonTapped() {
        view?.dismiss(animated: true)
    }
}
