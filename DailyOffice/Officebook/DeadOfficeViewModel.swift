import Combine
import Foundation

enum DeadOfficeHour: String, Hashable {
    case morning
    case evening
}

enum DeadOfficeOptionalPsalmChoice: String, CaseIterable, Hashable {
    case recite
    case omit
}

@MainActor
final class DeadOfficeViewModel: ObservableObject {
    @Published private(set) var data: DeadOfficeFile
    @Published private(set) var psalms: [(title: String, content: PsalmContent)] = []
    @Published private(set) var optionalPsalm: (title: String, content: PsalmContent)?
    @Published private(set) var firstLessonVerses: [BibleVerse] = []
    @Published private(set) var secondLessonVerses: [BibleVerse] = []
    @Published private(set) var selectedDate: Date
    @Published var selectedMorningPsalmGroup = "sunday_monday_thursday"
    @Published var optionalPsalmChoice: DeadOfficeOptionalPsalmChoice = .recite

    let hour: DeadOfficeHour

    init(hour: DeadOfficeHour, date: Date = Date()) {
        self.hour = hour
        self.selectedDate = date
        self.data = DeadOfficeDataLoader.shared.load()
    }

    var form: DeadOfficeForm {
        hour == .morning ? data.morning : data.evening
    }

    var isAllSoulsDay: Bool {
        LiturgyCoreService.shared.resolve(for: selectedDate, isEvening: hour == .evening)
            .identifier == .allSouls
    }

    var isAllSaintsSecondVespers: Bool {
        guard hour == .evening else { return false }
        let components = Calendar.current.dateComponents([.month, .day], from: selectedDate)
        let liturgy = LiturgyCoreService.shared.resolve(for: selectedDate, isEvening: true)
        return components.month == 11 && components.day == 1 && !liturgy.isFirstVespers
    }

    var visibleCollects: [DeadOfficeCollect] {
        if isAllSoulsDay || isAllSaintsSecondVespers {
            return form.collects.filter { $0.id == "common_dead" }
        }
        return form.collects
    }

    var collectsRubric: String {
        if isAllSoulsDay { return form.allSoulsCollectsRubric }
        if isAllSaintsSecondVespers, let rubric = form.allSaintsCollectsRubric { return rubric }
        return form.collectsRubric
    }

    var canShowOptionalPsalm: Bool {
        !isAllSoulsDay && !isAllSaintsSecondVespers
    }

    func load(language: AppLanguage) {
        data = DeadOfficeDataLoader.shared.load(language: language)
        optionalPsalmChoice = .recite
        if hour == .morning, isAllSoulsDay {
            selectedMorningPsalmGroup = "all_souls"
        }
        loadContent()
    }

    func loadContent() {
        let numbers: [String]
        if hour == .morning, let groups = form.weekdayPsalmGroups {
            numbers = groups[selectedMorningPsalmGroup] ?? form.psalms
        } else {
            numbers = form.psalms
        }
        psalms = numbers.compactMap { PsalmsLoader.shared.psalm(number: $0) }
        optionalPsalm = PsalmsLoader.shared.psalm(number: form.optionalPsalm)
        loadReadings()
    }

    private func loadReadings() {
        firstLessonVerses = []
        secondLessonVerses = []
        let first = form.firstLesson
        let second = form.secondLesson

        DispatchQueue.global(qos: .userInitiated).async {
            let firstVersion = BibleJSONService.shared.isApocrypha(book: first.book) ? "APO1933" : first.version
            let secondVersion = BibleJSONService.shared.isApocrypha(book: second.book) ? "APO1933" : second.version
            let firstTexts = BibleJSONService.shared.fetchVersesList(
                version: firstVersion,
                book: first.book,
                reference: first.reference
            )
            let secondTexts = BibleJSONService.shared.fetchVersesList(
                version: secondVersion,
                book: second.book,
                reference: second.reference
            )

            let makeVerses: ([String]) -> [BibleVerse] = { texts in
                texts.map { text in
                    let number = Int(text.components(separatedBy: " ").first ?? "0") ?? 0
                    return BibleVerse(verse: number, content: text)
                }
            }

            DispatchQueue.main.async {
                self.firstLessonVerses = makeVerses(firstTexts)
                self.secondLessonVerses = makeVerses(secondTexts)
            }
        }
    }
}
