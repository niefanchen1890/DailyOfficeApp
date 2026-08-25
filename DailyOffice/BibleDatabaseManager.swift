import Foundation
import SQLite3

struct BibleParagraph: Identifiable {
    let id = UUID()
    let heading: String?
    let verseRange: String
    let content: String
}

class BibleDatabaseManager {
    static let shared = BibleDatabaseManager()
    var db: OpaquePointer?
    
    init() {
        openDatabase()
    }
    
    func openDatabase() {
        guard let dbPath = Bundle.main.path(forResource: "bible_all_versions", ofType: "db") else {
            print("❌ 錯誤：找不到資料庫檔案 bible_all_versions.db")
            return
        }
        
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("✅ 成功連線到本地聖經資料庫")
        }
    }
    
    func fetchChapter(version: String, book: String, chapter: Int) -> [BibleParagraph] {
        var paragraphs: [BibleParagraph] = []
        // 🌟 確保這裡查詢的是 version 欄位，注入 SSEB 後，傳入的 version 參數應為 "SSEB"
        let query = "SELECT heading, verse_range, content FROM paragraphs WHERE version = ? AND book_name = ? AND chapter = ? ORDER BY id ASC"
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (version as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (book as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 3, Int32(chapter))
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let heading = sqlite3_column_text(statement, 0).map { String(cString: $0) }
                let verseRange = String(cString: sqlite3_column_text(statement, 1))
                let content = String(cString: sqlite3_column_text(statement, 2))
                
                paragraphs.append(BibleParagraph(heading: heading, verseRange: verseRange, content: content))
            }
        }
        sqlite3_finalize(statement)
        return paragraphs
    }
}
