//
//  CloudSoundPlayerApp.swift
//  CloudSoundPlayer
//
//  Created by Kanstantsin Bucha on 18/03/2023.
//

import SwiftUI

@main
struct CloudSoundPlayerApp: App {
    let cloudManager = CloudManager()
    var body: some Scene {
        WindowGroup {
            ContentView(manager: cloudManager)
        }
    }
}
