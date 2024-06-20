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
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        
        for word in words {
            syllables.append(contentsOf: splitIntoSyllables(word))
        }
        
        return syllables
    }

    private static func splitIntoSyllables(_ word: String) -> [String] {
        var syllables: [String] = []
        var currentSyllable = ""
        let vowels = CharacterSet(charactersIn: "aeiouAEIOU")
        let punctuation = CharacterSet(charactersIn: ".,!?;:")
        let consonantClusters = ["ck", "dh", "gh", "sh", "th"]

        for (index, character) in word.enumerated() {
            if String(character).rangeOfCharacter(from: punctuation) != nil {
                if !currentSyllable.isEmpty {
                    syllables.append(currentSyllable)
                    currentSyllable = ""
                }
                syllables.append("sil")
                continue
            }

            currentSyllable.append(character)

            if String(character).rangeOfCharacter(from: vowels) != nil {
                if index < word.count - 1 {
                    let nextIndex = word.index(word.startIndex, offsetBy: index + 1)
                    let nextCharacter = word[nextIndex]
                    
                    if String(nextCharacter).rangeOfCharacter(from: vowels) == nil {
                        if index + 2 < word.count {
                            let nextNextIndex = word.index(word.startIndex, offsetBy: index + 2)
                            let nextNextCharacter = word[nextNextIndex]
                            let cluster = String([nextCharacter, nextNextCharacter])
                            
                            if consonantClusters.contains(cluster) {
                                currentSyllable.append(nextCharacter)
                                currentSyllable.append(nextNextCharacter)
                                syllables.append(currentSyllable)
                                currentSyllable = ""
                                continue
                            }
                        }
                        
                        if nextCharacter.isConsonant {
                            currentSyllable.append(nextCharacter)
                            syllables.append(currentSyllable)
                            currentSyllable = ""
                        }
                    }
                } else {
                    syllables.append(currentSyllable)
                    currentSyllable = ""
                }
            }
        }
        if !currentSyllable.isEmpty {
            syllables.append(currentSyllable)
        }

        // Check for special cases like "yes" and "no"
        for syllable in syllables {
            if syllable.lowercased() == "yes" {
                NotificationCenter.default.post(name: .avatarPerformHeadNod, object: nil)
            }
            if syllable.lowercased() == "no" || syllable.lowercased() == "not" {
                NotificationCenter.default.post(name: .avatarPerformHeadShaking, object: nil)
            }
        }
        
        return syllables
    }
}

private extension Character {
    var isConsonant: Bool {
        let consonants = CharacterSet(charactersIn: "bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ")
        return String(self).rangeOfCharacter(from: consonants) != nil
    }
}
