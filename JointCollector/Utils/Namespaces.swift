//
//  Namespaces.swift
//  JointCollector
//
//  Created by Pogos Anesyan on 11.05.2022.
//

import Vision

// MARK: - Typealias

typealias JointName = VNHumanBodyPoseObservation.JointName
typealias JointsGroupName = VNHumanBodyPoseObservation.JointsGroupName

// MARK: - Constants

enum Constants {

	static let appName = "JointsCollector"

	enum Joints {

		static let all: [JointName] = [
			.rightEye,
			.leftEye,
			.rightEar,
			.leftEar,
			.nose,
			.neck,
			.root,
			.rightHip,
			.rightKnee,
			.rightAnkle,
			.leftHip,
			.leftKnee,
			.leftAnkle,
			.rightShoulder,
			.rightElbow,
			.rightWrist,
			.leftShoulder,
			.leftElbow,
			.leftWrist
		]
	}
}
