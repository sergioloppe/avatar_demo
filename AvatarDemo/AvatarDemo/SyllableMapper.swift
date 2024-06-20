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
        return phonemeMappings[syllable, default: "vrc_v_sil"]
    }
}
