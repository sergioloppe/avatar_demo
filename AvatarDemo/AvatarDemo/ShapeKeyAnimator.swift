//
//  ShapeKeyAnimator.swift
//  animation
//
//  Created by Sergio on 14.06.24.
//

import SceneKit

class ShapeKeyAnimator: NSObject {
    private var syncTimer: Timer?
    private var asyncTimer: Timer?
    private var morpher: SCNMorpher?
    private var targetIndices: [String: Int] = [:]
    private var syllableMapper: SyllableMapper
    private var configuration: AvatarConfiguration
    private var node: SCNNode
    
    var asyncFrequencyRange: ClosedRange<TimeInterval> = 2.0...5.0
    var asyncAnimationDuration: TimeInterval = 0.1
    var syncAnimationDuration: TimeInterval = 0.09

    init(morpher: SCNMorpher, node: SCNNode, syllableMapper: SyllableMapper, configuration: AvatarConfiguration) {
        self.morpher = morpher
        self.node = node
        self.syllableMapper = syllableMapper
        self.configuration = configuration
        
        for (index, target) in morpher.targets.enumerated() {
            targetIndices[target.name!] = index
        }
        
        super.init()
        startAsyncAnimations()
    }
    
    private func startAsyncAnimations() {
        asyncTimer?.invalidate()
        asyncTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval.random(in: asyncFrequencyRange), repeats: true) { [weak self] timer in
            self?.blink()
        }
    }

    private func blink() {
        animateMultipleShapeKey(named: configuration.blinkTargets, duration: asyncAnimationDuration)
    }

    private func createWeightAction(targetIndices: [Int], duration: TimeInterval, increase: Bool) -> SCNAction {
        return SCNAction.customAction(duration: duration) { (node, elapsedTime) in
            let weight = increase ? CGFloat(elapsedTime / CGFloat(duration)) : CGFloat(1.0 - (elapsedTime / CGFloat(duration)))
            for targetIndex in targetIndices {
                self.morpher?.setWeight(weight, forTargetAt: targetIndex)
            }
        }
    }

    func animateShapeKey(named shapeKey: String, duration: TimeInterval) {
        guard let targetIndex = targetIndices[shapeKey] else { return }
        
        let halfDuration = duration / 2.0
        let increaseWeight = createWeightAction(targetIndices: [targetIndex], duration: halfDuration, increase: true)
        let decreaseWeight = createWeightAction(targetIndices: [targetIndex], duration: halfDuration, increase: false)

        let sequence = SCNAction.sequence([increaseWeight, decreaseWeight])
        node.runAction(sequence)
    }
    
    func animateMultipleShapeKey(named shapeKeys: [String], duration: TimeInterval) {
        let targetIndices = shapeKeys.compactMap { self.targetIndices[$0] }
        guard !targetIndices.isEmpty else { return }
        
        let halfDuration = duration / 2.0
        let increaseWeight = createWeightAction(targetIndices: targetIndices, duration: halfDuration, increase: true)
        let decreaseWeight = createWeightAction(targetIndices: targetIndices, duration: halfDuration, increase: false)

        let sequence = SCNAction.sequence([increaseWeight, decreaseWeight])
        node.runAction(sequence)
    }
    
    func animateSyllables(_ syllables: [String], totalDuration: TimeInterval) {
        guard let morpher = self.morpher else { return }

        let syllableDuration = totalDuration / TimeInterval(syllables.count)
        
        var syllableIndex = 0
        
        syncTimer?.invalidate()
        syncTimer = Timer.scheduledTimer(withTimeInterval: syllableDuration, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if syllableIndex >= syllables.count {
                timer.invalidate()
                return
            }
            
            let syllable = syllables[syllableIndex]
            let mappedTarget = self.syllableMapper.mapSyllableToMorpher(syllable)
            if let targetIndex = self.targetIndices[mappedTarget] {
                self.animateShapeKey(named: mappedTarget, duration: syllableDuration)
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
