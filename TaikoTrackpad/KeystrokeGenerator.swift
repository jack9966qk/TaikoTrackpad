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

private let EventSource =
	CGEventSource(stateID: CGEventSourceStateID.hidSystemState)

enum KeystrokeGenerator {
	private struct KeyCodeContext {
		let keyDownEvent: CGEvent
		let keyUpEvent: CGEvent
		let keyDownQueue: DispatchQueue
		let keyUpQueue: DispatchQueue

		init(keyCode: KeyCode) {
			self.keyDownEvent = CGEvent(keyboardEventSource: EventSource,
										virtualKey: keyCode.rawValue,
										keyDown: true)!
			self.keyUpEvent = CGEvent(keyboardEventSource: EventSource,
									  virtualKey: keyCode.rawValue,
									  keyDown: false)!
			self.keyDownQueue = DispatchQueue(label: "Key down for keyCode: \(String(describing: keyCode))",
											  qos: .userInteractive)
			self.keyUpQueue = DispatchQueue(label: "Key up for keyCode: \(String(describing: keyCode))",
											qos: .userInteractive)
		}
	}

	private static let eventTapLocation = CGEventTapLocation.cghidEventTap
	private static let dContext = KeyCodeContext(keyCode: .d)
	private static let fContext = KeyCodeContext(keyCode: .f)
	private static let jContext = KeyCodeContext(keyCode: .j)
	private static let kContext = KeyCodeContext(keyCode: .k)

	private static func context(for input: TaikoInput) -> KeyCodeContext {
		switch input {
		case .leftKa: return dContext
		case .leftDon: return fContext
		case .rightDon: return jContext
		case .rightKa: return kContext
		}
	}

	static func pressAndRelease(_ input: TaikoInput) {
		let context = self.context(for: input)
		context.keyDownQueue.async {
			context.keyDownEvent.post(tap: self.eventTapLocation)
			context.keyUpEvent.post(tap: self.eventTapLocation)
//			context.keyUpQueue.asyncAfter(deadline: .now() + (2 / 1000)) {
//				context.keyUpEvent.post(tap: self.eventTapLocation)
//			}
		}
	}
}
