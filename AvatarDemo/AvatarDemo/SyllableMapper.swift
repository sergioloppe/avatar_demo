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
    static let targetNames = ["vrc_v_th", "vrc_v_ss", "vrc_v_sil", "vrc_v_rr", "vrc_v_pp", "vrc_v_ou", "vrc_v_oh", "vrc_v_nn", "vrc_v_kk", "vrc_v_ih", "vrc_v_ff", "vrc_v_ee", "vrc_v_dd", "vrc_v_ch", "vrc_v_aa", "vrc_lowerlid_right", "vrc_lowerlid_left", "vrc_blink_right", "vrc_blink_left"]

    func mapSyllableToMorpher(_ syllable: String) -> String {
        let phoneme = self.getPhoneme(for: syllable)
        return self.mapPhonemeToMorpher(phoneme)
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
    
    private func mapPhonemeToMorpher(_ phoneme: String) -> String {
        switch phoneme {
        case "a":
            return "vrc_v_aa"
        case "e":
            return "vrc_v_ee"
        case "i":
            return "vrc_v_ih"
        case "o":
            return "vrc_v_oh"
        case "u":
            return "vrc_v_ou"
        case "th":
            return "vrc_v_th"
        case "s":
            return "vrc_v_ss"
        case "r":
            return "vrc_v_rr"
        case "p":
            return "vrc_v_pp"
        case "f":
            return "vrc_v_ff"
        case "d":
            return "vrc_v_dd"
        case "ch":
            return "vrc_v_ch"
        case "n":
            return "vrc_v_nn"
        case "k":
            return "vrc_v_kk"
        case "sil":
            return "vrc_v_sil"
        default:
            return "vrc_v_sil"
        }
    }
}
