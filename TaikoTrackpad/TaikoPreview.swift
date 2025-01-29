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
		let aspectRatio = touch.deviceAspectRatio
		let transformedRadius = TaikoShapeParams.radius * aspectRatio
		let transformedPoint: CGPoint = {
			let xDeltaFromMid = touch.normalizedX - 0.5
			return .init(x: 0.5 + xDeltaFromMid * aspectRatio,
						 y: touch.normalizedY)
		}()

		let isRightSide = transformedPoint.x > TaikoShapeParams.center.x
		let isInside: Bool = {
			let xDelta = transformedPoint.x - TaikoShapeParams.center.x
			let yDelta = transformedPoint.y - TaikoShapeParams.center.y
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

private extension TaikoInput {
	var displayColor: Color {
		switch self {
		case .leftDon, .rightDon: return .red
		case .leftKa, .rightKa: return .blue
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
	private let touchPointDiameter: CGFloat = 20

    var body: some View {
		ZStack {
			GeometryReader { proxy in
				TaikoShape().fill()

				ForEach(eventHistory) { event in
					let input = event.input
					let touch = event.touch
					Circle()
						.foregroundColor(input.displayColor)
						.frame(
							width: touchPointDiameter,
							height: touchPointDiameter)
						.offset(
							x: proxy.size.width * touch.normalizedX
								- touchPointDiameter / 2.0,
							y: proxy.size.height * touch.normalizedY
								- touchPointDiameter / 2.0)
				}
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
