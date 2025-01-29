/// Taken and modified from
/// https://stackoverflow.com/a/61888862
/// https://gist.github.com/zrzka/224a18517649247a5867fbe65dbd5ae0

import SwiftUI
import AppKit

protocol AppKitTouchesViewDelegate: AnyObject {
	// Provides `.touching` touches only.
	func touchesView(
		_ view: AppKitTouchesView,
		didUpdateTouchingTouches touches: Set<NSTouch>)
}

final class AppKitTouchesView: NSView {
	weak var delegate: AppKitTouchesViewDelegate?

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		allowedTouchTypes = [.direct, .indirect]
		// We'd like to receive resting touches as well.
		wantsRestingTouches = true
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func handleTouches(with event: NSEvent) {
		// Get all `.touching` touches only (includes `.began`, `.moved` &
		// `.stationary`).
		let touches = event.touches(matching: .touching, in: self)
		// Forward them via delegate.
		delegate?.touchesView(self, didUpdateTouchingTouches: touches)
	}

	override func touchesBegan(with event: NSEvent) {
		handleTouches(with: event)
	}

	override func touchesEnded(with event: NSEvent) {
		handleTouches(with: event)
	}

	override func touchesMoved(with event: NSEvent) {
		handleTouches(with: event)
	}

	override func touchesCancelled(with event: NSEvent) {
		handleTouches(with: event)
	}
}

struct Touch: Identifiable {
	// `Identifiable` -> `id` is required for `ForEach` (see below).
	let id: Int
	// Normalized touch X position on a device (0.0 - 1.0).
	let normalizedX: CGFloat
	// Normalized touch Y position on a device (0.0 - 1.0).
	let normalizedY: CGFloat
	let deviceAspectRatio: CGFloat

	init(_ nsTouch: NSTouch) {
		self.normalizedX = nsTouch.normalizedPosition.x
		// `NSTouch.normalizedPosition.y` is flipped -> 0.0 means bottom. But
		// the `Touch` struct is meant to be used with the SwiftUI -> flip it.
		self.normalizedY = 1.0 - nsTouch.normalizedPosition.y
		let size = nsTouch.deviceSize
		self.deviceAspectRatio = size.width / size.height
		self.id = nsTouch.hash
	}
}

struct TouchesView: NSViewRepresentable {
	// Up to date list of touching touches.
	@Binding var touches: [Touch]

	func updateNSView(_ nsView: AppKitTouchesView, context: Context) {}

	func makeNSView(context: Context) -> AppKitTouchesView {
		let view = AppKitTouchesView()
		view.delegate = context.coordinator
		return view
	}

	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	class Coordinator: NSObject, AppKitTouchesViewDelegate {
		let parent: TouchesView

		init(_ view: TouchesView) {
			self.parent = view
		}

		func touchesView(
			_ view: AppKitTouchesView,
			didUpdateTouchingTouches touches: Set<NSTouch>
		) {
			parent.touches = touches.map(Touch.init)
		}
	}
}

struct TrackpadView: View {
	private let touchViewLength: CGFloat = 20

	@State var touches: [Touch] = []

	var body: some View {
		ZStack {
			GeometryReader { proxy in
				TouchesView(touches: self.$touches)

				ForEach(self.touches) { touch in
					Circle()
						.foregroundColor(Color.green)
						.frame(width: touchViewLength, height: touchViewLength)
						.offset(
							x: proxy.size.width * touch.normalizedX
								- touchViewLength / 2.0,
							y: proxy.size.height * touch.normalizedY
								- touchViewLength / 2.0
						)
				}
			}
		}
	}
}
