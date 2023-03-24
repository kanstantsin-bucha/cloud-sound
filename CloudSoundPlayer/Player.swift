import Foundation
import AVFAudio

public class Player {
    enum Error: Swift.Error {
        case fileIsNotLoadedFromCloud
    }
    private var player: AVAudioPlayer?
    private var cloud: CloudManager
    
    public init(player: AVAudioPlayer? = nil, cloud: CloudManager) {
        self.player = player
        self.cloud = cloud
    }
    
    func pause() {
        player?.pause()
    }
    
    func play(_ fileURL: URL) {
        Task {
            do {
                try await play(file: fileURL)
            } catch {
                print("Error playing sound: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private methods
    
    private func play(file: URL) async throws {
        let availableExtensions = ["mp3", "icloud"]
        guard availableExtensions.contains(file.pathExtension) else { return }
        let fileURL = try await cloud.coordinateRead(fileAtURL: file)
            
        let values = try fileURL.resourceValues(forKeys: [
            .isUbiquitousItemKey,
            .ubiquitousItemDownloadingStatusKey,
            .ubiquitousItemDownloadRequestedKey
        ])
        
        let status = values.ubiquitousItemDownloadingStatus ?? .notDownloaded
        print("""
            isiCloud: \(values.isUbiquitousItem ?? false); \
            isRequested: \(values.ubiquitousItemDownloadRequested ?? false); \
            status: \(status.rawValue);
            """
        )
        guard status == .current || status == .downloaded else {
            forceLoading(file: fileURL)
            throw Error.fileIsNotLoadedFromCloud
        }
        player = try AVAudioPlayer(data: try Data(contentsOf: fileURL))
        player?.prepareToPlay()
        player?.play()
    }
    
    private func forceLoading(file: URL) {
        _ = try? Data(contentsOf: file)
    }
}

