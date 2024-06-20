//
//  SceneViewContainer.swift
//  AvatarDemo
//
//  Created by Sergio on 15.06.24.
//

import SwiftUI
import SceneKit
import SpriteKit

/// A container view for displaying and interacting with the avatar's scene.
struct SceneViewContainer: UIViewRepresentable {
    @Binding var cameraPosition: SCNVector3
    @Binding var meshPosition: SCNVector3
    @Binding var meshRotation: SCNVector3
    @Binding var meshScale: SCNVector3
    let avatarConfiguration: AvatarConfiguration

    class Coordinator: NSObject, SCNSceneRendererDelegate {
        var parent: SceneViewContainer
        var sceneView: SCNView?
        var shapeKeyAnimator: ShapeKeyAnimator?
        var textToSpeechProcessor: TextToSpeechProcessor
        
        // Animations
        private var currentHeadAngle: Float = 0

        init(parent: SceneViewContainer) {
            self.parent = parent
            self.textToSpeechProcessor = TextToSpeechProcessor(configuration: parent.avatarConfiguration)
            
            super.init()
            NotificationCenter.default.addObserver(self, selector: #selector(changeShapeKey(notification:)), name: .avatarChangeShapeKey, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(readText(notification:)), name: .avatarReadText, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(moveHeadLeft(notification:)), name: .avatarMoveHeadLeft, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(moveHeadRight(notification:)), name: .avatarMoveHeadRight, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(moveHeadNodding(notification:)), name: .avatarPerformHeadNod, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(moveHeadShaking(notification:)), name: .avatarPerformHeadShaking, object: nil)
        }

        @objc func changeShapeKey(notification: NSNotification) {
            guard let shapeKey = notification.object as? String else { return }
            shapeKeyAnimator?.animateShapeKey(named: shapeKey, duration: shapeKeyAnimator?.asyncAnimationDuration ?? 0.5)
        }

        @objc func readText(notification: NSNotification) {
            guard let text = notification.object as? String else { return }
            textToSpeechProcessor.processAndReadText(text, animator: shapeKeyAnimator)
        }

        @objc func moveHeadLeft(notification: NSNotification) {
            moveHead(to: .left)
        }

        @objc func moveHeadRight(notification: NSNotification) {
            moveHead(to: .right)
        }

        @objc func moveHeadNodding(notification: NSNotification) {
            performHeadNod()
        }
        
        @objc func moveHeadShaking(notification: NSNotification) {
            performHeadShaking()
        }
        
        func setup(sceneView: SCNView) {
            self.sceneView = sceneView
            sceneView.delegate = self
            startContinuousRotation()
        }

        func initializeShapeKeyAnimatorIfNeeded() {
            guard let sceneView = sceneView, let rootNode = sceneView.scene?.rootNode else { return }
            if shapeKeyAnimator == nil, let morpher = ShapeKeyAnimator.findMorpher(in: rootNode) {
                let syllableMapper = DefaultSyllableMapper(configuration: parent.avatarConfiguration)
                self.shapeKeyAnimator = ShapeKeyAnimator(morpher: morpher, node: rootNode, syllableMapper: syllableMapper, configuration: parent.avatarConfiguration)
            }
        }

        func updateTransforms() {
            guard let sceneView = sceneView else { return }
            if let cameraNode = sceneView.scene?.rootNode.childNode(withName: parent.avatarConfiguration.nodeNameCamera, recursively: true) {
                parent.cameraPosition = cameraNode.position
            }
            if let meshNode = sceneView.scene?.rootNode.childNode(withName: parent.avatarConfiguration.nodeNameMesh, recursively: true) {
                parent.meshPosition = meshNode.position
                parent.meshRotation = meshNode.eulerAngles
                parent.meshScale = meshNode.scale
            }
        }

        func applyMaterial(to node: SCNNode, textureName: String) {
            let loadedTexture = SKTexture(imageNamed: textureName)
            let textureMaterial = SCNMaterial()
            textureMaterial.diffuse.contents = loadedTexture
            
            if let meshNode = node.childNode(withName: parent.avatarConfiguration.nodeNameMesh, recursively: true) {
                meshNode.geometry?.materials = [textureMaterial]
            }
        }

        // SCNSceneRendererDelegate method
        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            updateTransforms()
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

        func focusCameraOnHead() {
            guard let sceneView = sceneView else { return }
            guard let cameraNode = sceneView.scene?.rootNode.childNode(withName: parent.avatarConfiguration.nodeNameCamera, recursively: true),
                  let headNode = sceneView.scene?.rootNode.childNode(withName: parent.avatarConfiguration.nodeNameHead, recursively: true) else {
                return
            }

            // Position the camera relative to the head node
            let headPosition = headNode.worldPosition
            cameraNode.position = SCNVector3(headPosition.x, headPosition.y, headPosition.z + 0.5)

            // Make the camera look at the head node
            let lookAtConstraint = SCNLookAtConstraint(target: headNode)
            lookAtConstraint.isGimbalLockEnabled = true
            cameraNode.constraints = [lookAtConstraint]
        }

        func setupNodeTransformations(node: SCNNode) {
            let scaleFactor = parent.avatarConfiguration.containerHeight / 100
            node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
            node.position = parent.avatarConfiguration.initialPosition
            node.eulerAngles = parent.avatarConfiguration.initialEulerAngles
        }

        private func startContinuousRotation() {
            DispatchQueue.main.asyncAfter(deadline: .now() + .random(in: 2...5)) {
                self.continuousHeadMovement()
            }
        }

        private func continuousHeadMovement() {
            guard let sceneView = sceneView else { return }
            guard let headNode = sceneView.scene?.rootNode.childNode(withName: parent.avatarConfiguration.nodeNameHead, recursively: true) else { return }

            var angle = Float.random(in: -10...10)
            if abs(currentHeadAngle + angle) > 15 {
                angle *= -1
            }
            
            currentHeadAngle += angle
            let rotateAction = SCNAction.rotateBy(x: 0, y: CGFloat(GLKMathDegreesToRadians(angle)), z: 0, duration: 1)

            headNode.runAction(rotateAction) {
                self.startContinuousRotation()
            }
        }

        func moveHead(to direction: HeadDirection, degrees: Float = 15) {
            guard let sceneView = sceneView else { return }
            guard let headNode = sceneView.scene?.rootNode.childNode(withName: parent.avatarConfiguration.nodeNameHead, recursively: true) else { return }

            let angle: CGFloat
            switch direction {
            case .left:
                angle = CGFloat(GLKMathDegreesToRadians(degrees))
            case .right:
                angle = CGFloat(GLKMathDegreesToRadians(-degrees))
            }
            
            let rotateAction = SCNAction.rotateBy(x: 0, y: angle, z: 0, duration: 2)
            headNode.runAction(rotateAction)
        }
        
        func performHeadNod() {
            guard let sceneView = sceneView else { return }
            guard let headNode = sceneView.scene?.rootNode.childNode(withName: parent.avatarConfiguration.nodeNameHead, recursively: true) else { return }

            let nodDown = SCNAction.rotateBy(x: CGFloat(GLKMathDegreesToRadians(10)), y: 0, z: 0, duration: 0.5)
            let nodUp = SCNAction.rotateBy(x: CGFloat(GLKMathDegreesToRadians(-10)), y: 0, z: 0, duration: 0.5)
            let nodSequence = SCNAction.sequence([nodDown, nodUp, nodDown, nodUp, nodDown, nodUp])
            headNode.runAction(nodSequence)
        }

        func performHeadShaking() {
            guard let sceneView = sceneView else { return }
            guard let headNode = sceneView.scene?.rootNode.childNode(withName: parent.avatarConfiguration.nodeNameHead, recursively: true) else { return }

            let nodDown = SCNAction.rotateBy(x: 0, y: CGFloat(GLKMathDegreesToRadians(10)), z: 0, duration: 0.5)
            let nodUp = SCNAction.rotateBy(x: 0, y: CGFloat(GLKMathDegreesToRadians(-10)), z: 0, duration: 0.5)
            let nodSequence = SCNAction.sequence([nodDown, nodUp, nodDown, nodUp, nodDown, nodUp])
            headNode.runAction(nodSequence)
        }
        
        enum HeadDirection {
            case left
            case right
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        context.coordinator.setup(sceneView: sceneView)
        
        // Load the robot.scn file
        guard let scene = SCNScene(named: "robot.scn") else {
            fatalError("Unable to find robot.scn")
        }
        
        sceneView.scene = scene
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        
        // Center the mesh in the scene, scale it appropriately, and rotate it to face the back
        if let node = scene.rootNode.childNode(withName: avatarConfiguration.nodeNameRoot, recursively: true) {
            context.coordinator.setupNodeTransformations(node: node)
            context.coordinator.applyMaterial(to: node, textureName: avatarConfiguration.textureName)
        }
        
        // Print the node names and check for morphers
        context.coordinator.printNodeNamesAndMorphers(scene.rootNode)
        
        // Initialize shape key animator
        context.coordinator.initializeShapeKeyAnimatorIfNeeded()

        // Focus the camera on the head
        //context.coordinator.focusCameraOnHead()
        
        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.initializeShapeKeyAnimatorIfNeeded()
    }
}

extension Notification.Name {
    static let avatarChangeShapeKey = Notification.Name("avatarChangeShapeKey")
    static let avatarReadText = Notification.Name("avatarReadText")
    static let avatarMoveHeadLeft = Notification.Name("avatarMoveHeadLeft")
    static let avatarMoveHeadRight = Notification.Name("avatarMoveHeadRight")
    static let avatarPerformHeadNod = Notification.Name("avatarPerformHeadNod")
    static let avatarPerformHeadShaking = Notification.Name("avatarPerformHeadShaking")
}
