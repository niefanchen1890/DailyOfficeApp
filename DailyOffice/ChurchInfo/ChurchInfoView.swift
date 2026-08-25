import SwiftUI
import WebKit

// MARK: - 主入口：教會資訊
struct ChurchInfoView: View {
    @StateObject private var wpService = WPAPIService()
    @State private var selectedTab = 0
    private let tabs = ["新聞", "彌撒", "博客"]  // ✅ 新增博客
    
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
                    Text("教會資訊")
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
            Picker("模塊", selection: $selectedTab) {
                ForEach(0..<tabs.count, id: \.self) { i in
                    Text(tabs[i]).tag(i)
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
                        isOffline: wpService.isOfflineNews
                    )
                case 1:
                    PostListView(
                        posts: wpService.massPosts,
                        isLoading: wpService.isLoadingMass,
                        emptyText: "暫無彌撒內容",
                        type: .mass,
                        isOffline: wpService.isOfflineMass
                    )
                case 2:
                    PostListView(
                        posts: wpService.blogPosts,
                        isLoading: wpService.isLoadingBlog,
                        emptyText: "暫無博客文章",
                        type: .blog,           // ✅ 新增
                        isOffline: wpService.isOfflineBlog
                    )
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarHidden(true)
        .task {
            await wpService.fetchNews()
            await wpService.fetchMass()
            await wpService.fetchBlog()  // ✅ 新增
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
    
    var body: some View {
        VStack(spacing: 0) {
            if isOffline {
                HStack(spacing: 8) {
                    Image(systemName: "wifi.slash")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("目前為離線模式，顯示本地緩存內容")
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
                ProgressView("載入中...")
                Spacer()
            } else if posts.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: type.icon)
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text(emptyText)
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(spacing: 0) {
                        ForEach(posts) { post in
                            NavigationLink(destination: PostDetailView(post: post)) {
                                PostRow(post: post, type: type)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider()
                                .padding(.leading, 108)
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
                Text(post.cleanTitle)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                if !post.formattedDate.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11))
                        Text(post.formattedDate)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(Color(red: 181/255, green: 8/255, blue: 56/255).opacity(0.8))
                }
                
                // ✅ 博客模塊顯示作者
                if type == .blog, !post.authorDisplayNames.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 11))
                        Text(post.authorDisplayNames)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.secondary)
                }
                
                Text(post.cleanExcerpt)
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
    @State private var isLoadingWeb = true
    
    var body: some View {
        VStack(spacing: 0) {
            // ✅ 文章標題與發布時間（完整顯示，長標題自動換行）
            VStack(alignment: .leading, spacing: 8) {
                Text(post.cleanTitle)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                
                if !post.formattedDate.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                        Text(post.formattedDate)
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
            HTMLContentView(htmlContent: post.content.rendered, isLoading: $isLoadingWeb)
            
            // ✅ 底部作者區域（僅博客顯示，或全部顯示均可）
            if !post.authorDisplayNames.isEmpty {
                AuthorFooterView(post: post)
            }
        }
        .navigationTitle("")   // ✅ 移除導航列居中標題，避免與內容區標題重複
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - ✅ 新增：文章底部作者視圖
struct AuthorFooterView: View {
    let post: WPPost
    
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
                            Text(author.fullName)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            if let desc = author.description, !desc.isEmpty {
                                Text(desc)
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
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
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
        <body>\(htmlContent)</body>
        </html>
        """
        webView.loadHTMLString(styledHTML, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: HTMLContentView
        init(_ parent: HTMLContentView) { self.parent = parent }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
    }
}

#Preview {
    ChurchInfoView()
}
