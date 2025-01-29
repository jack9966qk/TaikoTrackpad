//
//  TaikoShape.swift
//  TaikoTrackpad
//
//  Created by Jack on 2021/8/13.
//

import SwiftUI

private extension TaikoInput {
	var displayColor: Color {
		switch self {
		case .leftDon, .rightDon: return .red
		case .leftKa, .rightKa: return .blue
		}
	}
}

struct TaikoShape: Shape {
	var params = AppConfig.shared.taikoShapeParams

	func path(in rect: CGRect) -> Path {
		var path = Path()
		let center = CGPoint(x: rect.width * params.center.x,
							 y: rect.height * params.center.y)
		let radius = rect.width * params.radius
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
		}.onReceive(TouchpadListener.shared.taikoEventPublisher) { update in
			eventHistory.append(update)
		}
    }
}

struct TaikoShape_Previews: PreviewProvider {
    static var previews: some View {
        TaikoShape()
    }
}
