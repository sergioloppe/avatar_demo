//
//  ContentView.swift
//  AvatarDemo
//
//  Created by Sergio on 15.06.24.
//

import SwiftUI
import SceneKit
import SpriteKit

struct ContentView: View {
    @State private var cameraPosition: SCNVector3 = SCNVector3(0, 0, 5)
    @State private var meshPosition: SCNVector3 = SCNVector3(0, 0, 0)
    @State private var meshRotation: SCNVector3 = SCNVector3(0, 0, 0)
    @State private var meshScale: SCNVector3 = SCNVector3(0.2, 0.2, 0.2)

    var body: some View {
        ZStack {
            VStack {
                SceneViewContainer(cameraPosition: $cameraPosition, meshPosition: $meshPosition, meshRotation: $meshRotation, meshScale: $meshScale)
                    .frame(height: 200)
                
                Spacer()
                HStack {
                    Spacer()
                    Button("vrc_lowerlid_left") {
                        NotificationCenter.default.post(name: .changeShapeKey, object: "vrc_lowerlid_left")
                    }
                    .padding()
                    Spacer()
                    Button("vrc_blink_right") {
                        NotificationCenter.default.post(name: .changeShapeKey, object: "vrc_blink_right")
                    }
                    .padding()
                    Spacer()
                }
                .padding(.bottom, 20)
                VStack(alignment: .leading) {
                    Text("Camera Position: x: \(cameraPosition.x), y: \(cameraPosition.y), z: \(cameraPosition.z)")
                    Text("Mesh Position: x: \(meshPosition.x), y: \(meshPosition.y), z: \(meshPosition.z)")
                    Text("Mesh Rotation: x: \(meshRotation.x), y: \(meshRotation.y), z: \(meshRotation.z)")
                    Text("Mesh Scale: x: \(meshScale.x), y: \(meshScale.y), z: \(meshScale.z)")
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
            }
        }
    }
}

struct SceneViewContainer: UIViewRepresentable {
    @Binding var cameraPosition: SCNVector3
    @Binding var meshPosition: SCNVector3
    @Binding var meshRotation: SCNVector3
    @Binding var meshScale: SCNVector3

    class Coordinator: NSObject, SCNSceneRendererDelegate {
        var parent: SceneViewContainer
        var sceneView: SCNView?
        var shapeKeyAnimator: ShapeKeyAnimator?
        
        // Constants
        let nodeNameRoot = "root"
        let nodeNameMesh = "Mesh"
        let nodeNameCamera = "Camera.001"
        let nodeNameHead = "mixamorig_Head"

        init(parent: SceneViewContainer) {
            self.parent = parent
        }

        @objc func changeShapeKey(notification: NSNotification) {
            guard let shapeKey = notification.object as? String else { return }
            shapeKeyAnimator?.animateShapeKey(named: shapeKey)
        }

        func setup(sceneView: SCNView) {
            self.sceneView = sceneView
            sceneView.delegate = self
            NotificationCenter.default.addObserver(self, selector: #selector(changeShapeKey(notification:)), name: .changeShapeKey, object: nil)
        }

        func initializeShapeKeyAnimatorIfNeeded() {
            guard let sceneView = sceneView, let rootNode = sceneView.scene?.rootNode else { return }
            if shapeKeyAnimator == nil, let morpher = ShapeKeyAnimator.findMorpher(in: rootNode) {
                let targetNames = ["vrc_v_th", "vrc_v_ss", "vrc_v_sil", "vrc_v_rr", "vrc_v_pp", "vrc_v_ou", "vrc_v_oh", "vrc_v_nn", "vrc_v_kk", "vrc_v_ih", "vrc_v_ff", "vrc_v_ee", "vrc_v_dd", "vrc_v_ch", "vrc_v_aa", "vrc_lowerlid_right", "vrc_lowerlid_left", "vrc_blink_right", "vrc_blink_left"]
                self.shapeKeyAnimator = ShapeKeyAnimator(morpher: morpher, targetNames: targetNames)
            }
        }

        func updateTransforms() {
            guard let sceneView = sceneView else { return }
            if let cameraNode = sceneView.scene?.rootNode.childNode(withName: nodeNameCamera, recursively: true) {
                parent.cameraPosition = cameraNode.position
            }
            if let meshNode = sceneView.scene?.rootNode.childNode(withName: nodeNameMesh, recursively: true) {
                parent.meshPosition = meshNode.position
                parent.meshRotation = meshNode.eulerAngles
                parent.meshScale = meshNode.scale
            }
        }

        func applyMaterial(to node: SCNNode, textureName: String) {
            let loadedTexture = SKTexture(imageNamed: textureName)
            let textureMaterial = SCNMaterial()
            textureMaterial.diffuse.contents = loadedTexture
            
            if let meshNode = node.childNode(withName: "Mesh", recursively: true) {
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
            guard let cameraNode = sceneView.scene?.rootNode.childNode(withName: nodeNameCamera, recursively: true),
                  let headNode = sceneView.scene?.rootNode.childNode(withName: nodeNameHead, recursively: true) else {
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

        func setupNodeTransformations(node: SCNNode, containerHeight: CGFloat) {
            let scaleFactor = containerHeight / 100
            node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
            node.position = SCNVector3(0, 0, -scaleFactor * 1.23)
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
        if let node = scene.rootNode.childNode(withName: context.coordinator.nodeNameRoot, recursively: true) {
            context.coordinator.setupNodeTransformations(node: node, containerHeight: 300)
            context.coordinator.applyMaterial(to: node, textureName: "phong22")
        }
        
        // Print the node names and check for morphers
        context.coordinator.printNodeNamesAndMorphers(scene.rootNode)
        
        // Initialize shape key animator
        context.coordinator.initializeShapeKeyAnimatorIfNeeded()

        // Focus the camera on the head
        context.coordinator.focusCameraOnHead()
        
        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.initializeShapeKeyAnimatorIfNeeded()
    }
}

extension Notification.Name {
    static let changeShapeKey = Notification.Name("changeShapeKey")
}

#Preview {
    ContentView()
}
