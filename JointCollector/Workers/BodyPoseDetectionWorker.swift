//
//  BodyPoseDetectionWorker.swift
//  JointCollector
//
//  Created by Pogos Anesyan on 11.05.2022.
//

import Vision

/// Тип, что может найти скелет человека
protocol BodyPoseDetectable: AnyObject {

	///   - multiplier: Множитель, на который умножаем координаты суставов
	func makeHumanBodyPoseRequest(for frame: CGImage, multiplier: CGFloat, isReversed: Bool) -> [JointName: CGPoint]
}

final class BodyPoseDetectionWorker {

	private let humanBodyPoseRequest = VNDetectHumanBodyPoseRequest()
}

// MARK: - BodyPoseDetectable

extension BodyPoseDetectionWorker: BodyPoseDetectable {

	func makeHumanBodyPoseRequest(for frame: CGImage, multiplier: CGFloat, isReversed: Bool) -> [JointName: CGPoint] {
		var result: [JointName: CGPoint] = [:]
		let visionRequestHandler = VNImageRequestHandler(cgImage: frame, orientation: .up)
		
		try? visionRequestHandler.perform([humanBodyPoseRequest])

		let observation = humanBodyPoseRequest.results?.first as? VNHumanBodyPoseObservation
		guard var recognizedPoints = try? observation?.recognizedPoints(.all) else { return [:] }

		if isReversed {
			reverse(points: &recognizedPoints)
		}

		for point in recognizedPoints {
			let pointLocation = point.value.location
			result[point.key] = CGPoint(x: isReversed ? 1 - pointLocation.x * multiplier : pointLocation.x * multiplier,
										y: pointLocation.y * multiplier)
		}

		return result
	}
}

// MARK: - Private methods

private extension BodyPoseDetectionWorker {

	func reverse(
		points: inout [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
	) {

		var reversed: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint] = [:]

		reversed[.rightEar] = points[.leftEar]
		reversed[.leftEar] = points[.rightEar]

		reversed[.rightEye] = points[.leftEye]
		reversed[.leftEye] = points[.rightEye]
	
		reversed[.rightWrist] = points[.leftWrist]
		reversed[.leftWrist] = points[.rightWrist]

		reversed[.rightElbow] = points[.leftElbow]
		reversed[.leftElbow] = points[.rightElbow]

		reversed[.rightShoulder] = points[.leftShoulder]
		reversed[.leftShoulder] = points[.rightShoulder]

		reversed[.rightAnkle] = points[.leftAnkle]
		reversed[.leftAnkle] = points[.rightAnkle]

		reversed[.rightHip] = points[.leftHip]
		reversed[.leftHip] = points[.rightHip]

		reversed[.rightKnee] = points[.leftKnee]
		reversed[.leftKnee] = points[.rightKnee]

		reversed[.root] = points[.root]
		reversed[.neck] = points[.neck]
		reversed[.nose] = points[.nose]

		points = reversed
	}
}
