import Foundation
import UIKit

protocol EditMelodyGridDelegate: AnyObject {
    func editMelodyGrid(_ editMelodyGrid: EditMelodyGrid, didCreateNote noteViewModel: NoteViewModel)
    func editMelodyGrid(_ editMelodyGrid: EditMelodyGrid, didDeleteNote noteViewModel: NoteViewModel)
}

extension EditMelodyGrid {
    private enum Constants {
        static let standartNotesInBeat: Int = 4
        static let visualNoteRounding: Double = 1 / 24

        static let noteHeight: CGFloat = 32
        static let standartNoteWidth: CGFloat = 64
        
        static let noteSeparatorWidth: CGFloat = 1
        static let beatSeparatorWidth: CGFloat = 4
        static let measureSeparatorWidth: CGFloat = 8
        
        static let beatWidth: CGFloat = CGFloat(Constants.standartNotesInBeat) * (
            Constants.standartNoteWidth + Constants.noteSeparatorWidth
        ) - Constants.noteSeparatorWidth

        static let measureWidth: CGFloat = CGFloat(Int.beatsInMeasure) * (
            beatWidth + Constants.beatSeparatorWidth
        ) - Constants.beatSeparatorWidth
    }
}

final class EditMelodyGrid: UIView {
    weak var delegate: EditMelodyGridDelegate?

    // MARK: Public properties

    var keys: Int {
        didSet {
            updateAllLayers()
        }
    }
    
    var measures: Int {
        didSet {
            drawMissingBeats()
        }
    }

