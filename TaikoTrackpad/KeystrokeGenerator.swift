//
//  KeystrokeGenerator.swift
//  TaikoTrackpad
//
//  Created by Jack on 2021/8/13.
//

import Foundation

enum KeyCode: UInt16 {
	case zero = 29
	case d = 2
	case f = 3
	case j = 38
	case k = 40
}

private extension DispatchQueue {
	convenience init(label: String, qos: DispatchQoS) {
		self.init(label: label,
				  qos: qos,
				  attributes: [.concurrent],
				  autoreleaseFrequency: .inherit,
				  target: nil)
	}
}

struct KeystrokeGenerator {
	fileprivate struct KeyCodeContext {
		private static let eventSource =
			CGEventSource(stateID: CGEventSourceStateID.hidSystemState)

		let keyDownEvent: CGEvent
		let keyUpEvent: CGEvent
		// Unsure if it is really better (e.g. less latency) to have separate
		// dispatch queues for each keyDown and keyUp.
		let keyDownQueue: DispatchQueue
		let keyUpQueue: DispatchQueue

		init(keyCode: KeyCode) {
			keyDownEvent = CGEvent(keyboardEventSource: Self.eventSource,
								   virtualKey: keyCode.rawValue,
								   keyDown: true)!
			keyUpEvent = CGEvent(keyboardEventSource: Self.eventSource,
								 virtualKey: keyCode.rawValue,
								 keyDown: false)!
			keyDownQueue = DispatchQueue(
				label: "Key down for keyCode: \(keyCode)",
				qos: .userInteractive)
			keyUpQueue = DispatchQueue(
				label: "Key up for keyCode: \(keyCode)",
				qos: .userInteractive)
		}
	}

	private let dContext = KeyCodeContext(keyCode: .d)
	private let fContext = KeyCodeContext(keyCode: .f)
	private let jContext = KeyCodeContext(keyCode: .j)
	private let kContext = KeyCodeContext(keyCode: .k)

	private init() {}
}

extension KeystrokeGenerator {
	static let shared = KeystrokeGenerator()
}

extension KeystrokeGenerator {
	private func context(for input: TaikoInput) -> KeyCodeContext {
		switch input {
		case .leftKa: return dContext
		case .leftDon: return fContext
		case .rightDon: return jContext
		case .rightKa: return kContext
		}
	}

	private func pressAndRelease(_ context: KeyCodeContext) {
		let eventTapLocation = CGEventTapLocation.cghidEventTap
		context.keyDownQueue.async {
			context.keyDownEvent.post(tap: eventTapLocation)
			context.keyUpEvent.post(tap: eventTapLocation)
//			context.keyUpQueue.asyncAfter(deadline: .now() + (2 / 1000)) {
//				context.keyUpEvent.post(tap: eventTapLocation)
//			}
		}
	}

	func pressAndRelease(_ input: TaikoInput) {
		pressAndRelease(context(for: input))
	}
}

