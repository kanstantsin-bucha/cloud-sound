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
            VStack {
                Spacer()
                Spacer()
                List(cloud.fileUrls, id: \.self, selection: $selected) { url in
                    Text(url.lastPathComponent)
                }
                .onChange(of: selected) { newValue in
                    play()
                }
                HStack {
                    Button { play() } label: { Image(systemName: "play").font(.system(size: 40)) }
                        .padding()
                    Button { player.pause() } label: { Image(systemName: "pause").font(.system(size: 40)) }
                        .padding()
                }
            }
        }
    }
    
    private func play() {
        guard let fileToPlay = selected ?? cloud.fileUrls.first else { return }
        player.play(fileToPlay)
    }
}
