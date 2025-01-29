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
	var params: AppConfig.TaikoShapeParams

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
	@ObservedObject var appConfig: AppConfig
	@State private var eventHistory: [TaikoTouchEvent] = []
	@State private var highlightedEvent: TaikoTouchEvent?
	private let touchPointDiameter: CGFloat = 20

    var body: some View {
		ZStack {
			GeometryReader { proxy in
				TaikoShape(params: appConfig.taikoShapeParams).fill()

				ForEach(eventHistory) { event in
					let input = event.input
					let touch = event.touch
					let highlighted =
						highlightedEvent.map { $0.id == event.id } ?? false
					let diameter = highlighted
						? touchPointDiameter * 1.5
						: touchPointDiameter
					Circle()
						.foregroundColor(input.displayColor)
						.brightness(highlighted ? 0 : -0.5)
						.frame(width: diameter, height: diameter)
						.offset(
							x: proxy.size.width * touch.normalizedX
								- diameter / 2.0,
							y: proxy.size.height * touch.normalizedY
								- diameter / 2.0)
				}
			}
		}.onReceive(TouchpadListener.shared.taikoEventPublisher) { update in
			eventHistory.append(update)
			// Set and unset the highlighted event to play some transient
			// animation.
			highlightedEvent = update
			withAnimation {
				highlightedEvent = nil
			}
		}
    }
}

struct TaikoShape_Previews: PreviewProvider {
    static var previews: some View {
		TaikoShape(params: .init())
    }
}
