import Foundation
import UIKit

public class CloudManager {
    typealias File = URL
    public let cloud = CloudContainer()
    private var files: FileManager { FileManager.default }
    private let coordinator = NSFileCoordinator()
    private var document: UIDocument?
    
    private lazy var documentsURL: URL = {
        guard let containerURL = files.url(forUbiquityContainerIdentifier: nil) else {
            preconditionFailure("Failed to get URL of the ubiquitous store")
        }
        return containerURL.appendingPathComponent("Documents")
    }()
    
    public init() {
        Task {
            await initiateCloud()
            cloud.start()
        }
    }
    
    public func coordinateRead(fileAtURL fileURL: URL) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                var error: NSError?
                self.coordinator.coordinate(readingItemAt: fileURL, error: &error) { [weak error] url in
                    DispatchQueue.main.async {
                        if let error {
                            continuation.resume(throwing: error)
                            return
                        }
                        continuation.resume(returning: url)
                    }
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    private func initiateCloud() async {
        await withCheckedContinuation { [weak self] continuation in
            guard let self = self else { return }
            self.coordinator.coordinate(writingItemAt: documentsURL, error: nil) { url in
                self.document = UIDocument(fileURL: url)
                guard !self.files.fileExists(atPath: url.path()) else { return }
                do {
                    try self.files.createDirectory(at: url, withIntermediateDirectories: true)
                    continuation.resume()
                } catch {
                    preconditionFailure("Failed to create a Documents directory")
                }
            }
        }
        
    }
}
