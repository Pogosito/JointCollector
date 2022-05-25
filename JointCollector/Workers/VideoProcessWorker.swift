//
//  VideoProcessWorker.swift
//  JointCollector
//
//  Created by Pogos Anesyan on 11.05.2022.
//

import AVFoundation

/// Тип, что может обрабатывать видео
protocol VideoProcessWorkerProtocol: AnyObject {

	/// Применить обработчик для каждого кадра видео
	/// - Parameters:
	///   - url: Путь к видео
	///   - completion: Обработчик
	func processEveryFrameOfVideo(url: URL, completion: (CVImageBuffer, Float64) -> ())
}

/// Воркер для обработки видео
final class VideoProcessWorker {}

// MARK: - VideoProcessWorkerProtocol

extension VideoProcessWorker: VideoProcessWorkerProtocol {

	func processEveryFrameOfVideo(url: URL, completion: (CVImageBuffer, Float64) -> ()) {
		let asset = AVAsset(url: url)

		let outputSettings = [
			String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: kCVPixelFormatType_32BGRA)
		]

		guard let safeReader = try? AVAssetReader(asset: asset) else {
			fatalError("Can't create AVAssetReader")
		}

		guard let safeVideoTrack = asset.tracks(withMediaType: .video).first else {
			fatalError("Resource does not contain video track")
		}

		let trackReaderOutput = AVAssetReaderTrackOutput(track: safeVideoTrack,
														 outputSettings: outputSettings)

		safeReader.add(trackReaderOutput)
		safeReader.startReading()

		while let sampleBuffer = trackReaderOutput.copyNextSampleBuffer() {
			let presTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer)
			let frameTime = CMTimeGetSeconds(presTime);

			if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
				completion(imageBuffer, frameTime)
			} else {
				fatalError("Can not retrieve CVImageBuffer from your frame")
			}
		}
	}
}
