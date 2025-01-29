//
//  AppDelegate.swift
//  TaikoTrackpad
//
//  Created by Jack on 2021/8/12.
//

import Cocoa
import SwiftUI
import Combine

@main
class AppDelegate: NSObject, NSApplicationDelegate {
	var window: NSWindow!
	var listenerSubscription: AnyCancellable?

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Create the SwiftUI view that provides the window contents.
		let contentView = ContentView()

		// Create the window and set the content view.
		window = NSWindow(
		    contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
		    styleMask: [
				.titled,
				.closable,
				.miniaturizable,
				.resizable,
				.fullSizeContentView],
		    backing: .buffered,
			defer: false)
		window.isReleasedWhenClosed = false
		window.center()
		window.setFrameAutosaveName("Main Window")
		window.contentView = NSHostingView(rootView: contentView)
		window.makeKeyAndOrderFront(nil)

		let updateTitle = { () in
			let active = TouchpadListener.shared.enabled
			self.window.title =
				"TaikoTrackpad: \(active ? "ON" : "OFF")"
		}
		updateTitle()
		listenerSubscription = TouchpadListener.shared.objectDidChange.sink(
			receiveValue: updateTitle)

		TouchpadListener.setUpShared()
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}
}

