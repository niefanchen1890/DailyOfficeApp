import SwiftUI

/// 經課表的展示投影，只列出聖日文件明確提供的內容。
struct HolyDay1943Row: Identifiable {
    struct Office: Identifiable {
        let id: String
        let title: String
        let psalms: DailyOfficeFile.OfficePeriod.PsalmLectionaryGroup?
        let lessons: DailyOfficeFile.OfficePeriod.LessonsGroup?
    }
    let id: String
    let dateKey: String
    let name: String
    let isSpecial: Bool
    let offices: [Office]

    var dateLabel: String {
        "\(Int(dateKey.prefix(2)) ?? 0)月\(Int(dateKey.suffix(2)) ?? 0)日"
    }

    private struct Source: Decodable {
        let name: String
        let vigil: Period?
        let morning: Period?
        let evening: Period?
    }
    private struct Period: Decodable {
        let lessons: DailyOfficeFile.OfficePeriod.LessonsContainer?
        let psalms: DailyOfficeFile.OfficePeriod.PsalmLectionaryContainer?
        let lectionary_sets: DailyOfficeFile.OfficePeriod.LectionarySetContainer?
    }

    static func rows(data: Data, filename: String, language: AppLanguage) throws -> [Self] {
        let parts = filename.split(separator: "_")
        guard parts.count >= 3, parts[0] == "sanctorale",
              parts[1].count == 4, parts[1].allSatisfy(\.isNumber) else { return [] }
        guard let localized = LocalizedJSONResolver.resolve(data: data, language: language) else {
            throw CocoaError(.coderReadCorrupt)
        }
        let source = try JSONDecoder().decode(Source.self, from: localized)
        return [false, true].compactMap { special in
            var offices: [Office] = []
            for (key, title, period) in [("vigil", "前夕晚禱", source.vigil), ("morning", "早禱", source.morning), ("evening", "晚禱", source.evening)] {
                guard let period else { continue }
                func append(_ suffix: String, _ label: String, _ psalms: DailyOfficeFile.OfficePeriod.PsalmLectionaryGroup?, _ lessons: DailyOfficeFile.OfficePeriod.LessonsGroup?) {
                    guard !(psalms?.items.isEmpty ?? true) || lessons?.ot != nil || lessons?.nt != nil else { return }
                    offices.append(Office(id: key + suffix, title: label, psalms: psalms, lessons: lessons))
                }
                if special {
                    append("", title, period.psalms?.special, period.lessons?.special)
                } else if let sets = period.lectionary_sets?.year1943, !sets.isEmpty {
                    for (index, set) in sets.enumerated() {
                        let label = sets.count > 1 ? "\(title) · \(set.label ?? "組\(index + 1)")" : title
                        append("-\(index)", label, set.psalms ?? period.psalms?.year1943, set.lessons ?? period.lessons?.year1943)
                    }
                } else {
                    append("", title, period.psalms?.year1943, period.lessons?.year1943)
                }
            }
            guard !offices.isEmpty else { return nil }
            return Self(id: filename + (special ? "-special" : "-1943"), dateKey: String(parts[1]), name: source.name, isSpecial: special, offices: offices)
        }
    }
}

struct HolyDays1943View: View {
    let onPsalmTapped: (Office1943PsalmItem) -> Void
    let onLessonTapped: (Office1943Lesson) -> Void
    @AppStorage("appLanguage") private var languageCode = AppLanguage.traditional.rawValue
    @State private var rows: [HolyDay1943Row] = []
    private var isSimp: Bool { languageCode == AppLanguage.simplified.rawValue }

    var body: some View {
        DisclosureGroup {
            Text("* 表示另列的專屬詩篇或經課。日期按聖日固定日期排列。".adaptChinese(isSimplified: isSimp))
                .font(.caption2.bold()).foregroundStyle(.secondary)
            ForEach(rows) { row in
                DisclosureGroup {
                    ForEach(row.offices) { office in
                        VStack(alignment: .leading, spacing: 8) {
                            Label(office.title.adaptChinese(isSimplified: isSimp), systemImage: office.id.hasPrefix("morning") ? "sunrise.fill" : "moon.fill")
                                .font(.caption.bold())
                                .foregroundColor(office.id.hasPrefix("morning") ? .orange : .indigo)
                            Divider()
                            HStack(alignment: .top, spacing: 0) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("詩篇".adaptChinese(isSimplified: isSimp)).font(.caption2.bold()).foregroundStyle(.secondary)
                                    if let items = office.psalms?.items, !items.isEmpty {
                                        ForEach(Array(items.enumerated()), id: \.offset) { _, psalm in
                                            Button {
                                                onPsalmTapped(Office1943PsalmItem(number: psalm.number, verses: psalm.verses))
                                            } label: {
                                                Text(psalm.number + (psalm.verses.map { " (\($0))" } ?? ""))
                                                    .font(.system(size: 12, weight: .semibold))
                                            }.buttonStyle(.plain).foregroundStyle(.tint)
                                        }
                                    } else { Text("—").foregroundStyle(.secondary) }
                                }.frame(maxWidth: .infinity, alignment: .leading)
                                Divider().frame(height: 70).padding(.horizontal, 8)
                                lesson("第一經課", office.lessons?.ot)
                                Divider().frame(height: 70).padding(.horizontal, 8)
                                lesson("第二經課", office.lessons?.nt)
                            }.font(.footnote)
                        }
                        .padding(10)
                        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                    }
                } label: {
                    Text("\(row.dateLabel)　\(row.name)\(row.isSpecial ? "*" : "")".adaptChinese(isSimplified: isSimp))
                }
            }
        } label: {
            Text("聖日經課".adaptChinese(isSimplified: isSimp))
                .font(.headline).foregroundStyle(Color(red: 181/255, green: 8/255, blue: 56/255))
                .padding(.vertical, 6)
        }
        .task(id: languageCode) { loadRows() }
    }

    private func lesson(_ title: String, _ reference: DailyOfficeFile.OfficePeriod.LessonReference?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.adaptChinese(isSimplified: isSimp)).font(.caption2.bold()).foregroundStyle(.secondary)
            if let reference {
                Button {
                    onLessonTapped(Office1943Lesson(book: reference.book, chapter: reference.chapter))
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(reference.book.adaptChinese(isSimplified: isSimp))
                            .font(.system(size: 13, weight: .semibold))
                        Text(reference.chapter.adaptChinese(isSimplified: isSimp))
                            .font(.system(size: 11)).foregroundStyle(.secondary)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }.buttonStyle(.plain).foregroundStyle(.tint)
            } else { Text("—").foregroundStyle(.secondary) }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    private func loadRows() {
        var result: [HolyDay1943Row] = []
        let language = AppLanguage(rawValue: languageCode) ?? .traditional
        let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
        for url in urls where url.lastPathComponent.hasPrefix("sanctorale_") {
            do {
                let data = try Data(contentsOf: url)
                result += try HolyDay1943Row.rows(data: data, filename: url.deletingPathExtension().lastPathComponent, language: language)
            } catch {
                AppLog.debug("經課表無法列出 \(url.lastPathComponent): \(error)")
            }
        }
        rows = result.sorted { $0.dateKey == $1.dateKey ? $0.id < $1.id : $0.dateKey < $1.dateKey }
    }
}
