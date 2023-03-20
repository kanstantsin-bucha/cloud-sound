import SwiftUI

struct ContentView: View {
    @ObservedObject var container: CloudContainer
    private let manager: CloudManager
    
    public init(manager: CloudManager) {
        self.manager = manager
        container = manager.container
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
