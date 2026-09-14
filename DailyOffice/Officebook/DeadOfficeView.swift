import SwiftUI

struct DeadOfficeView: View {
    @StateObject private var viewModel: DeadOfficeViewModel
    @AppStorage(AppLanguageStore.userDefaultsKey) private var appLanguageCode = AppLanguage.traditional.rawValue

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguageCode) ?? .traditional
    }

    private var isSimplified: Bool { language == .simplified }

    init(hour: DeadOfficeHour, date: Date = Date()) {
        _viewModel = StateObject(wrappedValue: DeadOfficeViewModel(hour: hour, date: date))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                header
                RubricBlock(text: viewModel.data.introductoryRubric)
                psalmsSection
                lessonSection(
                    title: viewModel.data.firstLessonTitle,
                    reading: viewModel.form.firstLesson,
                    verses: viewModel.firstLessonVerses
                )
                if let responsory = viewModel.form.firstResponsory {
                    responsorySection(responsory)
                }
                if let response = viewModel.form.firstLessonResponse {
                    LiturgyCard { responseRow(response) }
                }
                if let canticle = viewModel.form.firstCanticle {
                    canticleSection(canticle)
                }
                lessonSection(
                    title: viewModel.data.secondLessonTitle,
                    reading: viewModel.form.secondLesson,
                    verses: viewModel.secondLessonVerses
                )
                if let responsory = viewModel.form.secondResponsory {
                    responsorySection(responsory)
                }
                canticleSection(viewModel.form.secondCanticle)
                prayersSection
                collectsSection
                optionalPsalmSection

                Text(viewModel.form.endingText)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .padding(.bottom, 60)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle(viewModel.data.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.load(language: language) }
        .onChange(of: appLanguageCode) { _, _ in viewModel.load(language: language) }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Text(viewModel.data.title)
                .font(.system(size: 32, weight: .bold))
            Divider().padding(.horizontal, 60)
            Text(viewModel.form.title)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(LiturgyColors.crimson)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    private var psalmsSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: viewModel.data.psalmTitle)
                if viewModel.hour == .morning {
                    if let rubric = viewModel.form.psalmSelectionRubric {
                        RubricBlock(text: rubric)
                    }
                    Picker(isSimplified ? "诗篇组" : "詩篇組", selection: $viewModel.selectedMorningPsalmGroup) {
                        Text(isSimplified ? "组一" : "組一").tag("sunday_monday_thursday")
                        Text(isSimplified ? "组二" : "組二").tag("tuesday_friday")
                        Text(isSimplified ? "组三" : "組三").tag("wednesday_saturday")
                        Text(isSimplified ? "组四" : "組四").tag("all_souls")
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 2)
                    .onChange(of: viewModel.selectedMorningPsalmGroup) { _, _ in
                        viewModel.loadContent()
                    }

                    if let rubric = viewModel.form.psalmGroupRubrics?[viewModel.selectedMorningPsalmGroup] {
                        RubricBlock(text: rubric)
                    }
                }
                AntiphonLine(text: viewModel.data.psalmAntiphonOpening, isSimplified: isSimplified)
                ForEach(Array(viewModel.psalms.enumerated()), id: \.offset) { _, psalm in
                    deadPsalm(psalm)
                }
                AntiphonLine(text: viewModel.data.psalmAntiphonFull, isSimplified: isSimplified)
            }
        }
    }

    private func deadPsalm(_ psalm: (title: String, content: PsalmContent)) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(psalm.title).foregroundColor(LiturgyColors.crimson)
                if !psalm.content.latinTitle.isEmpty {
                    Text(psalm.content.latinTitle)
                        .italic()
                        .foregroundColor(.primary)
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .padding(.bottom, 4)

            ForEach(Array(psalm.content.verses.enumerated()), id: \.offset) { _, verse in
                numberedPsalmVerse(verse)
            }
        }
        .padding(.vertical, 6)
    }

    private func lessonSection(title: String, reading: DeadOfficeReading, verses: [BibleVerse]) -> some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: title)
                RubricBlock(text: viewModel.data.lessonRubric)
                Text("\(title)\(isSimplified ? "载在" : "載在")\(reading.book)\(reading.reference)")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                if verses.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView(isSimplified ? "载入经文..." : "載入經文...")
                            .padding(.vertical, 20)
                        Spacer()
                    }
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(verses) { verse in
                            Text(attributedScripture(verse.content))
                                .lineSpacing(6)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                Text("\(title)\(isSimplified ? "读毕。" : "讀畢。")")
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
                    .padding(.top, 8)
            }
        }
    }

    private func responsorySection(_ responsory: DeadOfficeResponsory) -> some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: responsory.title)
                BodyText(responsory.text)
                ForEach(responsory.responses, id: \.self) { response in
                    responseRow(response)
                }
            }
        }
    }

    private func canticleSection(_ canticle: DeadOfficeCanticle) -> some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: canticle.title)
                if let rubric = canticle.rubric { RubricBlock(text: rubric) }
                if let antiphon = canticle.antiphonOpening {
                    AntiphonLine(text: antiphon, isSimplified: isSimplified)
                }
                ForEach(canticle.verses, id: \.self) { BodyText($0) }
                if let antiphon = canticle.antiphonFull {
                    AntiphonLine(text: antiphon, isSimplified: isSimplified)
                }
            }
        }
    }

    private var prayersSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: viewModel.data.prayerTitle)
                ForEach(viewModel.data.kyrie, id: \.self) { BodyText($0) }
                BodyText(viewModel.data.lordPrayer)
                ForEach(viewModel.data.prayerResponses, id: \.self) { responseRow($0) }
            }
        }
    }

    private var collectsSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: isSimplified ? "祝文" : "祝文")
                RubricBlock(text: viewModel.collectsRubric)
                responseRow(viewModel.data.collectOpening)
                ForEach(viewModel.visibleCollects) { collect in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(collect.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(LiturgyColors.crimson)
                        BodyText(collect.text)
                    }
                }
                responseRow(viewModel.data.collectEnding)
            }
        }
    }

    @ViewBuilder
    private var optionalPsalmSection: some View {
        if viewModel.canShowOptionalPsalm, let psalm = viewModel.optionalPsalm {
            LiturgyCard {
                VStack(alignment: .leading, spacing: 14) {
                    RubricBlock(text: viewModel.form.optionalPsalmRubric)
                    Picker(isSimplified ? "结尾诗篇" : "結尾詩篇", selection: $viewModel.optionalPsalmChoice) {
                        Text(isSimplified ? "诵念" : "誦念").tag(DeadOfficeOptionalPsalmChoice.recite)
                        Text(isSimplified ? "省略" : "省略").tag(DeadOfficeOptionalPsalmChoice.omit)
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 2)
                    if viewModel.optionalPsalmChoice == .recite {
                        deadPsalm(psalm)
                        responseRow(DeadOfficeResponse(
                            leader: isSimplified ? "求主赐他们永恒的安息，" : "求主賜他們永恆的安息，",
                            people: isSimplified ? "并以永远的光照耀他们。" : "並以永遠的光照耀他們。"
                        ))
                    }
                }
            }
        }
    }

    private func responseRow(_ response: DeadOfficeResponse) -> some View {
        ResponsoryRow(response: Responsory(leader: response.leader, people: response.people))
    }

    private func numberedPsalmVerse(_ verse: String) -> some View {
        let trimmed = verse.trimmingCharacters(in: .whitespaces)
        let number = String(trimmed.prefix(while: \.isNumber))
        let text = number.isEmpty
            ? trimmed
            : String(trimmed.dropFirst(number.count)).trimmingCharacters(in: .whitespaces)

        return HStack(alignment: .firstTextBaseline, spacing: 6) {
            if !number.isEmpty {
                Text(number)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.red)
            }
            Text(text)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.primary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func attributedScripture(_ text: String) -> AttributedString {
        var result = AttributedString(text)
        result.font = .system(size: 17)
        result.foregroundColor = .primary
        guard let regex = try? NSRegularExpression(pattern: "(?:^|\\s)(\\d+)(?=\\s)") else {
            return result
        }
        let matches = regex.matches(
            in: text,
            range: NSRange(location: 0, length: (text as NSString).length)
        )
        for match in matches {
            if let range = Range(match.range(at: 1), in: result) {
                result[range].font = .system(size: 11, weight: .medium)
                result[range].foregroundColor = .red
                result[range].baselineOffset = 6
            }
        }
        return result
    }
}

private struct AntiphonLine: View {
    let text: String
    let isSimplified: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(isSimplified ? "对经：" : "對經：")
                .foregroundColor(.red)
            Text(text).foregroundColor(.primary)
        }
        .font(.system(size: 17))
        .fixedSize(horizontal: false, vertical: true)
    }
}
