//
//  SyllableMapper.swift
//  AvatarDemo
//
//  Created by Sergio on 15.06.24.
//

import Foundation

protocol SyllableMapper {
    func mapSyllableToMorpher(_ syllable: String) -> String
}

class DefaultSyllableMapper: SyllableMapper {
    private var phonemeMappings: [String: String]

    init(configuration: AvatarConfiguration) {
        self.phonemeMappings = configuration.phonemeMappings
    }
    
    func mapSyllableToMorpher(_ syllable: String) -> String {
        let phoneme = self.getPhoneme(for: syllable)
        return self.phonemeMappings[phoneme, default: "sil"]
    }
    
    private func getPhoneme(for syllable: String) -> String {
        let vowels = CharacterSet(charactersIn: "aeiou")
        for char in syllable.lowercased() {
            if String(char).rangeOfCharacter(from: vowels) != nil {
                return String(char)
            }
        }
        return "sil"
    }
}
