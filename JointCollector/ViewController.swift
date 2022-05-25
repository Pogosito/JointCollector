//
//  ViewController.swift
//  JointCollector
//
//  Created by Pogos Anesyan on 11.05.2022.
//

import Cocoa
import Vision
import Dispatch

final class ViewController: NSViewController {

	// MARK: - @IBOutlets

	@IBOutlet weak var videoPathField: NSTextField!
	@IBOutlet weak var saveAsFilePath: NSTextField!

	// MARK: - Private properties

	private let videoProcessWorker: VideoProcessWorkerProtocol = VideoProcessWorker()
	private let bodyPoseDetectionWorker: BodyPoseDetectable = BodyPoseDetectionWorker()
	private let skeletonConverterWorker: SkeletonConvertible = SkeletonConverterWorker()
	private let jointsSaverWorker: JointsSavable = JointsSaverWorker()

	private var desiredJoints: Set<VNHumanBodyPoseObservation.JointName> = {
		var desiredJoints: Set<VNHumanBodyPoseObservation.JointName> = []
		desiredJoints.reserveCapacity(18)
		return desiredJoints
	}()

	private let jointsDict: [Int: VNHumanBodyPoseObservation.JointName] = [
		// Other
		0: .rightEye,
		1: .leftEye,
		2: .rightEar,
		3: .leftEar,
		4: .nose,
		5: .neck,
		6: .root,

		// right leg
		7: .rightHip,
		8: .rightKnee,
		9: .rightAnkle,

		// left leg
		10: .leftHip,
		11: .leftKnee,
		12: .leftAnkle,

		// right arm
		13: .rightShoulder,
		14: .rightElbow,
		15: .rightWrist,

		// left arm
		16: .leftShoulder,
		17: .leftElbow,
		18: .leftWrist
	]

	private lazy var chooseFilePanel: NSOpenPanel = {
		let dialog = NSOpenPanel()
		dialog.showsResizeIndicator = true;
		dialog.showsHiddenFiles = false;
		dialog.canChooseDirectories = true;
		dialog.canCreateDirectories = true;
		dialog.allowsMultipleSelection = false;
		dialog.delegate = self
		return dialog
	}()

	private let savePanel: NSSavePanel = {
		let savePanel = NSSavePanel()
		savePanel.canCreateDirectories = true
		return savePanel
	}()

	override func viewWillAppear() {
		super.viewWillAppear()
		configureWindow()
	}
}

// MARK: - NSOpenSavePanelDelegate

extension ViewController: NSOpenSavePanelDelegate {

	func panel(_ sender: Any, shouldEnable url: URL) -> Bool {
		let pathExtension = url.pathExtension
		return pathExtension == "mp4" || pathExtension == "mov" || pathExtension == ""
	}
}

// MARK: - @IBAction

extension ViewController {

	@IBAction func selectVideo(sender: AnyObject) {
		open(panel: chooseFilePanel, filed: videoPathField)
	}

	@IBAction func browseFiles(sender: AnyObject) {
		open(panel: savePanel, filed: saveAsFilePath)
	}

	@IBAction func processVideo(sender: AnyObject) {
		// Добавить обработку, когда не выбрали ни одной точки
		Task {
			let headers = configureHeaders()
			let selectedFilePath = URL(fileURLWithPath: videoPathField.stringValue)
			let joints = await getJointsFromVideo(url: selectedFilePath)
			jointsSaverWorker.save(joints: joints, with: headers,
									in: URL(fileURLWithPath: saveAsFilePath.stringValue))
		}
	}

	@IBAction func selectJoint(sender: NSButton) {
		guard let senderIdString = sender.identifier?.rawValue,
			  let senderId = Int(senderIdString),
			  let safeJoint = jointsDict[senderId] else {
			fatalError()
		}

		if sender.state == .on {
			desiredJoints.insert(safeJoint)
		} else {
			desiredJoints.remove(safeJoint) 
		}
	}
}

// MARK: - Private methods

private extension ViewController {

	func open(panel: NSSavePanel, filed: NSTextField) {
		if (panel.runModal() == NSApplication.ModalResponse.OK) {
			let result = panel.url
			if (result != nil) {
				guard let stringPath = result?.path else {
					print("Путь до файла не найден")
					return
				}
				filed.stringValue = stringPath
			}
		} else {
			return
		}
	}

	func configureHeaders() -> [String] {
		var headers: [String] = []
		for joint in Constants.Joints.all {
			if desiredJoints.contains(joint) {
				let joint = joint.rawValue.rawValue
				headers.append(joint + "_x")
				headers.append(joint + "_y")
			}
		}
		return headers
	}

	func getJointsFromVideo(url: URL) async -> [[Double]] {
		var jointsInFrame: [[Double]] = []
//		for isReversed in [false, true] {
//			for k in [0.5, 0.6, 0.7, 0.8, 0.9, 1, 1.1, 1.2, 1.3, 1.4, 1.5] {
				videoProcessWorker.processEveryFrameOfVideo(url: url) { buffer, time in
					let ciImage = CIImage(cvImageBuffer: buffer)
					let cgImage = ciImage.convertToCGImage()
					let result = bodyPoseDetectionWorker.makeHumanBodyPoseRequest(for: cgImage!, multiplier: 1, isReversed: false)
					let centeredResult = skeletonConverterWorker.moveSkeletonToTheCenterOfTheFrame(result)
					let relativeRoot = skeletonConverterWorker.getSkeletonJointsPositionRelativeRoot(joints: centeredResult)

					var jointsArray: [Double] = []
					for joint in Constants.Joints.all {
						guard desiredJoints.contains(joint) else { continue }

						guard let safeJoint = relativeRoot[joint] else {
							fatalError("Не видно точки \(joint)")
						}
						jointsArray.append(safeJoint.x)
						jointsArray.append(safeJoint.y)

					}
					jointsInFrame.append(jointsArray)
//				}
//				print("✅ Собрано для \(k)")
//			}
//			print("-------------------------")
		}
		return jointsInFrame
	}

	func configureWindow() {
		let windowSize = NSSize(width: 500, height: 500)
		title = Constants.appName
		view.window?.title = Constants.appName
		view.window?.minSize = windowSize
		view.window?.maxSize = windowSize
	}
}
