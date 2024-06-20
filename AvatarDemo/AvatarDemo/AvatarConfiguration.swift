//
//  AvatarConfiguration.swift
//  AvatarDemo
//
//  Created by Sergio on 20.06.24.
//

import Foundation
import SceneKit

/// Configuration struct for the avatar, containing various settings and mappings used in the avatar animation and rendering.
struct AvatarConfiguration {
    var nodeNameRoot: String
    var nodeNameMesh: String
    var nodeNameCamera: String
    var nodeNameHead: String
    var textureName: String                 // Name of the texture to be applied to the mesh
    var containerHeight: CGFloat            // Height of the container for scaling the avatar
    var initialPosition: SCNVector3         // Initial position of the avatar
    var initialEulerAngles: SCNVector3      // Initial rotation angles of the avatar
    var blinkTargets: [String]              // List of blink target names
    var phonemeMappings: [String: String]   // Mapping of phonemes to morpher target names

    static let defaultConfiguration = AvatarConfiguration(
        nodeNameRoot: "root",
        nodeNameMesh: "Mesh",
        nodeNameCamera: "Camera.001",
        nodeNameHead: "mixamorig_Head",
        textureName: "phong22",
        containerHeight: 300,
        initialPosition: SCNVector3(0.2, 0.2, -3.0 * 1.23),
        initialEulerAngles: SCNVector3(0.15, 0, -0.25),
        blinkTargets: ["vrc_blink_left", "vrc_blink_right"],
        phonemeMappings: [
            "a": "vrc_v_aa",
            "e": "vrc_v_ee",
            "i": "vrc_v_ih",
            "o": "vrc_v_oh",
            "u": "vrc_v_ou",
            "th": "vrc_v_th",
            "s": "vrc_v_ss",
            "r": "vrc_v_rr",
            "p": "vrc_v_pp",
            "f": "vrc_v_ff",
            "d": "vrc_v_dd",
            "ch": "vrc_v_ch",
            "n": "vrc_v_nn",
            "k": "vrc_v_kk",
            "sil": "vrc_v_sil"
        ]
    )
}
