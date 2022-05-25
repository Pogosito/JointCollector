//
//  Extensions+GlobalFunction.swift
//  JointCollector
//
//  Created by Pogos Anesyan on 11.05.2022.
//

import Cocoa
import Vision

// MARK: - CIImage

extension CIImage {

	/// Конвертирует `CIImage` в `CGImage`
	func convertToCGImage() -> CGImage? {
		let context = CIContext(options: nil)
		guard let safeCGImage = context.createCGImage(self, from: self.extent) else { return nil }
		return safeCGImage
	}
}
