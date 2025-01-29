//
//  GlobalEventListener.swift
//  TaikoTrackpad
//
//  Created by Jack on 2021/8/13.
//

import Foundation
import AppKit
import Combine

private enum TouchEventCounter {
	private static var current = -1
	static func next() -> Int {
		current += 1
		return current
	}
}

struct TaikoTouchEvent: Identifiable {
	let input: TaikoInput
	let touch: Touch
	let id = TouchEventCounter.next()
}

class TouchpadListener {
	var enabled = false {
		didSet {
			objectDidChange.send()
			updateCursorVisibility()
		}
	}

	let objectDidChange = PassthroughSubject<Void, Never>()
	let taikoEventPublisher = PassthroughSubject<TaikoTouchEvent, Never>()

	private init() {}
}

extension TouchpadListener {
	static let shared = TouchpadListener()
}

private extension TouchpadListener {
	static let alwaysAllowedEventTypes = Set<CGEventType>([.keyDown, .keyUp])
//	static let ignoredEventTypes = Set<CGEventType>([
//		.leftMouseDown,
//		.leftMouseUp,
//		.rightMouseDown,
//		.rightMouseUp,
//		.mouseMoved,
//		.leftMouseDragged,
//		.rightMouseDragged
//	])

	private func updateCursorVisibility() {
		let propertyString = CFStringCreateWithCString(
			kCFAllocatorDefault,
			"SetsCursorInBackground",
			CFStringBuiltInEncodings.macRoman.rawValue)
		CGSSetConnectionProperty(_CGSDefaultConnection(),
								 _CGSDefaultConnection(),
								 propertyString,
								 kCFBooleanTrue)
		if enabled {
			CGDisplayHideCursor(CGMainDisplayID())
		} else {
			CGDisplayShowCursor(CGMainDisplayID())
		}
	}

	private func handleCGEvent(proxy: CGEventTapProxy,
							   type: CGEventType,
							   event: CGEvent,
							   refcon: UnsafeMutableRawPointer?
	) -> Unmanaged<CGEvent>? {
		let unmanged = { Unmanaged.passRetained(event) }
		if type == CGEventType.keyUp,
		   let nsEvent = NSEvent(cgEvent: event),
		   nsEvent.keyCode == KeyCode.zero.rawValue {
			enabled.toggle()
			return nil
		}

		guard enabled else { return unmanged() }
		if Self.alwaysAllowedEventTypes.contains(type) { return unmanged() }

		print(event)
		print("Event type value: \(type.rawValue)")

		guard
			let nsEvent = NSEvent(cgEvent: event),
			nsEvent.type == .gesture
		else { return nil }

		for nsTouch in nsEvent.allTouches() where nsTouch.phase == .began {
			let touch = Touch(nsTouch)
			let input = TaikoInput.mapped(from: touch)
			KeystrokeGenerator.shared.pressAndRelease(input)
			taikoEventPublisher.send(.init(input: input, touch: touch))
//			NSHapticFeedbackManager.defaultPerformer.perform(
//				.generic, performanceTime: .now)
		}
		return nil
	}
}

extension TouchpadListener {
	/// Sets up the shared touchpad listener. It cannot be an instance method
	/// nor parameterized because the CGEvent callback requries a C function.
	static func setUpShared() {
		let eventMask = ~CGEventType.null.rawValue
		guard let eventTap = CGEvent.tapCreate(
			tap: .cgSessionEventTap,
			place: .headInsertEventTap,
			options: .defaultTap,
			eventsOfInterest: CGEventMask(eventMask),
			// Inline closure due to C function requirement.
			callback: { (proxy, type, event, refcon) in
				TouchpadListener.shared.handleCGEvent(
					proxy: proxy, type: type, event: event, refcon: refcon)
			},
			userInfo: nil
		) else {
			print("failed to create event tap")
			return
		}

		let runLoopSource =
			CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
		CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
		CGEvent.tapEnable(tap: eventTap, enable: true)
		CFRunLoopRun()
	}
}

