//
//  TaikoInput.swift
//  TaikoTrackpad
//
//  Created by Jack on 2025/1/29.
//

import Foundation

enum TaikoInput {
	case leftDon
	case leftKa
	case rightDon
	case rightKa
}

extension TaikoInput {
	static func mapped(
		from touch: Touch, appConfig: AppConfig = .shared
	) -> Self {
		let aspectRatio = touch.deviceAspectRatio
		let taikoShapeParams = appConfig.taikoShapeParams
		let transformedRadius = taikoShapeParams.radius * aspectRatio
		let transformedPoint: CGPoint = {
			let xDeltaFromMid = touch.normalizedX - 0.5
			return .init(x: 0.5 + xDeltaFromMid * aspectRatio,
						 y: touch.normalizedY)
		}()

		let isRightSide = transformedPoint.x > taikoShapeParams.center.x
		let isInside: Bool = {
			let xDelta = transformedPoint.x - taikoShapeParams.center.x
			let yDelta = transformedPoint.y - taikoShapeParams.center.y
			let dist = sqrt(xDelta * xDelta + yDelta * yDelta)
			return dist < transformedRadius
		}()

		switch (isInside, isRightSide) {
		case (true, true): return .rightDon
		case (false, true): return .rightKa
		case (true, false): return .leftDon
		case (false, false): return .leftKa
		}
	}
}

