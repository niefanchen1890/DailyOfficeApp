import Foundation
import Combine
import UIKit

// MARK: - 緩存管理器
actor WPAPICacheManager {
    static let shared = WPAPICacheManager()
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let expirationInterval: TimeInterval = 7 * 24 * 60 * 60   // ✅ 本地緩存延長至 7 天
    
    init() {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = urls[0].appendingPathComponent("ChurchInfo", isDirectory: true)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
    }
    
    func save(_ posts: [WPPost], key: String) {
        let entry = CacheEntry(posts: posts, timestamp: Date())
        let url = cacheDirectory.appendingPathComponent("\(key).json")
        guard let data = try? JSONEncoder().encode(entry) else { return }
        try? data.write(to: url, options: .atomic)
    }
    
    func load(key: String) -> [WPPost]? {
        let url = cacheDirectory.appendingPathComponent("\(key).json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard let entry = try? JSONDecoder().decode(CacheEntry.self, from: data) else {
            try? fileManager.removeItem(at: url)
            return nil
        }
        if Date().timeIntervalSince(entry.timestamp) > expirationInterval {
            try? fileManager.removeItem(at: url)
            return nil
        }
        return entry.posts
    }
    
    private struct CacheEntry: Codable {
        let posts: [WPPost]
        let timestamp: Date
    }
}

// MARK: - WordPress API 服務
@MainActor
final class WPAPIService: ObservableObject {
    @Published var newsPosts: [WPPost] = []
    @Published var massPosts: [WPPost] = []
    @Published var blogPosts: [WPPost] = []   // ✅ 新增：博客
    @Published var isLoadingNews = false
    @Published var isLoadingMass = false
    @Published var isLoadingBlog = false       // ✅ 新增
    @Published var errorMessage: String?
    @Published var isOfflineNews = false
    @Published var isOfflineMass = false
    @Published var isOfflineBlog = false       // ✅ 新增
    
    private let cache = WPAPICacheManager.shared
    private let newsCacheKey = "news_posts_v1"
    private let massCacheKey = "mass_posts_v1"
    private let blogCacheKey = "blog_posts_v1" // ✅ 新增
    
    private let newsURL = URL(string: "https://theanglicancatholic.org/wp-json/wp/v2/posts?categories=787698155&per_page=20&_embed")!
    private let massURL = URL(string: "https://theanglicancatholic.org/wp-json/wp/v2/posts?categories=13892115&per_page=20&_embed")!
    private let blogURL = URL(string: "https://theanglicancatholic.org/wp-json/wp/v2/posts?categories=787698227&per_page=20&_embed")! // ✅ 新增
    
    init() {
        Task {
            await loadCachedNews()
            await loadCachedMass()
            await loadCachedBlog()
        }
    }
    
    // MARK: - 新聞
    func fetchNews() async {
        isLoadingNews = true
        errorMessage = nil
        isOfflineNews = false
        
        if newsPosts.isEmpty {
            if let cached = await cache.load(key: newsCacheKey) {
                newsPosts = cached
            }
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: newsURL)
            let posts = try JSONDecoder().decode([WPPost].self, from: data)
            newsPosts = posts
            isOfflineNews = false
            await cache.save(posts, key: newsCacheKey)
        } catch {
            if newsPosts.isEmpty {
                errorMessage = "新聞載入失敗，請檢查網路連線"
            } else {
                isOfflineNews = true
            }
        }
        isLoadingNews = false
    }
    
    private func loadCachedNews() async {
        guard newsPosts.isEmpty else { return }
        if let cached = await cache.load(key: newsCacheKey) {
            newsPosts = cached
            isOfflineNews = true
        }
    }
    
    // MARK: - 彌撒
    func fetchMass() async {
        isLoadingMass = true
        errorMessage = nil
        isOfflineMass = false
        
        if massPosts.isEmpty {
            if let cached = await cache.load(key: massCacheKey) {
                massPosts = cached
            }
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: massURL)
            let posts = try JSONDecoder().decode([WPPost].self, from: data)
            massPosts = posts
            isOfflineMass = false
            await cache.save(posts, key: massCacheKey)
        } catch {
            if massPosts.isEmpty {
                errorMessage = "彌撒內容載入失敗，請檢查網路連線"
            } else {
                isOfflineMass = true
            }
        }
        isLoadingMass = false
    }
    
    private func loadCachedMass() async {
        guard massPosts.isEmpty else { return }
        if let cached = await cache.load(key: massCacheKey) {
            massPosts = cached
            isOfflineMass = true
        }
    }
    
    // MARK: - ✅ 新增：博客
    func fetchBlog() async {
        isLoadingBlog = true
        errorMessage = nil
        isOfflineBlog = false
        
        if blogPosts.isEmpty {
            if let cached = await cache.load(key: blogCacheKey) {
                blogPosts = cached
            }
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: blogURL)
            let posts = try JSONDecoder().decode([WPPost].self, from: data)
            blogPosts = posts
            isOfflineBlog = false
            await cache.save(posts, key: blogCacheKey)
        } catch {
            if blogPosts.isEmpty {
                errorMessage = "博客載入失敗，請檢查網路連線"
            } else {
                isOfflineBlog = true
            }
        }
        isLoadingBlog = false
    }
    
    private func loadCachedBlog() async {
        guard blogPosts.isEmpty else { return }
        if let cached = await cache.load(key: blogCacheKey) {
            blogPosts = cached
            isOfflineBlog = true
        }
    }
}

