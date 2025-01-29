//
//  Config.swift
//  TaikoTrackpad
//
//  Created by Jack on 2025/1/29.
//

import Foundation
import Combine

class AppConfig: ObservableObject {
	struct TaikoShapeParams {
		var center = CGPoint(x: 0.5, y: 1.0)
		var radius: CGFloat = 0.45
	}

	@Published var taikoShapeParams = TaikoShapeParams()

	private init() {}
}

extension AppConfig {
	static let shared = AppConfig()
}