    var notesInBeat: Int {
        didSet {
            for beatLayer in beatLayers {
                redrawSeparatorsOfBeatLayer(beatLayer)
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        let measureWithSeparatorWidth = Constants.measureWidth + Constants.measureSeparatorWidth
        let noteWithSeparatorHeight = Constants.noteHeight + Constants.noteSeparatorWidth

        return .init(
            width: CGFloat(measures) * measureWithSeparatorWidth - Constants.measureSeparatorWidth,
            height: CGFloat(keys) * noteWithSeparatorHeight - Constants.noteSeparatorWidth
        )
    }

    // MARK: Private properties

    private var beatLayers: [CALayer] = []
    private var noteViewMapping = ObjectMapper<NoteViewModel, EditMelodyGridNote>()

    // MARK: Init

    init(measures: Int, keys: Int, notesInBeat: Int, notes: [NoteViewModel] = []) {
        self.measures = measures
        self.keys = keys
        self.notesInBeat = notesInBeat
        
        super.init(frame: .zero)

        self.configure()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public functions

    func startPlayAnimation(onNote note: NoteViewModel) {
        noteViewMapping[note]?.startPlayAnimation()
    }

    func addNote(noteViewModel: NoteViewModel) {
        let noteView = EditMelodyGridNote(noteViewModel: noteViewModel)
        noteView.delegate = self
        addSubview(noteView)

        let roundedStart = (noteViewModel.start / Constants.visualNoteRounding).rounded() * Constants.visualNoteRounding
        let roundedEnd = (noteViewModel.end / Constants.visualNoteRounding).rounded() * Constants.visualNoteRounding
        let startLocation = findBeatLocation(roundedStart, includingLastSeparator: true)
        let endLocation = findBeatLocation(roundedEnd)

        noteView.frame = .init(
            x: startLocation,
            y: (Constants.noteHeight + Constants.noteSeparatorWidth) * CGFloat(noteViewModel.key),
            width: endLocation - startLocation,
            height: Constants.noteHeight
        )

        noteViewMapping[noteViewModel] = noteView
    }

    func deleteNote(noteViewModel: NoteViewModel) {
        if let editMelodyGridNote = noteViewMapping[noteViewModel] {
            editMelodyGridNote.removeFromSuperview()
            noteViewMapping[editMelodyGridNote.noteViewModel] = nil
        }
    }

    // MARK: Private functions

    private func configure() {
        backgroundColor = .imp.backgroundColor

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnGrid(_:)))
        addGestureRecognizer(tapGestureRecognizer)

        drawMissingBeats()
    }

    /// Перерисовывает всю сетку.
    private func updateAllLayers() {
        beatLayers.forEach {
            $0.removeFromSuperlayer()
        }
        beatLayers.removeAll(keepingCapacity: true)
        drawMissingBeats()
    }

    /// Отрисовывает нужные биты, если их не хватает, или удаляет биты с конца, если есть лишние.
    /// Нужно вызывать каждый раз при изменении количества битов.
    private func drawMissingBeats() {
        if beatLayers.count > measures * .beatsInMeasure {
            beatLayers.suffix(beatLayers.count - measures * .beatsInMeasure).forEach {
                $0.removeFromSuperlayer()
            }
            beatLayers.removeLast(beatLayers.count - measures * .beatsInMeasure)
            invalidateIntrinsicContentSize()
        } else if beatLayers.count < measures * .beatsInMeasure {
            for beat in beatLayers.count ..< measures * .beatsInMeasure {
                let beatLayer = drawBeat(beat)
                layer.insertSublayer(beatLayer, at: 0)
                beatLayers.append(beatLayer)
            }
            invalidateIntrinsicContentSize()
        }
    }
    
    /// Отрисовывает бит с переданым номером.
    /// - Parameter beat: номер бита.
    /// - Returns: отрисованный бит.
    private func drawBeat(_ beat: Int) -> CALayer {
        let evenColor = UIColor.imp.gridEvenBeatBackgroundColor.cgColor
        let oddColor = UIColor.imp.gridOddBeatBackgroundColor.cgColor
        let beatLayer = CALayer()
        beatLayer.backgroundColor = beat % 2 == 0 ? evenColor : oddColor
        beatLayer.frame = calculateBeatFrame(beat)
        redrawSeparatorsOfBeatLayer(beatLayer)
        return beatLayer
    }
    
    /// Считает расположение бита с переданным номером.
    /// - Parameter beat: номер бита.
    /// - Returns: расположение бита.
    private func calculateBeatFrame(_ beat: Int) -> CGRect {
        let prevMeasuresWidth = CGFloat(beat / .beatsInMeasure) * (Constants.measureWidth + Constants.measureSeparatorWidth)
        let prevBeatsWidth = CGFloat(beat % .beatsInMeasure) * (Constants.beatWidth + Constants.beatSeparatorWidth)
        return .init(
            origin: .init(x: prevMeasuresWidth + prevBeatsWidth, y: 0),
            size: .init(
                width: Constants.beatWidth,
                height: CGFloat(keys) * (Constants.noteHeight + Constants.noteSeparatorWidth) - Constants.noteSeparatorWidth
            )
        )
    }
    
    /// Удаляет разделители на бите и рисует их снова.
    /// - Parameter beatLayer: слой бита для перерисовки разделителей.
    private func redrawSeparatorsOfBeatLayer(_ beatLayer: CALayer) {
        beatLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        drawHorizontalSeparatorsOfBeatLayer(beatLayer)
        drawVerticalSeparatorsOfBeatLayer(beatLayer)
    }
    
    /// Рисует горизонтальные разделители на бите.
    /// - Parameter beatLayer: слоу бита для рисования разделителей.
    private func drawHorizontalSeparatorsOfBeatLayer(_ beatLayer: CALayer) {
        for key in 1 ..< keys {
            let separator = CALayer()
            separator.backgroundColor = UIColor.imp.backgroundColor.cgColor
            beatLayer.addSublayer(separator)

            separator.frame = .init(
                x: 0,
                y: (Constants.noteHeight + Constants.noteSeparatorWidth) * CGFloat(key) - Constants.noteSeparatorWidth,
                width: beatLayer.frame.width,
                height: Constants.noteSeparatorWidth
            )
        }
    }

    /// Рисует вертикальные разделители на бите.
    /// - Parameter beatLayer: слоу бита для рисования разделителей.
    private func drawVerticalSeparatorsOfBeatLayer(_ beatLayer: CALayer) {
        let noteWidth = (beatLayer.frame.width - Constants.noteSeparatorWidth * CGFloat(notesInBeat - 1)) / CGFloat(notesInBeat)
        for note in 1 ..< notesInBeat {
            let separator = CALayer()
            separator.backgroundColor = UIColor.white.cgColor
            beatLayer.addSublayer(separator)

            separator.frame = .init(
                x: (noteWidth + Constants.noteSeparatorWidth) * CGFloat(note) - Constants.noteSeparatorWidth,
                y: 0,
                width: Constants.noteSeparatorWidth,
                height: beatLayer.frame.height
            )
        }
    }
    
    /// Находит ноту, ее начало и конец по точке касания.
    /// - Parameter point: точка касания.
    /// - Returns: нота, ее начало и конец. Если касание произошло в некорректной координате вернется nil.
    private func findTouchLocationOnGrid(point: CGPoint) -> (key: Int, start: Double, end: Double)? {
        if let key = findKeyOfTouch(at: point), let beat = findBeatOfTouch(at: point) {
            return (key: key, start: beat.start, end: beat.end)
        } else {
            return nil
        }
    }
    
    /// Находит ноту переданного касания.
    /// - Parameter point: точка касания.
    /// - Returns: нота, которая должна находится по координатам касания.
    private func findKeyOfTouch(at point: CGPoint) -> Int? {
        let noteWithSeparatorHeigth = Constants.noteHeight + Constants.noteSeparatorWidth
        let note = point.y / noteWithSeparatorHeigth
        if note - floor(note) < Constants.noteHeight / Constants.noteSeparatorWidth {
            return Int(note)
        } else {
            return nil
        }
    }
    
    /// Ищет начало и конец ноты переданного касания.
    /// - Parameter point: точка касания.
    /// - Returns: начало и конец ноты, которая должна находиться по координатам касания.
    /// Если касание произошло в некорректной координате вернется nil.
    private func findBeatOfTouch(at point: CGPoint) -> (start: Double, end: Double)? {
        let noteWidth = (Constants.beatWidth - Constants.noteSeparatorWidth * CGFloat(notesInBeat - 1)) / CGFloat(notesInBeat)
        let measureWithSeparatorWidth = Constants.measureWidth + Constants.measureSeparatorWidth
        let beatWithSeparatorWidth = Constants.beatWidth + Constants.beatSeparatorWidth
        let noteWithSeparatorWidth = noteWidth + Constants.noteSeparatorWidth

        let measure = point.x / measureWithSeparatorWidth
        let xInsideMeasure = point.x - floor(measure) * measureWithSeparatorWidth
        if measure - floor(measure) > Constants.measureWidth / measureWithSeparatorWidth {
            return nil
        }

        let beat = xInsideMeasure / beatWithSeparatorWidth
        let xInsideBeat = xInsideMeasure - floor(beat) * beatWithSeparatorWidth
        if beat - floor(beat) > Constants.beatWidth / beatWithSeparatorWidth {
            return nil
        }

        let note = xInsideBeat / noteWithSeparatorWidth
        if note - floor(note) > noteWidth / noteWithSeparatorWidth {
            return nil
        }

        let noteFraction = Double(1) / Double(notesInBeat)
        let start = floor(measure) * Double(Int.beatsInMeasure) + floor(beat) + floor(note) * noteFraction
        let end = floor(measure) * Double(Int.beatsInMeasure) + floor(beat) + floor(note + 1) * noteFraction
        return (start: start, end: end)
    }
    
    /// По биту находит его x-координату на сетке.
    /// - Parameters:
    ///   - beat: бит, расположение которого нужно найти.
    ///   - includingLastSeparator: добавлять ли разделитель к координате.
    /// - Returns: X-координата переданного бита.
    private func findBeatLocation(_ beat: Double, includingLastSeparator: Bool = false) -> CGFloat {
        let noteWidth = (Constants.beatWidth - Constants.noteSeparatorWidth * CGFloat(notesInBeat - 1)) / CGFloat(notesInBeat)
        let noteFraction = Double(1) / Double(notesInBeat)

        let measures = floor(beat / Double(Int.beatsInMeasure) + .eps)
        let beats = floor(beat - measures * Double(Int.beatsInMeasure) + .eps)
        let notes = floor((beat - measures * Double(Int.beatsInMeasure) - beats) / noteFraction + .eps)
        let remainder = beat - measures * Double(Int.beatsInMeasure) - beats - notes * noteFraction

        let measuresWidth = (Constants.measureWidth + Constants.measureSeparatorWidth) * measures
        let beatsWidth = (Constants.beatWidth + Constants.beatSeparatorWidth) * beats
        let notesWidth = (noteWidth + Constants.noteSeparatorWidth) * notes
        let remainderWidth = noteWidth * remainder / noteFraction
        let totalWidth = measuresWidth + beatsWidth + notesWidth + remainderWidth

        if !includingLastSeparator, remainder < .eps {
            if notes < .eps {
                if beats < .eps {
                    return totalWidth - Constants.measureSeparatorWidth
                } else {
                    return totalWidth - Constants.beatSeparatorWidth
                }
            } else {
                return totalWidth - Constants.noteSeparatorWidth
            }
        } else {
            return totalWidth
        }
    }

    /// Вызывается при любом нажатии на сетку.
    /// - Parameter sender: распознаватель нажатий.
    @objc private func didTapOnGrid(_ sender: UITapGestureRecognizer) {
        if let (key, start, end) = findTouchLocationOnGrid(point: sender.location(in: self)) {
            let noteViewModel = NoteViewModel(key: key, start: start, end: end)
            addNote(noteViewModel: noteViewModel)
            delegate?.editMelodyGrid(self, didCreateNote: noteViewModel)
        }
    }
}

// MARK: - EditMelodyGridNoteDelegate

extension EditMelodyGrid: EditMelodyGridNoteDelegate {
    func editMelodyGridNoteWasTapped(_ editMelodyGridNote: EditMelodyGridNote) {
        editMelodyGridNote.removeFromSuperview()
        noteViewMapping[editMelodyGridNote.noteViewModel] = nil
        delegate?.editMelodyGrid(self, didDeleteNote: editMelodyGridNote.noteViewModel)
    }
}
