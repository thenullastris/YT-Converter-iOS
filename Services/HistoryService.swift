import Foundation

class HistoryService {
    static let shared = HistoryService()
    private let key = "download_history"

    func load() -> [DownloadItem] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let items = try? JSONDecoder().decode([DownloadItem].self, from: data) else {
            return []
        }
        return items
    }

    func save(_ items: [DownloadItem]) {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func add(_ item: DownloadItem) {
        var items = load()
        items.insert(item, at: 0)
        if items.count > 50 { items = Array(items.prefix(50)) }
        save(items)
    }

    func delete(id: UUID) {
        var items = load()
        items.removeAll { $0.id == id }
        save(items)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
