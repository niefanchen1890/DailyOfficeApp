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
    
    func save(
        _ posts: [WPPost],
        key: String,
        etag: String? = nil,
        lastModified: String? = nil
    ) {
        let entry = CacheEntry(
            posts: posts,
            timestamp: Date(),
            etag: etag,
            lastModified: lastModified
        )
        let url = cacheDirectory.appendingPathComponent("\(key).json")
        guard let data = try? JSONEncoder().encode(entry) else { return }
        try? data.write(to: url, options: .atomic)
    }
    
    struct CachedPosts: Sendable {
        let posts: [WPPost]
        let isExpired: Bool
        let etag: String?
        let lastModified: String?
    }

    func load(key: String) -> CachedPosts? {
        let url = cacheDirectory.appendingPathComponent("\(key).json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard let entry = try? JSONDecoder().decode(CacheEntry.self, from: data) else {
            try? fileManager.removeItem(at: url)
            return nil
        }
        let isExpired = Date().timeIntervalSince(entry.timestamp) > expirationInterval
        return CachedPosts(
            posts: entry.posts,
            isExpired: isExpired,
            etag: entry.etag,
            lastModified: entry.lastModified
        )
    }
    
    private struct CacheEntry: Codable {
        let posts: [WPPost]
        let timestamp: Date
        let etag: String?
        let lastModified: String?

        init(posts: [WPPost], timestamp: Date, etag: String? = nil, lastModified: String? = nil) {
            self.posts = posts
            self.timestamp = timestamp
            self.etag = etag
            self.lastModified = lastModified
        }
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
    @Published var newsErrorMessage: String?
    @Published var massErrorMessage: String?
    @Published var blogErrorMessage: String?
    @Published var isOfflineNews = false
    @Published var isOfflineMass = false
    @Published var isOfflineBlog = false       // ✅ 新增
    @Published var isStaleNews = false
    @Published var isStaleMass = false
    @Published var isStaleBlog = false
    @Published var canLoadMoreNews = false
    @Published var canLoadMoreMass = false
    @Published var canLoadMoreBlog = false
    @Published var isLoadingMoreNews = false
    @Published var isLoadingMoreMass = false
    @Published var isLoadingMoreBlog = false

    private var newsPage = 1
    private var massPage = 1
    private var blogPage = 1
    
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
        let result = await fetchPosts(
            from: newsURL,
            cacheKey: newsCacheKey,
            currentPosts: newsPosts,
            currentIsStale: isStaleNews,
            currentCanLoadMore: canLoadMoreNews,
            failureMessage: "新聞載入失敗，請檢查網路連線"
        )
        newsPosts = result.posts
        isOfflineNews = result.isOffline
        isStaleNews = result.isStale
        newsErrorMessage = result.errorMessage
        canLoadMoreNews = result.canLoadMore
        newsPage = 1
        isLoadingNews = false
    }
    
    private func loadCachedNews() async {
        guard newsPosts.isEmpty else { return }
        if let cached = await cache.load(key: newsCacheKey) {
            newsPosts = cached.posts
            isOfflineNews = true
            isStaleNews = cached.isExpired
        }
    }
    
    // MARK: - 彌撒
    func fetchMass() async {
        isLoadingMass = true
        let result = await fetchPosts(
            from: massURL,
            cacheKey: massCacheKey,
            currentPosts: massPosts,
            currentIsStale: isStaleMass,
            currentCanLoadMore: canLoadMoreMass,
            failureMessage: "彌撒內容載入失敗，請檢查網路連線"
        )
        massPosts = result.posts
        isOfflineMass = result.isOffline
        isStaleMass = result.isStale
        massErrorMessage = result.errorMessage
        canLoadMoreMass = result.canLoadMore
        massPage = 1
        isLoadingMass = false
    }
    
    private func loadCachedMass() async {
        guard massPosts.isEmpty else { return }
        if let cached = await cache.load(key: massCacheKey) {
            massPosts = cached.posts
            isOfflineMass = true
            isStaleMass = cached.isExpired
        }
    }
    
    // MARK: - ✅ 新增：博客
    func fetchBlog() async {
        isLoadingBlog = true
        let result = await fetchPosts(
            from: blogURL,
            cacheKey: blogCacheKey,
            currentPosts: blogPosts,
            currentIsStale: isStaleBlog,
            currentCanLoadMore: canLoadMoreBlog,
            failureMessage: "博客載入失敗，請檢查網路連線"
        )
        blogPosts = result.posts
        isOfflineBlog = result.isOffline
        isStaleBlog = result.isStale
        blogErrorMessage = result.errorMessage
        canLoadMoreBlog = result.canLoadMore
        blogPage = 1
        isLoadingBlog = false
    }
    
    private func loadCachedBlog() async {
        guard blogPosts.isEmpty else { return }
        if let cached = await cache.load(key: blogCacheKey) {
            blogPosts = cached.posts
            isOfflineBlog = true
            isStaleBlog = cached.isExpired
        }
    }

    private struct FetchResult {
        let posts: [WPPost]
        let isOffline: Bool
        let isStale: Bool
        let canLoadMore: Bool
        let errorMessage: String?
    }

    /// 新聞、彌撒與博客共用同一套「先讀快取，再更新網路」流程。
    private func fetchPosts(
        from url: URL,
        cacheKey: String,
        currentPosts: [WPPost],
        currentIsStale: Bool,
        currentCanLoadMore: Bool,
        failureMessage: String
    ) async -> FetchResult {
        var availablePosts = currentPosts
        var cachedPostsAreStale = currentIsStale
        let cachedEntry = await cache.load(key: cacheKey)

        if availablePosts.isEmpty, let cachedPosts = cachedEntry {
            availablePosts = cachedPosts.posts
            cachedPostsAreStale = cachedPosts.isExpired
        }

        do {
            var request = URLRequest(url: url)
            if let etag = cachedEntry?.etag {
                request.setValue(etag, forHTTPHeaderField: "If-None-Match")
            }
            if let lastModified = cachedEntry?.lastModified {
                request.setValue(lastModified, forHTTPHeaderField: "If-Modified-Since")
            }

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WPAPIError.invalidResponse
            }

            if httpResponse.statusCode == 304, !availablePosts.isEmpty {
                await cache.save(
                    availablePosts,
                    key: cacheKey,
                    etag: cachedEntry?.etag,
                    lastModified: cachedEntry?.lastModified
                )
                return FetchResult(
                    posts: availablePosts,
                    isOffline: false,
                    isStale: false,
                    canLoadMore: currentCanLoadMore,
                    errorMessage: nil
                )
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw WPAPIError.httpStatus(httpResponse.statusCode)
            }

            let freshPosts: [WPPost]
            do {
                freshPosts = try JSONDecoder().decode([WPPost].self, from: data)
            } catch {
                throw WPAPIError.invalidData
            }
            await cache.save(
                freshPosts,
                key: cacheKey,
                etag: httpResponse.value(forHTTPHeaderField: "ETag"),
                lastModified: httpResponse.value(forHTTPHeaderField: "Last-Modified")
            )
            let totalPages = Int(httpResponse.value(forHTTPHeaderField: "X-WP-TotalPages") ?? "") ?? 1
            return FetchResult(
                posts: freshPosts,
                isOffline: false,
                isStale: false,
                canLoadMore: totalPages > 1,
                errorMessage: nil
            )
        } catch {
            return FetchResult(
                posts: availablePosts,
                isOffline: !availablePosts.isEmpty,
                isStale: cachedPostsAreStale,
                canLoadMore: currentCanLoadMore,
                errorMessage: availablePosts.isEmpty ? message(for: error, fallback: failureMessage) : nil
            )
        }
    }

    func fetchMoreNews() async {
        guard canLoadMoreNews, !isLoadingMoreNews else { return }
        isLoadingMoreNews = true
        let result = await fetchAdditionalPage(from: newsURL, page: newsPage + 1, currentPosts: newsPosts, cacheKey: newsCacheKey)
        newsPosts = result.posts
        canLoadMoreNews = result.canLoadMore
        if result.didAdvance { newsPage += 1 }
        isLoadingMoreNews = false
    }

    func fetchMoreMass() async {
        guard canLoadMoreMass, !isLoadingMoreMass else { return }
        isLoadingMoreMass = true
        let result = await fetchAdditionalPage(from: massURL, page: massPage + 1, currentPosts: massPosts, cacheKey: massCacheKey)
        massPosts = result.posts
        canLoadMoreMass = result.canLoadMore
        if result.didAdvance { massPage += 1 }
        isLoadingMoreMass = false
    }

    func fetchMoreBlog() async {
        guard canLoadMoreBlog, !isLoadingMoreBlog else { return }
        isLoadingMoreBlog = true
        let result = await fetchAdditionalPage(from: blogURL, page: blogPage + 1, currentPosts: blogPosts, cacheKey: blogCacheKey)
        blogPosts = result.posts
        canLoadMoreBlog = result.canLoadMore
        if result.didAdvance { blogPage += 1 }
        isLoadingMoreBlog = false
    }

    private struct AdditionalPageResult {
        let posts: [WPPost]
        let canLoadMore: Bool
        let didAdvance: Bool
    }

    private func fetchAdditionalPage(
        from baseURL: URL,
        page: Int,
        currentPosts: [WPPost],
        cacheKey: String
    ) async -> AdditionalPageResult {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            return AdditionalPageResult(posts: currentPosts, canLoadMore: true, didAdvance: false)
        }
        var queryItems = components.queryItems ?? []
        queryItems.removeAll { $0.name == "page" }
        queryItems.append(URLQueryItem(name: "page", value: String(page)))
        components.queryItems = queryItems

        guard let pageURL = components.url else {
            return AdditionalPageResult(posts: currentPosts, canLoadMore: true, didAdvance: false)
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: pageURL)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return AdditionalPageResult(posts: currentPosts, canLoadMore: true, didAdvance: false)
            }
            let newPosts = try JSONDecoder().decode([WPPost].self, from: data)
            let existingIDs = Set(currentPosts.map(\.id))
            let combined = currentPosts + newPosts.filter { !existingIDs.contains($0.id) }
            let totalPages = Int(httpResponse.value(forHTTPHeaderField: "X-WP-TotalPages") ?? "") ?? page
            let cachedEntry = await cache.load(key: cacheKey)
            await cache.save(
                combined,
                key: cacheKey,
                etag: cachedEntry?.etag,
                lastModified: cachedEntry?.lastModified
            )
            return AdditionalPageResult(posts: combined, canLoadMore: page < totalPages, didAdvance: true)
        } catch {
            return AdditionalPageResult(posts: currentPosts, canLoadMore: true, didAdvance: false)
        }
    }

    private func message(for error: Error, fallback: String) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost,
                 .cannotFindHost, .cannotConnectToHost, .timedOut:
                return fallback
            default:
                return "網路請求失敗，請稍後再試"
            }
        }

        switch error {
        case WPAPIError.httpStatus(let statusCode):
            return "網站服務暫時無法使用（錯誤代碼 \(statusCode)）"
        case WPAPIError.invalidData:
            return "網站返回的資料格式不正確，請稍後再試"
        default:
            return "網站沒有返回有效資料，請稍後再試"
        }
    }
}

private enum WPAPIError: Error {
    case invalidResponse
    case httpStatus(Int)
    case invalidData
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
