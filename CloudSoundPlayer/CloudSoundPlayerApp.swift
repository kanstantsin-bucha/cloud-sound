//
//  CloudSoundPlayerApp.swift
//  CloudSoundPlayer
//
//  Created by Kanstantsin Bucha on 18/03/2023.
//

import SwiftUI

@main
struct CloudSoundPlayerApp: App {
    private let cloudManager: CloudManager
    private let player: Player
    
    init() {
        cloudManager = CloudManager()
        player = Player(cloud: cloudManager)
    }
    
    var body: some Scene {
        WindowGroup {
            SongsView(cloud: cloudManager.cloud, player: player)
        }
    }
}
