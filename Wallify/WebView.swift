//
//  WebView.swift
//  Wallify
//
//  Created by Daniel Ofosu on 22.6.2025.
//

import SwiftUI

struct WebView: View {
    @State private var webUrl: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "safari")
                .font(.system(size: 50))
                .foregroundColor(.blue)

            Text("Web Wallpaper")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Enter a URL to display a website as your wallpaper. Note that some complex, interactive sites may not perform well.")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            TextField("Enter URL", text: $webUrl)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 400)
            
            Button("Set Web Wallpaper") {
                // TODO: Implement web view playback
            }
            .buttonStyle(.borderedProminent)
            .disabled(webUrl.isEmpty)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    WebView()
} 