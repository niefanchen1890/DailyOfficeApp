import SwiftUI
import Combine

struct PenitentialServiceView: View {
    @StateObject private var viewModel = PenitentialServiceViewModel()
    let isEmbedded: Bool
    
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
            viewModel.loadPsalm()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle(isEmbedded ? "" : "大齋首日懺悔文")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 獨立使用標題
    private var standaloneHeader: some View {
        VStack(spacing: 0) {
            Text(PenitentialServiceData.title)
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
                RubricBlock(text: PenitentialServiceData.standalone.rubric)
                
                ForEach(PenitentialServiceData.standalone.sentences.indices, id: \.self) { i in
                    let sentence = PenitentialServiceData.standalone.sentences[i]
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
                
                RubricBlock(text: PenitentialServiceData.beforePsalmRubric)
            }
        }
    }
    
    // MARK: - 嵌入模式開頭
    private var embeddedIntroSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                RubricBlock(text: PenitentialServiceData.embeddedRubric)
                RubricBlock(text: PenitentialServiceData.beforePsalmRubric)
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
                        BodyText("但願榮耀歸於聖父、聖子、聖靈；")
                        BodyText("※起初怎樣，現在以及永遠，也是怎樣，世世無盡。阿們。")
                    }
                    .padding(.top, 8)
                    
                    if !psalm.antiphon.isEmpty {
                        MorningPrayerView.AntiphonRow(text: psalm.antiphon)
                            .padding(.top, 8)
                    }
                } else {
                    HStack {
                        Spacer()
                        ProgressView("載入詩篇...")
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
            RubricBlock(text: PenitentialServiceData.afterPsalmRubric)
        }
    }
    
    // MARK: - 憐憫啟應
    private var kyrieSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(PenitentialServiceData.kyrieResponses, id: \.self) { item in
                    PenitentialResponsoryRow(leader: item.leader, people: item.people)
                }
            }
        }
    }
    
    // MARK: - 主禱文
    private var lordPrayerSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: "主禱文")
                BodyText(PenitentialServiceData.lordPrayerText)
            }
        }
    }
    
    // MARK: - 拯救啟應
    private var salvationSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(PenitentialServiceData.salvationResponses, id: \.self) { item in
                    PenitentialResponsoryRow(leader: item.leader, people: item.people)
                }
            }
        }
    }
    
    // MARK: - 我們要禱告（第一次）
    private var letUsPray1: some View {
        LiturgyCard {
            PenitentialResponsoryRow(leader: "我們要禱告。", people: nil)
        }
    }
    
    // MARK: - 認罪禱文
    private var confessionPrayersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(PenitentialServiceData.confessionPrayers, id: \.self) { prayer in
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
                if let rubric = PenitentialServiceData.congregationRecitation.rubric {
                    RubricBlock(text: rubric)
                }
                ForEach(PenitentialServiceData.congregationRecitation.paragraphs, id: \.self) { p in
                    BodyText(p)
                }
            }
        }
    }
    
    // MARK: - 可省略禮規
    private var optionalOmitRubricSection: some View {
        LiturgyCard {
            RubricBlock(text: PenitentialServiceData.optionalOmitRubric)
        }
    }
    
    // MARK: - 主禮誦讀禱文
    private var priestPrayerSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                if let rubric = PenitentialServiceData.priestPrayer.rubric {
                    RubricBlock(text: rubric)
                }
                ForEach(PenitentialServiceData.priestPrayer.paragraphs, id: \.self) { p in
                    BodyText(p)
                }
            }
        }
    }
    
    // MARK: - 塵土啟應
    private var ashSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(PenitentialServiceData.ashResponses, id: \.self) { item in
                    PenitentialResponsoryRow(leader: item.leader, people: item.people)
                }
            }
        }
    }
    
    // MARK: - 我們要禱告（第二次）
    private var letUsPray2: some View {
        LiturgyCard {
            PenitentialResponsoryRow(leader: "我們要禱告。", people: nil)
        }
    }
    
    // MARK: - 最後三篇禱文
    private var finalPrayersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(PenitentialServiceData.finalPrayers, id: \.self) { prayer in
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
                Text(PenitentialServiceData.hymn.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(LiturgyColors.crimson)
                    .padding(.bottom, 2)
                
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(PenitentialServiceData.hymn.verses.indices, id: \.self) { i in
                        hymnVerseRow(
                            prefix: numberToChinese(i + 1) + "、",
                            text: PenitentialServiceData.hymn.verses[i]
                        )
                        
                        // 節後斷行（最後一節除外）
                        if i < PenitentialServiceData.hymn.verses.count - 1 {
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
                if let rubric = PenitentialServiceData.finalCollect.rubric {
                    RubricBlock(text: rubric)
                }
                ForEach(PenitentialServiceData.finalCollect.paragraphs, id: \.self) { p in
                    BodyText(p)
                }
            }
        }
    }
    
    // MARK: - 祝福文
    private var blessingSection: some View {
        LiturgyCard {
            BodyText(PenitentialServiceData.blessing)
        }
    }
}

// MARK: - 懺悔文啟應行
struct PenitentialResponsoryRow: View {
    let leader: String
    let people: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 4) {
                Text("啟：")
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
                    Text("應：")
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

// MARK: - ViewModel（修正版）
class PenitentialServiceViewModel: ObservableObject {
    @Published var psalm51: PsalmContent?
    @Published var psalmTitle: String = "詩篇第51篇"
    
    func loadPsalm() {
        // 🌟 修正：PsalmsLoader.psalm(number:) 接收 String，返回 (title, content)? 元組
        if let result = PsalmsLoader.shared.psalm(number: "51") {
            psalm51 = result.content
            psalmTitle = result.title
        } else {
            AppLog.warning("⚠️ [懺悔文] 無法載入詩篇第51篇")
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
