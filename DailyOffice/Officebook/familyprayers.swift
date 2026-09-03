import SwiftUI

// MARK: - 通用家用禱文部分視圖
struct HomePrayerPartView: View {
    let part: HomePrayerPart
    let collectOfTheDay: DailyOfficeFile.OfficePeriod.CollectJSON?  // 當日祝文
    @ObservedObject private var languageStore = AppLanguageStore.shared
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 12) {
                // 標題區域（僅「家用禱文」與「早禱/晚禱」標題）
                header
                
                // 所有禱文內容（含主禮規）集中在一個卡片內
                LiturgyCard {
                    VStack(alignment: .leading, spacing: 0) {
                        // 主禮規放在卡片最頂部
                        RubricBlock(text: part.mainRubric)
                            .padding(.bottom, 16)
                        
                        ForEach(part.sections.indices, id: \.self) { index in
                            let section = part.sections[index]
                            let isLast = index == part.sections.count - 1
                            
                            sectionContent(section: section)
                            
                            if !isLast {
                                Divider()
                                    .background(Color.secondary.opacity(0.2))
                                    .padding(.vertical, 16)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .padding(.bottom, 60)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle(part.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 頁面標題（僅「家用禱文」與「早禱/晚禱」）
    private var header: some View {
        VStack(spacing: 0) {
            Text(HomePrayerData.title)
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.top, 12)
            
            Text(part.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
            
            Divider()
                .background(Color.secondary.opacity(0.25))
                .padding(.horizontal, 60)
                .padding(.vertical, 20)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    // MARK: - 單一段落內容
    private func sectionContent(section: HomePrayerSection) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let preRubric = section.preRubric {
                RubricBlock(text: preRubric)
            }
            
            if let title = section.title {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            if let rubric = section.rubric {
                RubricBlock(text: rubric)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(section.paragraphs, id: \.self) { paragraph in
                    richTextParagraph(paragraph)
                }
            }
            
            if let postRubric = section.postRubric {
                RubricBlock(text: postRubric)
            }
            
            // MARK: 插入本日祝文（無對經、無啟應）
            if section.id == "lordPrayer",
               let collect = collectOfTheDay,
               let postRubric = section.postRubric,
               postRubric.contains("本日祝文") {
                VStack(alignment: .leading, spacing: 10) {
                    Text(collect.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.red)
                        .padding(.top, 8)
                    
                    BodyText(collect.text)
                }
            }
        }
    }

    // MARK: - 富文本段落（支持 {{RED:文本}} 红色标记）
    private func richTextParagraph(_ text: String) -> some View {
        let startMarker = "{{RED:"
        let endMarker = "}}"
        
        var result = Text("")
        var remaining = text
        
        while let startRange = remaining.range(of: startMarker) {
            let prefix = String(remaining[..<startRange.lowerBound])
            if !prefix.isEmpty {
                result = result + Text(prefix)
            }
            
            let afterStart = String(remaining[startRange.upperBound...])
            if let endRange = afterStart.range(of: endMarker) {
                let redText = String(afterStart[..<endRange.lowerBound])
                result = result + Text(redText).foregroundColor(.red)
                remaining = String(afterStart[endRange.upperBound...])
            } else {
                result = result + Text(remaining)
                remaining = ""
                break
            }
        }
        
        if !remaining.isEmpty {
            result = result + Text(remaining)
        }
        
        return result
            .font(.system(size: 17))
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - 早禱頁面
struct HomePrayerMorningView: View {
    @State private var selectedDate: Date = Date()
    @ObservedObject private var languageStore = AppLanguageStore.shared
    
    private var liturgy: DailyLiturgy {
        LiturgyCoreService.shared.resolve(for: selectedDate)
    }
    
    /// 早禱本日祝文
    private var morningCollect: DailyOfficeFile.OfficePeriod.CollectJSON? {
        DailyOfficeLoader.shared.collect(for: selectedDate, liturgy: liturgy)
    }
    
    var body: some View {
        HomePrayerPartView(
            part: HomePrayerData.morningPrayer,
            collectOfTheDay: morningCollect
        )
    }
}

// MARK: - 晚禱頁面
struct HomePrayerEveningView: View {
    @State private var selectedDate: Date = Date()
    @ObservedObject private var languageStore = AppLanguageStore.shared
    
    private var liturgy: DailyLiturgy {
        LiturgyCoreService.shared.resolve(for: selectedDate, isEvening: true)
    }
    
    /// 晚禱本日祝文（優先 evening，回退 morning）
    private var eveningCollect: DailyOfficeFile.OfficePeriod.CollectJSON? {
        // 前夕晚禱的祝文屬於明天的節日，需用明天的日期加載文件
        let fileDate: Date
        if liturgy.isFirstVespers {
            fileDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        } else {
            fileDate = selectedDate
        }
        
        guard let file = DailyOfficeLoader.shared.loadOfficeFile(for: fileDate, liturgy: liturgy) else {
            return nil
        }
        
        // 若當日為前夕晚禱，優先使用 vigil 祝文
        if liturgy.isFirstVespers {
            return file.vigil?.collect ?? file.evening?.collect ?? file.morning?.collect
        }
        return file.evening?.collect ?? file.morning?.collect
    }
    
    var body: some View {
        HomePrayerPartView(
            part: HomePrayerData.eveningPrayer,
            collectOfTheDay: eveningCollect
        )
    }
}

// MARK: - 預覽
struct HomePrayerMorningView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomePrayerMorningView()
        }
    }
}

struct HomePrayerEveningView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomePrayerEveningView()
        }
    }
}
