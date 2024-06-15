//
//  SyllableProcessor.swift
//  AvatarDemo
//
//  Created by Sergio on 15.06.24.
//

import Foundation

class SyllableProcessor {
    static func processTextToSyllables(_ text: String) -> [String] {
        // Simple syllable splitting for demonstration purposes
        // A more sophisticated approach may be required for accurate syllable splitting
        let vowels = CharacterSet(charactersIn: "aeiouAEIOU")
        var syllables: [String] = []
        var currentSyllable = ""
        
        for character in text {
            currentSyllable.append(character)
            if String(character).rangeOfCharacter(from: vowels) != nil {
                syllables.append(currentSyllable)
                currentSyllable = ""
            }
        }
        if !currentSyllable.isEmpty {
            syllables.append(currentSyllable)
        }
        
        return syllables
    }
}
