/// Taken and modified from
/// https://stackoverflow.com/a/61888862
/// https://gist.github.com/zrzka/224a18517649247a5867fbe65dbd5ae0

import AppKit

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
