import SwiftUI

struct LitanyView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 12) {
                header
                mainResponsesSection
                lordPrayerSection
                intermediateSection
                closingSection
                finalRubricSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .padding(.bottom, 60)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("總禱文")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 標題
    private var header: some View {
        VStack(spacing: 0) {
            Text(LitanyData.title)
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
    
    // MARK: - 總禱文啟應
    private var mainResponsesSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: LitanyData.title)
                RubricBlock(text: LitanyData.mainRubric)
                
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(LitanyData.mainResponses, id: \.self) { response in
                        LitanyResponsoryRow(response: response)
                    }
                }
            }
        }
    }
    
    // MARK: - 主禱文
    private var lordPrayerSection: some View {
        LiturgyCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(text: LitanyData.lordPrayer.title!)
                RubricBlock(text: LitanyData.lordPrayer.rubric!)
                
                ForEach(LitanyData.lordPrayer.paragraphs, id: \.self) { p in
                    BodyText(p)
                }
                
                RubricBlock(text: LitanyData.lordPrayerNote)
            }
        }
    }
    
    // MARK: - 中間段落（啟應＋禱文＋誦唸）
    private var intermediateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 中間啟應
            LiturgyCard {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(LitanyData.intermediateResponses, id: \.self) { response in
                        LitanyResponsoryRow(response: response)
                    }
                }
            }
            
            // 中間禱文
            LiturgyCard {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(LitanyData.intermediatePrayer.paragraphs, id: \.self) { p in
                        BodyText(p)
                    }
                }
            }
            
            // 誦唸段落（主禮者／會眾）
            ForEach(LitanyData.middleRecitations, id: \.rubric) { recitation in
                LiturgyCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recitation.rubric)
                            .font(.system(size: 15, weight: .regular))
                            .italic()
                            .foregroundColor(.red)
                        BodyText(recitation.text)
                    }
                }
            }
        }
    }
    
    // MARK: - 結尾（啟應＋禱文）
    private var closingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 結尾啟應
            LiturgyCard {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(LitanyData.closingResponses, id: \.self) { response in
                        LitanyResponsoryRow(response: response)
                    }
                }
            }
            
            // 結尾禱文
            LiturgyCard {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(LitanyData.closingPrayer.paragraphs, id: \.self) { p in
                        BodyText(p)
                    }
                }
            }
        }
    }
    
    // MARK: - 最後禮規
    private var finalRubricSection: some View {
        LiturgyCard {
            RubricBlock(text: LitanyData.finalRubric)
        }
    }
}

// MARK: - 總禱文啟應行（啟：／應： 紅色前綴，懸掛對齊）
struct LitanyResponsoryRow: View {
    let response: LitanyResponsory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 4) {
                Text("啟：")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.red)
                    .frame(width: 36, alignment: .leading)
                Text(response.leader)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            
            if !response.people.isEmpty {
                HStack(alignment: .top, spacing: 4) {
                    Text("應：")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
                        .frame(width: 36, alignment: .leading)
                    Text(response.people)
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
struct LitanyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LitanyView()
        }
    }
}
