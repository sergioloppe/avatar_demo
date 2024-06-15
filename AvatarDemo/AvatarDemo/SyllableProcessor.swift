//
//  SyllableProcessor.swift
//  AvatarDemo
//
//  Created by Sergio on 15.06.24.
//

import Foundation

class SyllableProcessor {
    static func processTextToSyllables(_ text: String) -> [String] {
        var syllables: [String] = []
        let vowels = CharacterSet(charactersIn: "aeiouAEIOU")
        let punctuation = CharacterSet(charactersIn: ".,!?;:")

        let words = splitTextIntoWords(text)

        for word in words {
            let wordSyllables = splitWordIntoSyllables(word)
            syllables.append(contentsOf: wordSyllables)
        }
        
        return syllables
    }

    private static func splitTextIntoWords(_ text: String) -> [String] {
        return text.split { $0.isWhitespace }.map { String($0) }
    }
    
    private static func splitWordIntoSyllables(_ word: String) -> [String] {
        var syllables: [String] = []
        var currentSyllable = ""
        var vowelCount = 0
        
        let vowels = CharacterSet(charactersIn: "aeiouAEIOU")
        let punctuation = CharacterSet(charactersIn: ".,!?;:")

        for character in word {
            if String(character).rangeOfCharacter(from: punctuation) != nil {
                if !currentSyllable.isEmpty {
                    syllables.append(currentSyllable)
                    currentSyllable = ""
                    vowelCount = 0
                }
                syllables.append("sil")
            } else {
                currentSyllable.append(character)
                if String(character).rangeOfCharacter(from: vowels) != nil {
                    vowelCount += 1
                    if vowelCount == 2 {
                        let lastCharacter = currentSyllable.removeLast()
                        syllables.append(currentSyllable)
                        currentSyllable = String(lastCharacter)
                        vowelCount = 1
                    }
                } else {
                    vowelCount = 0
                }
            }
        }
        if !currentSyllable.isEmpty {
            syllables.append(currentSyllable)
        }
        
        return syllables
    }
}
