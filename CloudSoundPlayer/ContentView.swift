import SwiftUI

struct ContentView: View {
    let manager: CloudManager
    @State var urls = [URL]()
    
    var body: some View {
        NavigationView {
            List(urls, id: \.self) { url in
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
        .task {
            urls = manager.listAllFiles()
        }
    }
}
