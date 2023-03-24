import SwiftUI

struct SongsView: View {
    @ObservedObject var cloud: CloudContainer
    @State private var selected: URL?
    private let player: Player
    
    public init(cloud: CloudContainer, player: Player) {
        self.player = player
        self.cloud = cloud
    }
    
    var body: some View {
        NavigationView {
            let container = manager.container
            List(container.fileUrls, id: \.self) { url in
                NavigationLink(url.lastPathComponent) {
                    Text(url.lastPathComponent)
                    Button("Play") {
                        manager.play(url)
                    }
                    .padding()
                    Button("Pause") {
                        manager.pause()
                    }
                    .padding()
                }
            }
        }
    }
}
