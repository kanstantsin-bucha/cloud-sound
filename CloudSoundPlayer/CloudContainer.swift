import Foundation

public class CloudContainer: NSObject, ObservableObject {
    @Published public private(set) var fileUrls = [URL]()
    
    private lazy var query: NSMetadataQuery = {
        let query = NSMetadataQuery()
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        query.predicate = NSPredicate(format: "%K LIKE '*.mp3'", NSMetadataItemFSNameKey)
        query.delegate = self
        return query
    }()
    
    public override init() {
        super.init()
        subscribeToNotifications()
    }
    
    deinit {
        query.disableUpdates()
        query.stop()
    }
    
    public func start() {
        DispatchQueue.main.async { [weak self] in
            self?.query.stop()
            self?.query.start()
        }
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(
            forName: .NSMetadataQueryGatheringProgress,
            object: query,
            queue: .main,
            using: { notification in
                print("NSMetadataQueryGatheringProgress")
            }
        )
        NotificationCenter.default.addObserver(
            forName: .NSMetadataQueryDidUpdate,
            object: query,
            queue: .main,
            using: { [weak self] notification in
                print("NSMetadataQueryDidUpdate")
                self?.handleUpdates()
            }
        )
        NotificationCenter.default.addObserver(
            forName: .NSMetadataQueryDidFinishGathering,
            object: query,
            queue: .main,
            using: { [weak self] notification in
                print("NSMetadataQueryDidFinishGathering")
                self?.handleUpdates()
            }
        )
        NotificationCenter.default.addObserver(
            forName: .NSMetadataQueryDidStartGathering,
            object: query,
            queue: .main,
            using: { notification in
                print("NSMetadataQueryDidStartGathering")
            }
        )
    }
    
    private func handleUpdates() {
        query.disableUpdates()
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            var urls = Set<URL>()
            self.query.enumerateResults { url, index, _ in
                (url as? URL).map { _ = urls.insert($0) }
            }
            DispatchQueue.main.async {
                print("Apply Updates")
                self.fileUrls = Array(urls).sorted(by: { $0.lastPathComponent > $1.lastPathComponent })
                self.query.start()
            }
        }
    }
}

extension CloudContainer: NSMetadataQueryDelegate {
    public func metadataQuery(_ query: NSMetadataQuery, replacementObjectForResultObject result: NSMetadataItem) -> Any {
        result.value(forAttribute: NSMetadataItemURLKey) ?? URL(filePath: "No File")
    }
}