// MARK: - ✅ 圖片緩存管理器（記憶體 NSCache + 磁碟，避免切換時閃爍）
final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let memoryCache = NSCache<NSURL, UIImage>()
    private let fileManager = FileManager.default
    private let diskCacheDirectory: URL
    private let diskExpiration: TimeInterval = 7 * 24 * 60 * 60   // 磁碟圖片緩存 7 天
    
    // 共用 URLSession，啟用系統層 HTTP 緩存
    private static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,    // 50MB
            diskCapacity: 300 * 1024 * 1024      // 300MB
        )
        return URLSession(configuration: config)
    }()
    
    private init() {
        memoryCache.countLimit = 300
        memoryCache.totalCostLimit = 120 * 1024 * 1024   // 約 120MB
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        diskCacheDirectory = urls[0].appendingPathComponent("ChurchInfoImages", isDirectory: true)
        try? fileManager.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true, attributes: nil)
    }
    
    private func diskURL(for url: URL) -> URL {
        let safeKey = (url.absoluteString.data(using: .utf8)?.base64EncodedString() ?? url.lastPathComponent)
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
        return diskCacheDirectory.appendingPathComponent(safeKey)
    }
    
    /// 同步讀取記憶體緩存（命中即可立即顯示，無需等待，避免閃爍）
    func memoryImage(for url: URL) -> UIImage? {
        memoryCache.object(forKey: url as NSURL)
    }
    
    /// 讀取記憶體或磁碟緩存
    func image(for url: URL) async -> UIImage? {
        if let cached = memoryCache.object(forKey: url as NSURL) {
            return cached
        }
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                let fileURL = self.diskURL(for: url)
                guard
                    let attrs = try? self.fileManager.attributesOfItem(atPath: fileURL.path),
                    let modDate = attrs[.modificationDate] as? Date
                else {
                    continuation.resume(returning: nil)
                    return
                }
                if Date().timeIntervalSince(modDate) > self.diskExpiration {
                    try? self.fileManager.removeItem(at: fileURL)
                    continuation.resume(returning: nil)
                    return
                }
                guard
                    let data = try? Data(contentsOf: fileURL),
                    let image = UIImage(data: data)
                else {
                    continuation.resume(returning: nil)
                    return
                }
                self.memoryCache.setObject(image, forKey: url as NSURL)
                continuation.resume(returning: image)
            }
        }
    }
    
    /// 下載並寫入記憶體 + 磁碟緩存
    func download(_ url: URL) async -> UIImage? {
        do {
            let (data, _) = try await Self.session.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            memoryCache.setObject(image, forKey: url as NSURL)
            let fileURL = diskURL(for: url)
            try? data.write(to: fileURL, options: .atomic)
            return image
        } catch {
            return nil
        }
    }
}

// MARK: - ✅ 緩存圖片載入器
@MainActor
final class CachedImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    init(url: URL?) {
        // 初始化時同步命中記憶體緩存：切換分頁／返回時可立即顯示，不閃爍
        if let url {
            self.image = ImageCacheManager.shared.memoryImage(for: url)
        }
    }
    
    func load(_ url: URL?) async {
        guard let url else { return }
        if image != nil { return }   // 記憶體已命中
        if let cached = await ImageCacheManager.shared.image(for: url) {
            self.image = cached
            return
        }
        if let downloaded = await ImageCacheManager.shared.download(url) {
            self.image = downloaded
        }
    }
}
