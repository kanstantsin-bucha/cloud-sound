import Foundation
import AVFAudio

class CloudManager {
    typealias File = URL
    private var player: AVAudioPlayer?
    
    private var manager: FileManager {
        FileManager.default
    }
    private let coordinator = NSFileCoordinator()
    
    private lazy var documentsURL: URL = {
        guard let containerURL = manager.url(forUbiquityContainerIdentifier: nil) else {
            preconditionFailure("Failed to get URL of the ubiquitous store")
        }
        return containerURL.appendingPathComponent("Documents")
    }()
    
    public init() {
        initiateCloud()
    }
    
    func listAllFiles() -> [File] {
        var files = [URL]()
        coordinator.coordinate(readingItemAt: documentsURL, error: nil) { url in
            (try? manager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil))
                .map { files = $0 }
        }
        return files
    }
    
    func pause() {
        player?.pause()
    }
    
    func play(_ fileURL: URL) {
        let availableExtensions = ["mp3", "icloud"]
        guard availableExtensions.contains(fileURL.pathExtension) else { return }
        coordinator.coordinate(readingItemAt: fileURL, error: nil) { url in
            
            do {
                let values = try fileURL.resourceValues(forKeys: [
                    .isUbiquitousItemKey,
                    .ubiquitousItemDownloadingStatusKey,
                    .ubiquitousItemDownloadRequestedKey
                ]
                )
                
                let status = values.ubiquitousItemDownloadingStatus ?? .notDownloaded
                print("""
                    isiCloud: \(values.isUbiquitousItem ?? false); \
                    isRequested: \(values.ubiquitousItemDownloadRequested ?? false); \
                    status: \(status.rawValue);
                    """
                )
                let data = try Data(contentsOf: url)
                guard status == .current || status == .downloaded else {
                    print("Still loading...")
                    return
                }
                player = try AVAudioPlayer(data: data)
                player?.prepareToPlay()
                player?.play()
            } catch {
                print("Error playing sound: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private methods
    
    private func initiateCloud() {
        coordinator.coordinate(writingItemAt: documentsURL, error: nil) { url in
            guard !manager.fileExists(atPath: url.path()) else { return }
            do {
                try manager.createDirectory(at: url, withIntermediateDirectories: true)
            } catch {
                preconditionFailure("Failed to create a Documents directory")
            }
        }
    }
}
