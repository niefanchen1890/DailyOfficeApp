import SwiftUI

struct LitanyView: View {
    // 1. 監聽當前語言狀態
    @AppStorage("appLanguage") private var appLanguageCode: String = AppLanguage.traditional.rawValue
    @StateObject private var loader = LitanyDataLoader.shared
    
    private var currentLang: AppLanguage {
        AppLanguage(rawValue: appLanguageCode) ?? .traditional
    }
    
    var body: some View {
        Group {
            if let data = loader.uiData {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 12) {
                        header(data: data)
                        mainResponsesSection(data: data)
                        lordPrayerSection(data: data)
                        intermediateSection(data: data)
                        closingSection(data: data)
                        finalRubricSection(data: data)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .padding(.bottom, 60)
                }
                .background(Color(UIColor.systemGroupedBackground))
                // 🌟 動態標題
                .navigationTitle(data.title.text(for: currentLang))
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ProgressView("載入中...")
            }
        }
    }
    
    // MARK: - 視圖拆分
    private func header(data: UILitanyData) -> some View {
        VStack(spacing: 0) {
            Text(data.title.text(for: currentLang))
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
    
    private func mainResponsesSection(data: UILitanyData) -> some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: data.title.text(for: currentLang))
                RubricBlock(text: data.mainRubric.text(for: currentLang))
                
                VStack(alignment: .leading, spacing: 2) {
                    // 🌟 不需要 id: \.self，因為模型已內建 Identifiable
                    ForEach(data.mainResponses) { response in
                        LitanyResponsoryRow(response: response, lang: currentLang)
                    }
                }
            }
        }
    }
    
    private func lordPrayerSection(data: UILitanyData) -> some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                if let title = data.lordPrayer.title?.text(for: currentLang) {
                    SectionTitle(text: title)
                }
                if let rubric = data.lordPrayer.rubric?.text(for: currentLang) {
                    RubricBlock(text: rubric)
                }
                ForEach(data.lordPrayer.paragraphs, id: \.self) { p in
                    BodyText(p.text(for: currentLang))
                }
                RubricBlock(text: data.lordPrayerNote.text(for: currentLang))
            }
        }
    }
    
    private func intermediateSection(data: UILitanyData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            LiturgyCard {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(data.intermediateResponses) { response in
                        LitanyResponsoryRow(response: response, lang: currentLang)
                    }
                }
            }
            LiturgyCard {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(data.intermediatePrayer.paragraphs, id: \.self) { p in
                        BodyText(p.text(for: currentLang))
                    }
                }
            }
            ForEach(data.middleRecitations) { recitation in
                LiturgyCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recitation.rubric.text(for: currentLang))
                            .font(.system(size: 15, weight: .regular))
                            .italic()
                            .foregroundColor(.red)
                        BodyText(recitation.text.text(for: currentLang))
                    }
                }
            }
        }
    }
    
    private func closingSection(data: UILitanyData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            LiturgyCard {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(data.closingResponses) { response in
                        LitanyResponsoryRow(response: response, lang: currentLang)
                    }
                }
            }
            LiturgyCard {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(data.closingPrayer.paragraphs, id: \.self) { p in
                        BodyText(p.text(for: currentLang))
                    }
                }
            }
        }
    }
    
    private func finalRubricSection(data: UILitanyData) -> some View {
        LiturgyCard {
            RubricBlock(text: data.finalRubric.text(for: currentLang))
        }
    }
}

// MARK: - 總禱文啟應行（支援雙語動態切換 啟/應 前綴）
struct LitanyResponsoryRow: View {
    let response: UILitanyResponsory
    let lang: AppLanguage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 4) {
                // 🌟 啟/启 動態判斷
                ResponsoryMarker(role: .leader, isSimplified: lang == .simplified)
                Text(response.leader.text(for: lang))
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            
            let peopleText = response.people.text(for: lang)
            if !peopleText.isEmpty {
                HStack(alignment: .top, spacing: 4) {
                    // 🌟 應/应 動態判斷
                    ResponsoryMarker(role: .people, isSimplified: lang == .simplified)
                    Text(peopleText)
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
