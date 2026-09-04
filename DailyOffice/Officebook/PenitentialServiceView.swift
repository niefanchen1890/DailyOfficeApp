import SwiftUI
import Combine

struct PenitentialServiceView: View {
    @StateObject private var viewModel = PenitentialServiceViewModel()
    @AppStorage(AppLanguageStore.userDefaultsKey) private var appLanguageCode = AppLanguage.traditional.rawValue
    let isEmbedded: Bool

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguageCode) ?? .traditional
    }
    
    init(isEmbedded: Bool = false) {
        self.isEmbedded = isEmbedded
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 12) {
                if !isEmbedded {
                    standaloneHeader
                }
                
                if isEmbedded {
                    embeddedIntroSection
                } else {
                    standaloneIntroSection
                }
                
                psalm51Section
                afterPsalmSection
                kyrieSection
                lordPrayerSection
                salvationSection
                letUsPray1
                confessionPrayersSection
                congregationRecitationSection
                optionalOmitRubricSection
                priestPrayerSection
                ashSection
                letUsPray2
                finalPrayersSection
                hymnSection
                finalCollectSection
                blessingSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .padding(.bottom, 60)
        }
        .onAppear {
            viewModel.load(language: language)
        }
        .onChange(of: appLanguageCode) {
            viewModel.load(language: language)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle(isEmbedded ? "" : viewModel.service.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 獨立使用標題
    private var standaloneHeader: some View {
        VStack(spacing: 0) {
            Text(viewModel.service.title)
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.top, 12)
            
            Divider()
                .background(Color.secondary.opacity(0.25))
                .padding(.horizontal, 60)
                .padding(.vertical, 20)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    // MARK: - 獨立使用開頭（含聖經選句）
    private var standaloneIntroSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                RubricBlock(text: viewModel.service.standalone.rubric)
                
                ForEach(viewModel.service.standalone.sentences.indices, id: \.self) { i in
                    let sentence = viewModel.service.standalone.sentences[i]
                    VStack(alignment: .leading, spacing: 4) {
                        Text(sentence.text)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.primary)
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text(sentence.reference)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.red)
                            .padding(.leading, 4)
                    }
                    .padding(.vertical, 6)
                }
                
                RubricBlock(text: viewModel.service.beforePsalmRubric)
            }
        }
    }
    
    // MARK: - 嵌入模式開頭
    private var embeddedIntroSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                RubricBlock(text: viewModel.service.embeddedRubric)
                RubricBlock(text: viewModel.service.beforePsalmRubric)
            }
        }
    }
    
    // MARK: - 詩篇第51篇（從 psalms.json 動態載入）
    private var psalm51Section: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                // 🌟 標題：從載入結果動態取得，或預設顯示
                SectionTitle(text: viewModel.psalmTitle)
                
                if let psalm = viewModel.psalm51 {
                    if !psalm.latinTitle.isEmpty {
                        Text(psalm.latinTitle)
                            .font(.system(size: 17, weight: .semibold))
                            .italic()
                            .foregroundColor(.primary)
                            .padding(.bottom, 4)
                    }
                    
                    if !psalm.antiphon.isEmpty {
                        MorningPrayerView.AntiphonRow(text: psalm.antiphon)
                            .padding(.bottom, 8)
                    }
                    
                    ForEach(psalm.verses, id: \.self) { verse in
                        psalmVerseRow(verse)
                    }
                    
                    // 榮耀頌
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(viewModel.service.psalm.gloriaPatri, id: \.self) { line in
                            BodyText(line)
                        }
                    }
                    .padding(.top, 8)
                    
                    if !psalm.antiphon.isEmpty {
                        MorningPrayerView.AntiphonRow(text: psalm.antiphon)
                            .padding(.top, 8)
                    }
                } else {
                    HStack {
                        Spacer()
                        ProgressView(viewModel.service.psalm.loadingText)
                            .padding(.vertical, 20)
                        Spacer()
                    }
                }
            }
        }
    }
    
    // MARK: - 詩篇節行（紅色節號）
    private func psalmVerseRow(_ verse: String) -> some View {
        let trimmed = verse.trimmingCharacters(in: .whitespaces)
        var number = ""
        for char in trimmed { if char.isNumber { number.append(char) } else { break } }
        let text = number.isEmpty ? trimmed : String(trimmed.dropFirst(number.count)).trimmingCharacters(in: .whitespaces)
        
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
    
    // MARK: - 詩篇後禮規
    private var afterPsalmSection: some View {
        LiturgyCard {
            RubricBlock(text: viewModel.service.afterPsalmRubric)
        }
    }
    
    // MARK: - 憐憫啟應
    private var kyrieSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(viewModel.service.kyrieResponses, id: \.self) { item in
                    responsoryRow(item)
                }
            }
        }
    }
    
    // MARK: - 主禱文
    private var lordPrayerSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: viewModel.service.lordPrayerTitle)
                BodyText(viewModel.service.lordPrayerText)
            }
        }
    }
    
    // MARK: - 拯救啟應
    private var salvationSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(viewModel.service.salvationResponses, id: \.self) { item in
                    responsoryRow(item)
                }
            }
        }
    }
    
    // MARK: - 我們要禱告（第一次）
    private var letUsPray1: some View {
        LiturgyCard {
            responsoryRow(PenitentialResponsoryItem(leader: viewModel.service.letUsPray, people: nil))
        }
    }
    
    // MARK: - 認罪禱文
    private var confessionPrayersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.service.confessionPrayers, id: \.self) { prayer in
                LiturgyCard {
                    ForEach(prayer.paragraphs, id: \.self) { p in
                        BodyText(p)
                    }
                }
            }
        }
    }
    
    // MARK: - 會眾誦經
    private var congregationRecitationSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                if let rubric = viewModel.service.congregationRecitation.rubric {
                    RubricBlock(text: rubric)
                }
                ForEach(viewModel.service.congregationRecitation.paragraphs, id: \.self) { p in
                    BodyText(p)
                }
            }
        }
    }
    
    // MARK: - 可省略禮規
    private var optionalOmitRubricSection: some View {
        LiturgyCard {
            RubricBlock(text: viewModel.service.optionalOmitRubric)
        }
    }
    
    // MARK: - 主禮誦讀禱文
    private var priestPrayerSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                if let rubric = viewModel.service.priestPrayer.rubric {
                    RubricBlock(text: rubric)
                }
                ForEach(viewModel.service.priestPrayer.paragraphs, id: \.self) { p in
                    BodyText(p)
                }
            }
        }
    }
    
    // MARK: - 塵土啟應
    private var ashSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(viewModel.service.ashResponses, id: \.self) { item in
                    responsoryRow(item)
                }
            }
        }
    }
    
    // MARK: - 我們要禱告（第二次）
    private var letUsPray2: some View {
        LiturgyCard {
            responsoryRow(PenitentialResponsoryItem(leader: viewModel.service.letUsPray, people: nil))
        }
    }
    
    // MARK: - 最後三篇禱文
    private var finalPrayersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.service.finalPrayers, id: \.self) { prayer in
                LiturgyCard {
                    ForEach(prayer.paragraphs, id: \.self) { p in
                        BodyText(p)
                    }
                }
            }
        }
    }
    
    // MARK: - 聖詩（懸掛縮進 + 節後斷行）
    private var hymnSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(viewModel.service.hymn.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(LiturgyColors.crimson)
                    .padding(.bottom, 2)
                
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.service.hymn.verses.indices, id: \.self) { i in
                        hymnVerseRow(
                            prefix: numberToChinese(i + 1) + "、",
                            text: viewModel.service.hymn.verses[i]
                        )
                        
                        // 節後斷行（最後一節除外）
                        if i < viewModel.service.hymn.verses.count - 1 {
                            Spacer().frame(height: 14)
                        }
                    }
                }
            }
        }
    }

    // MARK: - 聖詩單節（逗號斷行 + 懸掛縮進）
    private func hymnVerseRow(prefix: String, text: String) -> some View {
        // 按逗號分割，保留逗號在第一行末尾
        let segments = text.components(separatedBy: "，")
        
        return HStack(alignment: .top, spacing: 0) {
            // 紅色中文序號（固定寬度）
            Text(prefix)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.red)
                .frame(width: 40, alignment: .leading)
            
            // 正文：逗號處斷行，多行均與頓號後首字對齊
            VStack(alignment: .leading, spacing: 2) {
                ForEach(segments.indices, id: \.self) { i in
                    let segment = segments[i]
                    let isLast = i == segments.count - 1
                    // 非最後一段，末尾補回逗號；最後一段保持原樣（含句末標點）
                    let displayText = isLast ? segment : segment + "，"
                    
                    Text(displayText)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
    
    // MARK: - 最後祝文
    private var finalCollectSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                if let rubric = viewModel.service.finalCollect.rubric {
                    RubricBlock(text: rubric)
                }
                ForEach(viewModel.service.finalCollect.paragraphs, id: \.self) { p in
                    BodyText(p)
                }
            }
        }
    }
    
    // MARK: - 祝福文
    private var blessingSection: some View {
        LiturgyCard {
            BodyText(viewModel.service.blessing)
        }
    }

    private func responsoryRow(_ item: PenitentialResponsoryItem) -> some View {
        PenitentialResponsoryRow(
            leaderLabel: viewModel.service.leaderLabel,
            peopleLabel: viewModel.service.peopleLabel,
            leader: item.leader,
            people: item.people
        )
    }
}

// MARK: - 懺悔文啟應行
struct PenitentialResponsoryRow: View {
    let leaderLabel: String
    let peopleLabel: String
    let leader: String
    let people: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 4) {
                Text(leaderLabel)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.red)
                    .frame(width: 36, alignment: .leading)
                Text(leader)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            
            if let people = people, !people.isEmpty {
                HStack(alignment: .top, spacing: 4) {
                    Text(peopleLabel)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
                        .frame(width: 36, alignment: .leading)
                    Text(people)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                .padding(.bottom, 4)
            }
        }
    }
}

// MARK: - 預覽
struct PenitentialServiceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PenitentialServiceView()
        }
    }
}
