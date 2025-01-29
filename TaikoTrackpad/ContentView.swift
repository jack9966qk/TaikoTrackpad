//
//  ContentView.swift
//  TaikoTrackpad
//
//  Created by Jack on 2021/8/12.
//

import SwiftUI

struct ContentView: View {
	@State private var includePreview = false

	var togglePreviewButtonText: String {
		includePreview
			? "Clear preview"
			: "Show preview"
	}

    var body: some View {
		VStack {
			Text("Press 0 to toggle trackpad control")
			Button(togglePreviewButtonText) { includePreview.toggle() }
		}
		.padding()

		if includePreview {
			TaikoPreview(appConfig: .shared)
				.background(Color.gray)
				.aspectRatio(1.6, contentMode: .fit)
				.padding()
				.frame(
					minWidth: 240,
					maxWidth: .infinity,
					minHeight: 150,
					maxHeight: .infinity)
		}
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
