//
//  ContentView.swift
//  TaikoTrackpad
//
//  Created by Jack on 2021/8/12.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
		TrackpadReader {
			Text("Hello!")
		}
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
