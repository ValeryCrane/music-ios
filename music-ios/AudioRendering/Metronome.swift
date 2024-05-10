import Foundation
import AVFoundation

protocol MetronomeListener: AnyObject {
    func metronome(_ metronome: Metronome, didStartPlayingAtBeat beat: Double)
    func metronome(_ metronome: Metronome, didStopPlayingAtBeat beat: Double)
    func metronome(_ metronome: Metronome, didUpdateBPM bpm: Double)
}

final class Metronome {
    /// Свойство - индикатор того, что метроном запущен.
    private(set) var isPlaying = false

    /// Текущий BPM метронома.
    private(set) var bpm: Double
    
    /// Время запуска/перезапуска метронома.
    /// Если метроном не был запущен - nil.
    /// Если метроном на паузе - время, с которого он на паузе.
    private var startTime: UInt64?

    /// Бит, который должен быть проигран во время startTime.
    /// Если startTime - nil, то beatAtStartTime - тоже nil.
    private var beatAtStartTime: Double?
    
    /// Прослушиватели метронома по слабой ссылке
    private var listeners = [() -> MetronomeListener?]()

    init(bpm: Double) {
        self.bpm = bpm
    }
    
    /// Добавляет прослушивателя к метроному.
    /// - Parameter listener: прослушиватель метронома.
    func addListener(_ listener: MetronomeListener) {
        listeners.append({ [weak listener] in
            listener
        })
    }

    /// Удаляет прослушивателя.
    /// - Parameter listener: прослушиватель метронома.
    func removeListener(_ listener: MetronomeListener) {
        listeners.removeAll(where: { $0() === listener })
    }

    /// Обновляет BPM метронома и уведомляет об этом прослушивателей.
    /// - Parameter bpm: Новый BPM
    func updateBPM(_ bpm: Double) {
        let currentHostTime = mach_absolute_time()
        if let currentBeat = getBeat(ofHostTime: currentHostTime) {
            startTime = currentHostTime
            beatAtStartTime = currentBeat
        }

        self.bpm = bpm
        listeners.forEach { $0()?.metronome(self, didUpdateBPM: bpm) }
    }

    /// Возвращает время, когда должен быть проигран бит.
    /// Если метроном на паузе, и бит должен быть проигран после начала воспроизведения - возвращает nil.
    /// Если метроном не был запущен - возвращает nil.
    /// - Parameter beat: бит, который надо проиграть.
    /// - Returns: время, когда его надо проиграть.
    func getHostTime(ofBeat beat: Double) -> UInt64? {
        if let startTime = startTime, let beatAtStartTime = beatAtStartTime {
            if beat > beatAtStartTime, isPlaying {
                return startTime + AVAudioTime.hostTime(forSeconds: getDuration(ofBeats: (beat - beatAtStartTime)))
            } else if beat <= beatAtStartTime {
                return startTime - AVAudioTime.hostTime(forSeconds: getDuration(ofBeats: (beatAtStartTime - beat)))
            }
        }

        return nil
    }
    
    /// Возвращает бит, который должен быть проигран в переданое время.
    /// Если метроном на паузе, и переданное время не наступило - возвращает nil.
    /// Если метроном не был запущен - возвращает nil.
    /// - Parameter hostTime: время, когда нужно проиграть бит.
    /// - Returns: бит, который нужно проиграть.
    func getBeat(ofHostTime hostTime: UInt64) -> Double? {
        if let startTime = startTime, let beatAtStartTime = beatAtStartTime {
            if hostTime > startTime, isPlaying  {
                return beatAtStartTime + getBeats(ofDuration: AVAudioTime.seconds(forHostTime: hostTime - startTime))
            } else if hostTime <= startTime {
                return beatAtStartTime - getBeats(ofDuration: AVAudioTime.seconds(forHostTime: startTime - hostTime))
            }
        }

        return nil
    }

    /// Считает продолжительность битов в секундах.
    /// - Parameter beats: количество битов.
    /// - Returns: продолжительность битов.
    func getDuration(ofBeats beats: Double) -> Double {
        beats * (60 / bpm)
    }
    
    /// Считает, сколько битов поместится в переданное время.
    /// - Parameter duration: время.
    /// - Returns: сколько битов поместится во время.
    func getBeats(ofDuration duration: Double) -> Double {
        duration / (60 / bpm)
    }
    
    /// Запускает метроном.
    /// Если метроном был на паузе - запускает его с момента startTime.
    /// Если метроном уже запущен - ничего не происходит.
    func play() {
        guard !isPlaying else { return }

        let beatAtStartTime = self.beatAtStartTime ?? 0
        self.startTime = mach_absolute_time()
        self.beatAtStartTime = beatAtStartTime
        isPlaying = true

        listeners.forEach { $0()?.metronome(self, didStartPlayingAtBeat: beatAtStartTime) }
    }
    
    /// Приостанавливет метроном.
    /// Если метроном уже был на паузе или не был запущен - ничего не происходит.
    func pause() {
        guard isPlaying else { return }

        let currentHostTime = mach_absolute_time()
        if let currentBeat = getBeat(ofHostTime: currentHostTime) {
            startTime = currentHostTime
            beatAtStartTime = currentBeat
            isPlaying = false
            listeners.forEach { $0()?.metronome(self, didStopPlayingAtBeat: currentBeat)}
        }
    }
    
    /// Обнуляет метроном.
    /// Если метроном не был запущен - ничего не происходит.
    /// Если метроном был на паузе - происходит обнуление значений.
    /// Если метроном был запущен - прослушиватели уведомляются об окончании пригрывания.
    func reset() {
        let currentHostTime = mach_absolute_time()
        if isPlaying, let currentBeat = getBeat(ofHostTime: currentHostTime) {
            isPlaying = false
            listeners.forEach { $0()?.metronome(self, didStopPlayingAtBeat: currentBeat)}
        }

        startTime = nil
        beatAtStartTime = nil
    }
}
