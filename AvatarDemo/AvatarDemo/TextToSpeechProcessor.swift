//
//  TextToSpeechProcessor.swift
//  AvatarDemo
//
//  Created by Sergio on 15.06.24.
//

import AVFoundation

class TextToSpeechProcessor: NSObject, AVSpeechSynthesizerDelegate {
    private var speechSynthesizer: AVSpeechSynthesizer
    private var shapeKeyAnimator: ShapeKeyAnimator?
    private let configuration: AvatarConfiguration

    init(configuration: AvatarConfiguration) {
        self.configuration = configuration
        self.speechSynthesizer = AVSpeechSynthesizer()
        super.init()
        self.speechSynthesizer.delegate = self
    }

    func processAndReadText(_ text: String, animator: ShapeKeyAnimator?) {
        self.shapeKeyAnimator = animator
        let syllables = SyllableProcessor.processTextToSyllables(text)
        let totalDuration = estimateSpeechDuration(for: text)
        shapeKeyAnimator?.animateSyllables(syllables, totalDuration: totalDuration)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            self.speechSynthesizer.speak(utterance)
        }
    }

    private func estimateSpeechDuration(for text: String) -> TimeInterval {
        let wordsPerMinute: Double = 250.0
        let words = text.split { $0.isWhitespace || $0.isPunctuation }.count
        let minutes = Double(words) / wordsPerMinute
        return minutes * 60.0
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // Reset or perform any necessary actions after TTS finishes
    }
}
