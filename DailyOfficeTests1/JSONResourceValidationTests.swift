import Foundation
import XCTest

final class JSONResourceValidationTests: XCTestCase {
    func testAllJSONResourcesHaveValidSyntax() throws {
        guard let resourcesRootURL = Bundle.main.resourceURL else {
            XCTFail("無法找到 App 的資源目錄。")
            return
        }

        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(
            at: resourcesRootURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            XCTFail("無法讀取專案資源目錄：\(resourcesRootURL.path)")
            return
        }

        let jsonFiles = enumerator
            .compactMap { $0 as? URL }
            .filter { $0.pathExtension.lowercased() == "json" }
            .sorted { $0.path < $1.path }

        XCTAssertFalse(jsonFiles.isEmpty, "專案中沒有找到任何 JSON 檔案，請確認測試掃描路徑。")

        var failures: [String] = []

        for fileURL in jsonFiles {
            do {
                let data = try Data(contentsOf: fileURL)

                if let text = String(data: data, encoding: .utf8),
                   let location = trailingCommaLocation(in: text) {
                    let relativePath = fileURL.path.replacingOccurrences(
                        of: resourcesRootURL.path + "/",
                        with: ""
                    )
                    failures.append(
                        "• \(relativePath)\n  第 \(location.line) 行、第 \(location.column) 欄附近有結尾多餘逗號。"
                    )
                    continue
                }

                _ = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
            } catch {
                let relativePath = fileURL.path.replacingOccurrences(
                    of: resourcesRootURL.path + "/",
                    with: ""
                )
                failures.append("• \(relativePath)\n  \(error.localizedDescription)")
            }
        }

        XCTAssertTrue(
            failures.isEmpty,
            "發現 \(failures.count) 個格式不合法的 JSON 檔案（共檢查 \(jsonFiles.count) 個）：\n\n\(failures.joined(separator: "\n\n"))"
        )
    }

    /// Apple 的新版解析器可能接受結尾多餘逗號，但標準 JSON 不允許。
    /// 此處只檢查字串外的「逗號 + ] 或 }」，不會誤判正文中的標點。
    private func trailingCommaLocation(in text: String) -> (line: Int, column: Int)? {
        let characters = Array(text)
        var isInsideString = false
        var isEscaped = false
        var line = 1
        var column = 0

        for index in characters.indices {
            let character = characters[index]
            column += 1

            if character == "\n" {
                line += 1
                column = 0
            }

            if isInsideString {
                if isEscaped {
                    isEscaped = false
                } else if character == "\\" {
                    isEscaped = true
                } else if character == "\"" {
                    isInsideString = false
                }
                continue
            }

            if character == "\"" {
                isInsideString = true
                continue
            }

            guard character == "," else { continue }

            var nextIndex = characters.index(after: index)
            while nextIndex < characters.endIndex, characters[nextIndex].isWhitespace {
                nextIndex = characters.index(after: nextIndex)
            }

            if nextIndex < characters.endIndex,
               characters[nextIndex] == "]" || characters[nextIndex] == "}" {
                return (line, column)
            }
        }

        return nil
    }
}
