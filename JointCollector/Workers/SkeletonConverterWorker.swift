//
//  SkeletonModel.swift
//  JointCollector
//
//  Created by Pogos Anesyan on 11.05.2022.
//

import Cocoa

/// Тип, что может преобразовывать скелет
protocol SkeletonConvertible {

	/// Переместить скелет в центр фрейма, где был найден
	/// - Parameter joints: Суставы скелета с координатами
	/// - Returns: Координаты суставов скелета, перемещенного в центр фрейма
	/// - Note: Скелет считается перемещенным в центр, если после перемещения скелета `root` сустав оказывается в центре фрейма
	func moveSkeletonToTheCenterOfTheFrame(_ joints: [JointName: CGPoint]) -> [JointName: CGPoint]

	/// Получить координаты суставов скелета относительно `root` точки
	/// - Parameters:
	///   - joints: Суставы скелета с координатами
	/// - Returns: Координаты суставов скелета относительно от `root` точки
	func getSkeletonJointsPositionRelativeRoot(joints: [JointName: CGPoint]) -> [JointName: CGPoint]
}

struct SkeletonConverterWorker {}

// MARK: - SkeletonConverterProtocol

extension SkeletonConverterWorker: SkeletonConvertible {

	func moveSkeletonToTheCenterOfTheFrame(_ joints: [JointName: CGPoint]) -> [JointName: CGPoint] {
		var centeredJoints: [JointName: CGPoint] = [:]

		guard let rootPoint = joints[.root] else {
			print("Can't find root")
			return [:]
		}

		let xDiff = 0.5 - rootPoint.x
		let yDiff = 0.5 - rootPoint.y

		for joint in joints {
			var jointLocationCopy = joint.value
			jointLocationCopy.x = jointLocationCopy.x + xDiff
			jointLocationCopy.y = jointLocationCopy.y + yDiff

			centeredJoints[joint.key] = jointLocationCopy
		}

		return centeredJoints
	}

	func getSkeletonJointsPositionRelativeRoot(joints: [JointName: CGPoint]) -> [JointName: CGPoint] {

		var relativePointsOfJoints: [JointName: CGPoint] = [:]

		guard let rootPosition = joints[.root] else {
			fatalError("Не вижу рут")
		}

		for joint in Constants.Joints.all {
			guard let absoluteJointPosition = joints[joint] else { continue }

			let x = -rootPosition.x + absoluteJointPosition.x
			let y = -rootPosition.y + absoluteJointPosition.y

			let relativePoint = CGPoint(x: x, y: y)

			relativePointsOfJoints[joint] = relativePoint
		}

		return relativePointsOfJoints
	}
}
