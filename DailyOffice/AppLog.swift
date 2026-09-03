import Foundation
import OSLog

/// 全專案統一日誌入口。
///
/// `debug` 只在 Xcode 的 Debug 版本執行，App Store／Release 版本會在編譯時移除；
/// `warning` 與 `error` 則保留，方便追查真正的資源缺失或解析錯誤。
enum AppLog {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "DailyOffice",
        category: "runtime"
    )

    static func debug(_ message: @autoclosure () -> String) {
        #if DEBUG
        let text = message()
        logger.debug("\(text, privacy: .public)")
        #endif
    }

    static func warning(_ message: @autoclosure () -> String) {
        let text = message()
        logger.warning("\(text, privacy: .public)")
    }

    static func error(_ message: @autoclosure () -> String) {
        let text = message()
        logger.error("\(text, privacy: .public)")
    }
}
