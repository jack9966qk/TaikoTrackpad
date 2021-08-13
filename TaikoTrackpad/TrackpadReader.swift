//
//  TrackpadReader.swift
//  TaikoTrackpad
//
//  Created by Jack on 2021/8/12.
//

import SwiftUI
import AppKit

class TrackpadView: NSView {
	func startListening() {
		self.allowedTouchTypes = [.direct, .indirect]
	}

	override func touchesBegan(with event: NSEvent) {
		for touch in event.allTouches() {
			switch touch.phase {
			case .began:
				print("\(touch.normalizedPosition)")
			default: break
			}
		}
		print("touches began")
		print(event)
	}
}

struct TrackpadReader<Content: View>: NSViewRepresentable {
	typealias NSViewType = TrackpadView
	
	func makeNSView(context: Context) -> TrackpadView {
		let view = TrackpadView()
		view.startListening()
		return view
	}
	
	func updateNSView(_ nsView: TrackpadView, context: Context) {
	}
	
	let content: () -> Content
}

struct TrackpadReader_Previews: PreviewProvider {
    static var previews: some View {
		TrackpadReader {
			Text("hi")
		}
    }
}
