//
//  PreferenceView.swift
//  Wallify
//
//  Created by Daniel Ofosu on 22.6.2025.
//

import SwiftUI

struct PreferenceView: View {
    @State private var launchAtLogin = true

    var body: some View {
        Form {
            Section(header: Text("General").font(.headline)) {
                Toggle("Launch at Login", isOn: $launchAtLogin)
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: 400)
        .navigationTitle("Preferences")
    }
}

#Preview {
    PreferenceView()
} 