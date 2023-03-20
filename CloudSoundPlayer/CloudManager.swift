import Foundation
import AVFAudio
import UIKit

class CloudManager {
    typealias File = URL
    let container = CloudContainer()
    
    private var player: AVAudioPlayer?
    private var manager: FileManager {
        FileManager.default
    }
    private let coordinator = NSFileCoordinator()
    private var document: UIDocument?
    
    private lazy var documentsURL: URL = {
        guard let containerURL = manager.url(forUbiquityContainerIdentifier: nil) else {
            preconditionFailure("Failed to get URL of the ubiquitous store")
        }
        return containerURL.appendingPathComponent("Documents")
    }()
    
    public init() {
        Task {
            await initiateCloud()
            container.start()
        }
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
                ])
                
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
    
    private func initiateCloud() async {
        await withCheckedContinuation { [weak self] continuation in
            guard let self = self else { return }
            self.coordinator.coordinate(writingItemAt: documentsURL, error: nil) { url in
                self.document = UIDocument(fileURL: url)
                guard !self.manager.fileExists(atPath: url.path()) else { return }
                do {
                    try self.manager.createDirectory(at: url, withIntermediateDirectories: true)
                    continuation.resume()
                } catch {
                    preconditionFailure("Failed to create a Documents directory")
                }
            }
        }
        
    }
}
