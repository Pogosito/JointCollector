//
//  JointsSavable.swift
//  JointCollector
//
//  Created by Pogos Anesyan on 11.05.2022.
//

import Cocoa
import TabularData

/// Тип, что  может сохранить суставы скелета
protocol JointsSavable {

	/// Сохранить суставы скелета в виде таблицы
	/// - Parameters:
	///   - joints: Суставы
	///   - headers: Заголовки таблицы
	///   - fileUrl: Путь до файла
	func save(joints: [[Double]], with headers: [String], in fileUrl: URL)
}

struct JointsSaverWorker {}

// MARK: - JointsSavable

extension JointsSaverWorker: JointsSavable {

	func save(joints: [[Double]], with headers: [String], in directoryPath: URL) {

		let transposedJoints = transpose(joints)

		var dataFrame: DataFrame = [:]
		for (index, header) in headers.enumerated() {
			dataFrame[header] = transposedJoints[index]
		}

		do {
			try dataFrame.writeCSV(to: directoryPath)
		} catch let error {
			print(error)
		}

		print("Save success: \(directoryPath)")
	}
}

// MARK: - Private methods

private extension JointsSaverWorker {

	func transpose(_ matrix: [[Double]]) -> [[Double]] {
		var result: [[Double]] = []
		let lengthOfRow = matrix.first?.count ?? 0
		var helper: [Double] = []
		for i in 0..<lengthOfRow {
			for j in 0..<matrix.count {
				helper.append(matrix[j][i])
			}
			result.append(helper)
			helper = []
		}
		return result
	}
}
