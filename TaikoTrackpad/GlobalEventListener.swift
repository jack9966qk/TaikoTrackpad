//
//  GlobalEventListener.swift
//  TaikoTrackpad
//
//  Created by Jack on 2021/8/13.
//

import Foundation
import AppKit
import Combine

struct Counter {
	private static var current = -1
	static func next() -> Int {
		current += 1
		return current
	}
}

struct TaikoTouchEvent: Identifiable {
	let input: TaikoInput
	let touch: Touch
	let id = Counter.next()
}

let TaikoEventPublisher = PassthroughSubject<TaikoTouchEvent, Never>()

private var GlobalEventListenerEnabled = false
private let AlwaysAllowedEventTypes = Set<UInt32>([10, 11])
private let IgnoredEventTypes = Set<UInt32>([1, 2, 3, 4, 5, 6, 7])

private func UpdateCursorVisibility() {
	let propertyString = CFStringCreateWithCString(
		kCFAllocatorDefault,
		"SetsCursorInBackground",
		CFStringBuiltInEncodings.macRoman.rawValue)
	CGSSetConnectionProperty(_CGSDefaultConnection(),
							 _CGSDefaultConnection(),
							 propertyString,
							 kCFBooleanTrue)
	if GlobalEventListenerEnabled {
		CGDisplayHideCursor(CGMainDisplayID())
	} else {
		CGDisplayShowCursor(CGMainDisplayID())
	}
}

private func HandleCGEvent(proxy: CGEventTapProxy,
						   type: CGEventType,
						   event: CGEvent,
						   refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
	let unmanged = { Unmanaged.passRetained(event) }
	if type == CGEventType.keyUp,
	   let nsEvent = NSEvent(cgEvent: event),
	   nsEvent.keyCode == KeyCode.zero.rawValue {
		GlobalEventListenerEnabled.toggle()
		UpdateCursorVisibility()
		return nil
	}

	guard GlobalEventListenerEnabled else { return unmanged() }
	if AlwaysAllowedEventTypes.contains(type.rawValue) { return unmanged() }

	if type.rawValue == 0x1d, let nsEvent = NSEvent(cgEvent: event) {
		for nsTouch in nsEvent.allTouches() {
			if nsTouch.phase == .began {
				let touch = Touch(nsTouch)
				let input = TaikoInput.mapped(from: touch)
				KeystrokeGenerator.pressAndRelease(input)
				TaikoEventPublisher.send(.init(input: input, touch: touch))
//				NSHapticFeedbackManager.defaultPerformer.perform(
//					.generic, performanceTime: .now)
			}
		}
	}

	print(event)
	print("Event type value: \(type.rawValue)")

	return nil
}


enum GlobalEventListener {
	static var enabled: Bool {
		get { GlobalEventListenerEnabled }
		set { GlobalEventListenerEnabled = newValue }
	}

	static func setUp() {
		let eventMask = ~CGEventType.null.rawValue
		guard let eventTap = CGEvent.tapCreate(
				tap: .cgSessionEventTap,
				place: .headInsertEventTap,
				options: .defaultTap,
				eventsOfInterest: CGEventMask(eventMask),
				callback: HandleCGEvent(proxy:type:event:refcon:),
				userInfo: nil) else {
			print("failed to create event tap")
			return
		}

		let runLoopSource =
			CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
		CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
		CGEvent.tapEnable(tap: eventTap, enable: true)
		CFRunLoopRun()
	}

	private static func handle(_ event: NSEvent) {
		guard enabled else { return }

	}
}
