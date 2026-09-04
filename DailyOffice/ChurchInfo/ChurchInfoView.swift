import SwiftUI
import WebKit

// MARK: - 主入口：教會資訊
struct ChurchInfoView: View {
    @StateObject private var wpService = WPAPIService()
    @ObservedObject private var languageStore = AppLanguageStore.shared
    @State private var selectedTab = 0
    private let tabs = ["新聞", "彌撒", "博客"]  // ✅ 新增博客

    private var isSimp: Bool { languageStore.isSimplified }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - 頂部品牌區
            HStack(spacing: 16) {
                Image("anglican_shield")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("教會資訊".adaptChinese(isSimplified: isSimp))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Anglican Catholic Church")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
            
            // MARK: - 模塊切換
            Picker("模塊".adaptChinese(isSimplified: isSimp), selection: $selectedTab) {
                ForEach(0..<tabs.count, id: \.self) { i in
                    Text(tabs[i].adaptChinese(isSimplified: isSimp)).tag(i)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // MARK: - 內容區
            Group {
                switch selectedTab {
                case 0:
                    PostListView(
                        posts: wpService.newsPosts,
                        isLoading: wpService.isLoadingNews,
                        emptyText: "暫無新聞",
                        type: .news,
                        isOffline: wpService.isOfflineNews,
                        isStale: wpService.isStaleNews,
                        errorMessage: wpService.newsErrorMessage,
                        isSimplified: isSimp,
                        canLoadMore: wpService.canLoadMoreNews,
                        isLoadingMore: wpService.isLoadingMoreNews,
                        onLoadMore: { Task { await wpService.fetchMoreNews() } }
                    )
                case 1:
                    PostListView(
                        posts: wpService.massPosts,
                        isLoading: wpService.isLoadingMass,
                        emptyText: "暫無彌撒內容",
                        type: .mass,
                        isOffline: wpService.isOfflineMass,
                        isStale: wpService.isStaleMass,
                        errorMessage: wpService.massErrorMessage,
                        isSimplified: isSimp,
                        canLoadMore: wpService.canLoadMoreMass,
                        isLoadingMore: wpService.isLoadingMoreMass,
                        onLoadMore: { Task { await wpService.fetchMoreMass() } }
                    )
                case 2:
                    PostListView(
                        posts: wpService.blogPosts,
                        isLoading: wpService.isLoadingBlog,
                        emptyText: "暫無博客文章",
                        type: .blog,           // ✅ 新增
                        isOffline: wpService.isOfflineBlog,
                        isStale: wpService.isStaleBlog,
                        errorMessage: wpService.blogErrorMessage,
                        isSimplified: isSimp,
                        canLoadMore: wpService.canLoadMoreBlog,
                        isLoadingMore: wpService.isLoadingMoreBlog,
                        onLoadMore: { Task { await wpService.fetchMoreBlog() } }
                    )
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarHidden(true)
        .task {
            async let news: Void = wpService.fetchNews()
            async let mass: Void = wpService.fetchMass()
            async let blog: Void = wpService.fetchBlog()
            _ = await (news, mass, blog)
        }
        .refreshable {
            switch selectedTab {
            case 0: await wpService.fetchNews()
            case 1: await wpService.fetchMass()
            case 2: await wpService.fetchBlog()  // ✅ 新增
            default: break
            }
        }
    }
}

// MARK: - 文章類型枚舉
enum PostType {
    case news, mass, blog   // ✅ 新增 blog
    var icon: String {
        switch self {
        case .news: return "newspaper.fill"
        case .mass: return "cross.fill"
        case .blog: return "text.quote"   // ✅ 博客圖標
        }
    }
}

// MARK: - 文章列表
struct PostListView: View {
    let posts: [WPPost]
    let isLoading: Bool
    let emptyText: String
    let type: PostType
    let isOffline: Bool
    let isStale: Bool
    let errorMessage: String?
    let isSimplified: Bool
    let canLoadMore: Bool
    let isLoadingMore: Bool
    let onLoadMore: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if isOffline {
                HStack(spacing: 8) {
                    Image(systemName: "wifi.slash")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text(
                        (isStale
                            ? "目前為離線模式，顯示較早的本地緩存內容"
                            : "目前為離線模式，顯示本地緩存內容")
                            .adaptChinese(isSimplified: isSimplified)
                    )
                        .font(.caption)
                        .foregroundColor(.orange)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.08))
            }
            
            if isLoading && posts.isEmpty {
                Spacer()
                ProgressView("載入中...".adaptChinese(isSimplified: isSimplified))
                Spacer()
            } else if posts.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: type.icon)
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text((errorMessage ?? emptyText).adaptChinese(isSimplified: isSimplified))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                Spacer()
            } else {
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(spacing: 0) {
                        ForEach(posts) { post in
                            NavigationLink(destination: PostDetailView(post: post)) {
                                PostRow(post: post, type: type, isSimplified: isSimplified)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider()
                                .padding(.leading, 108)
                        }

                        if canLoadMore {
                            Button(action: onLoadMore) {
                                if isLoadingMore {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Text("載入更多".adaptChinese(isSimplified: isSimplified))
                                        .font(.system(size: 15, weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .disabled(isLoadingMore)
                            .padding(.vertical, 16)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 文章行（✅ 博客顯示作者）
struct PostRow: View {
    let post: WPPost
    let type: PostType
    let isSimplified: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            if let url = post.featuredImageURL {
                CachedAsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    placeholderIcon
                        .background(Color(UIColor.secondarySystemBackground))
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                placeholderIcon
                    .frame(width: 80, height: 80)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(post.localizedTitle(isSimplified: isSimplified))
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                if !post.formattedDate(isSimplified: isSimplified).isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11))
                        Text(post.formattedDate(isSimplified: isSimplified))
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(Color(red: 181/255, green: 8/255, blue: 56/255).opacity(0.8))
                }
                
                // ✅ 博客模塊顯示作者
                if type == .blog, !post.authorDisplayNames.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 11))
                        Text(post.authorDisplayNames.adaptChinese(isSimplified: isSimplified))
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.secondary)
                }
                
                Text(post.localizedExcerpt(isSimplified: isSimplified))
                    .font(.system(size: 14))
                    .lineLimit(2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    private var placeholderIcon: some View {
        Image(systemName: type.icon)
            .font(.title2)
            .foregroundColor(.secondary.opacity(0.4))
    }
}

// MARK: - 文章詳情（✅ 底部顯示作者）
struct PostDetailView: View {
    let post: WPPost
    @ObservedObject private var languageStore = AppLanguageStore.shared
    @State private var isLoadingWeb = true

    private var isSimp: Bool { languageStore.isSimplified }
    
    var body: some View {
        VStack(spacing: 0) {
            // ✅ 文章標題與發布時間（完整顯示，長標題自動換行）
            VStack(alignment: .leading, spacing: 8) {
                Text(post.localizedTitle(isSimplified: isSimp))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                
                if !post.formattedDate(isSimplified: isSimp).isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                        Text(post.formattedDate(isSimplified: isSimp))
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(Color(red: 181/255, green: 8/255, blue: 56/255).opacity(0.8))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            Divider()
            
            if isLoadingWeb {
                ProgressView()
                    .padding()
            }
            HTMLContentView(
                htmlContent: post.content.rendered,
                isSimplified: isSimp,
                isLoading: $isLoadingWeb
            )
            
            // ✅ 底部作者區域（僅博客顯示，或全部顯示均可）
            if !post.authorDisplayNames.isEmpty {
                AuthorFooterView(post: post, isSimplified: isSimp)
            }
        }
        .navigationTitle("")   // ✅ 移除導航列居中標題，避免與內容區標題重複
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - ✅ 新增：文章底部作者視圖
struct AuthorFooterView: View {
    let post: WPPost
    let isSimplified: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(post.authors ?? [], id: \.slug) { author in
                    HStack(spacing: 12) {
                        // 頭像
                        if let url = author.avatarImageURL {
                            CachedAsyncImage(url: url) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.secondary.opacity(0.4))
                            }
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .foregroundColor(.secondary.opacity(0.4))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(author.fullName.adaptChinese(isSimplified: isSimplified))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            if let desc = author.description, !desc.isEmpty {
                                Text(desc.adaptChinese(isSimplified: isSimplified))
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                    .lineLimit(3)
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
        }
    }
}

// MARK: - ✅ 緩存圖片視圖（記憶體 + 磁碟緩存，切換分頁／返回時直接顯示，避免閃爍）
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    @ViewBuilder private let content: (Image) -> Content
    @ViewBuilder private let placeholder: () -> Placeholder
    
    @StateObject private var loader: CachedImageLoader
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
        _loader = StateObject(wrappedValue: CachedImageLoader(url: url))
    }
    
    var body: some View {
        Group {
            if let uiImage = loader.image {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
            }
        }
        .task(id: url) {
            await loader.load(url)
        }
    }
}

// MARK: - HTML WebView
struct HTMLContentView: UIViewRepresentable {
    let htmlContent: String
    let isSimplified: Bool
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = false
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.backgroundColor = .clear
        webView.isOpaque = false
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let styledHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
                    font-size: 17px;
                    line-height: 1.6;
                    color: \(UIColor.label.hexString);
                    padding: 16px;
                    margin: 0;
                    word-wrap: break-word;
                }
                img { max-width: 100%; height: auto; border-radius: 8px; }
                h1, h2, h3 { color: \(Color(red: 181/255, green: 8/255, blue: 56/255).toHex()); }
                a { color: #B50838; }
                blockquote { border-left: 3px solid #B50838; padding-left: 12px; color: gray; }
            </style>
        </head>
        <body>\(htmlContent.adaptingHTMLChinese(isSimplified: isSimplified))</body>
        </html>
        """
        guard context.coordinator.lastLoadedHTML != styledHTML else { return }
        context.coordinator.lastLoadedHTML = styledHTML
        webView.loadHTMLString(
            styledHTML,
            baseURL: URL(string: "https://theanglicancatholic.org")
        )
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: HTMLContentView
        var lastLoadedHTML: String?

        init(_ parent: HTMLContentView) { self.parent = parent }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard navigationAction.navigationType == .linkActivated,
                  let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        }
    }
}

#Preview {
    ChurchInfoView()
}
