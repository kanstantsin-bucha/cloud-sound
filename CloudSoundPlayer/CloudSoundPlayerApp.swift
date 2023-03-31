//
//  CloudSoundPlayerApp.swift
//  CloudSoundPlayer
//
//  Created by Kanstantsin Bucha on 18/03/2023.
//

import SwiftUI

@main
struct CloudSoundPlayerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
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

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        application.beginReceivingRemoteControlEvents()
        return true
    }
}
