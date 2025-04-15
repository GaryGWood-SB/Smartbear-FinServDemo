//
//  ContentView.swift
//  Smartbear FinServDemo
//
//  Created by default.
//  This view is not used in the demo app

import SwiftUI
import Bugsnag

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
