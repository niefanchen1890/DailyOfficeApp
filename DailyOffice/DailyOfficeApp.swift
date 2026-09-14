//
//  DailyOfficeApp.swift
//  DailyOffice
//
//  Created by Anthony Lim on 4/27/26.
//

import SwiftUI

enum AppAppearance: String, CaseIterable {
    case light
    case dark
    case automatic

    var title: String {
        switch self {
        case .light: return "白晝模式"
        case .dark: return "黑夜模式"
        case .automatic: return "自動"
        }
    }

    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .automatic: return .unspecified
        }
    }
}

@main
struct DailyOfficeApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}

private struct AppRootView: View {
    @AppStorage("appAppearance") private var appearance: AppAppearance = .automatic

    var body: some View {
        ContentView()
            .background(WindowAppearanceUpdater(appearance: appearance))
    }
}

/// 直接更新所在視窗；自動模式清除覆寫，恢復系統外觀。
struct WindowAppearanceUpdater: UIViewRepresentable {
    let appearance: AppAppearance

    func makeUIView(context: Context) -> AppearanceView {
        let view = AppearanceView()
        view.isUserInteractionEnabled = false
        view.style = appearance.interfaceStyle
        return view
    }

    func updateUIView(_ uiView: AppearanceView, context: Context) {
        uiView.style = appearance.interfaceStyle
    }

    final class AppearanceView: UIView {
        var style: UIUserInterfaceStyle = .unspecified {
            didSet { applyStyle() }
        }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            applyStyle()
        }

        private func applyStyle() {
            guard let window, window.overrideUserInterfaceStyle != style else { return }
            window.overrideUserInterfaceStyle = style
        }
    }
}
