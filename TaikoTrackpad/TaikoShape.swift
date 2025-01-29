//
//  TaikoShape.swift
//  TaikoTrackpad
//
//  Created by Jack on 2021/8/13.
//

import SwiftUI

enum TaikoShapeParams {
	static let center = CGPoint(x: 0.5, y: 1.0)
	static let radius: CGFloat = 0.45
}

enum TaikoInput {
	case leftDon
	case leftKa
	case rightDon
	case rightKa

	static func mapped(from touch: Touch) -> Self {
		let xDiffFromMid = touch.normalizedX - 0.5
		let aspectRatio = touch.deviceAspectRatio
		let transformedRadius = TaikoShapeParams.radius * aspectRatio
		let transformedPoint = CGPoint(x: 0.5 + xDiffFromMid * aspectRatio,
									   y: touch.normalizedY)
		let rightSide = transformedPoint.x > TaikoShapeParams.center.x
		let xDiff = transformedPoint.x - TaikoShapeParams.center.x
		let yDiff = transformedPoint.y - TaikoShapeParams.center.y
		let dist = sqrt(xDiff * xDiff + yDiff * yDiff)
		let inside = dist < transformedRadius
		switch (inside, rightSide) {
		case (true, true):
			return .rightDon
		case (false, true):
			return .rightKa
		case (true, false):
			return .leftDon
		case (false, false):
			return .leftKa
		}
	}
}

struct TaikoShape: Shape {
	func path(in rect: CGRect) -> Path {
		var path = Path()
		let center = CGPoint(x: rect.width * TaikoShapeParams.center.x,
							 y: rect.height * TaikoShapeParams.center.y)
		let radius = rect.width * TaikoShapeParams.radius
		path.move(to: center)
		path.addArc(center: center,
					radius: radius,
					startAngle: .degrees(360),
					endAngle: .degrees(0),
					clockwise: true)
		path.closeSubpath()
		return path
	}
}

struct TaikoPreview: View {
	@State private var eventHistory: [TaikoTouchEvent] = []
	private let touchViewLength: CGFloat = 20

    var body: some View {
		ZStack {
			GeometryReader { proxy in
				TaikoShape().fill()

				ForEach(eventHistory) { event in
					let input = event.input
					let touch = event.touch
					let don = input == .leftDon || input == .rightDon
					Circle()
						.foregroundColor(don ? Color.red : Color.blue)
						.frame(width: touchViewLength, height: touchViewLength)
						.offset(
							x: proxy.size.width * touch.normalizedX
								- touchViewLength / 2.0,
							y: proxy.size.height * touch.normalizedY
								- touchViewLength / 2.0
						)
				}
//				if let point = tapPoint {
//
//				}
//				if let input = input {
//					VStack {
//						Text(String.init(describing: input))
//						Spacer()
//					}
//				}
			}
		}.onReceive(TaikoEventPublisher) { update in
			eventHistory.append(update)
		}
    }
}

struct TaikoShape_Previews: PreviewProvider {
    static var previews: some View {
        TaikoShape()
    }
}
