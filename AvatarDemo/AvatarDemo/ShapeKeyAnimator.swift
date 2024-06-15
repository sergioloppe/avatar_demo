//
//  ShapeKeyAnimator.swift
//  animation
//
//  Created by Sergio on 14.06.24.
//

import SceneKit

class ShapeKeyAnimator: NSObject {
    private var timer: Timer?
    private var morpher: SCNMorpher?
    private var targetIndices: [String: Int] = [:]
    private var syllableMapper: SyllableMapper

    init(morpher: SCNMorpher, syllableMapper: SyllableMapper) {
        self.morpher = morpher
        self.syllableMapper = syllableMapper
        super.init()
        for (index, name) in DefaultSyllableMapper.targetNames.enumerated() {
            targetIndices[name] = index
        }
    }
    
    func animateShapeKey(named shapeKey: String) {
        guard let morpher = self.morpher, let targetIndex = targetIndices[shapeKey] else { return }
        
        // Invalidate any existing timer
        timer?.invalidate()
        
        // Smoothly transition the weight up and then down
        var currentWeight: Float = 0.0
        let step: Float = 0.1
        var goingUp = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if goingUp {
                currentWeight += step
                if currentWeight >= 1.0 {
                    currentWeight = 1.0
                    goingUp = false
                }
            } else {
                currentWeight -= step
                if currentWeight <= 0.0 {
                    currentWeight = 0.0
                    timer.invalidate()
                }
            }
            
            // Reset all weights to 0 before setting the target weight
            for i in 0..<morpher.targets.count {
                morpher.setWeight(0.0, forTargetAt: i)
            }
            morpher.setWeight(CGFloat(currentWeight), forTargetAt: targetIndex)
        }
    }
    
    func animateSyllables(_ syllables: [String]) {
        guard let morpher = self.morpher else { return }
        
        var syllableIndex = 0
        
        // Invalidate any existing timer
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if syllableIndex >= syllables.count {
                timer.invalidate()
                return
            }
            
            let syllable = syllables[syllableIndex]
            let mappedTarget = self.syllableMapper.mapSyllableToMorpher(syllable)
            if let targetIndex = self.targetIndices[mappedTarget] {
                // Animate the target morpher for the current syllable
                self.animateShapeKey(named: mappedTarget)
            }
            
            syllableIndex += 1
        }
    }
    
    static func findMorpher(in node: SCNNode?) -> SCNMorpher? {
        guard let node = node else { return nil }
        if let morpher = node.morpher {
            return morpher
        }
        for child in node.childNodes {
            if let result = findMorpher(in: child) {
                return result
            }
        }
        return nil
    }
    
    func printNodeNamesAndMorphers(_ node: SCNNode) {
        print("Node name: \(node.name ?? "Unnamed")")
        if let morpher = node.morpher {
            print("  Morpher found with targets: \(morpher.targets)")
            for (index, target) in morpher.targets.enumerated() {
                print("    Target \(index): \(target.name ?? "Unnamed")")
            }
        }
        for child in node.childNodes {
            printNodeNamesAndMorphers(child)
        }
    }
}
