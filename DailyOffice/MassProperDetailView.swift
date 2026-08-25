import SwiftUI

struct MassProperDetailView: View {
    let proper: MassProper
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // 1. 頂部標題區
                VStack(spacing: 8) {
                    Text(proper.dateDisplay).rubricCenteredStyle()
                    
                    Text(proper.title)
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                    
                    Text(proper.rank).rubricCenteredStyle()
                    
                    // 通用彌撒說明
                    if let commonMass = proper.commonMass {
                        Text(commonMass).rubricCenteredStyle()
                    }
                    
                    // 🌟 新增：將獨立出來的禮儀指示 (如：此彌撒經文同...) 顯示出來
                    if let rubricNote = proper.rubricNote {
                        VStack(alignment: .leading, spacing: 10) { // 控制紅字段落間的距離
                            let paragraphs = rubricNote.components(separatedBy: "\n")
                                .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                            
                            ForEach(paragraphs, id: \.self) { para in
                                Text("\u{3000}\u{3000}\(para)") // 每一段開頭強制空兩格
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.rubricRed)
                                    .lineSpacing(6)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.top, 10)
                
                // 2. 簡介區
                if let intro = proper.intro {
                    Text(intro.indented)
                        .font(.system(size: 18))
                        .lineSpacing(8)
                }
                
                Divider().padding(.vertical, 8)
                
                // 3. 聖道禮儀
                if let introit = proper.introit { renderLiturgicalSection(textData: introit) }
                // 🌟 支援單一祝文 (舊資料) 或 多重祝文 (新資料)
                if let collect = proper.collect { renderLiturgicalSection(textData: collect) }
                if let collects = proper.collects {
                    ForEach(collects.indices, id: \.self) { index in
                        renderLiturgicalSection(textData: collects[index])
                    }
                }
                if let epistle = proper.epistle { renderLiturgicalSection(textData: epistle) }
                if let alleluia = proper.alleluia { renderLiturgicalSection(textData: alleluia) }
                
                // 🌟 新增：加入連唱詠 (Tract)
                if let tract = proper.tract { renderLiturgicalSection(textData: tract) }
                
                if let gospel = proper.gospel { renderLiturgicalSection(textData: gospel) }
                
                // 🌟 針對 Creed：傳入 isEntirelyRubric = true，強制整段變紅
                if let creed = proper.creed { renderLiturgicalSection(textData: creed, isEntirelyRubric: true) }
                
                // 4. 聖餐禮儀 (奉獻頌前不加分割線，自然銜接)
                if let offertory = proper.offertory { renderLiturgicalSection(textData: offertory) }
                if let secret = proper.secret { renderLiturgicalSection(textData: secret) }
                if let secrets = proper.secrets {
                    ForEach(secrets.indices, id: \.self) { index in
                        renderLiturgicalSection(textData: secrets[index])
                    }
                }
                if let communion = proper.communion { renderLiturgicalSection(textData: communion) }
                if let postcommunion = proper.postcommunion { renderLiturgicalSection(textData: postcommunion) }
                    if let postcommunions = proper.postcommunions {
                        ForEach(postcommunions.indices, id: \.self) { index in
                            renderLiturgicalSection(textData: postcommunions[index])
                        }
                    }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .navigationTitle(proper.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 通用禮儀段落渲染器
    @ViewBuilder
    // 🌟 新增 isEntirelyRubric 參數，預設為 false
    private func renderLiturgicalSection(textData: LiturgicalText, isEntirelyRubric: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) { // 段落內間距保持緊湊
            
            // A. 四大紅色置中標題 (入祭頌、祝文、祕禱祝文、領聖餐後祝文)
            if let sectionTitle = textData.sectionTitle {
                Text(sectionTitle)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(.rubricRed)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 12)
            }
            
            // B. 指示語 (如：書信載在... / ☩福音載在...) - 黑色置中，☩紅
            if let instruction = textData.instruction {
                Text(parseInstruction(instruction))
                    .font(.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
            }

            // C. 經卷名出處 (如：便西拉智訓 15 / 哥林多後書...) - 紅色置中
            if let reference = textData.reference {
                Text(reference).rubricCenteredStyle()
                    .padding(.bottom, 2)
            }
            
            // 🌟 D. 正文內容 (強制首行縮排)
            if isEntirelyRubric {
                // 若指定為全紅 (如信經指示)，直接套用紅色並縮排
                Text(textData.content.indented)
                    .font(.system(size: 18))
                    .foregroundColor(.rubricRed)
                    .lineSpacing(6)
            } else {
                // 走正規表達式解析，僅特定字詞標紅
                Text(parseInlineRubrics(textData.content))
                    .font(.system(size: 18))
                    .lineSpacing(6)
            }
        }
        .padding(.bottom, 4)
    }
    
    // 處理指示語：黑色置中，僅將 ☩ 標紅
    private func parseInstruction(_ text: String) -> AttributedString {
        var attributed = AttributedString(text)
        attributed.foregroundColor = .primary
        if let range = attributed.range(of: "☩") {
            attributed[range].foregroundColor = UIColor(.rubricRed)
        }
        return attributed
    }
    
    // 處理內文：啓應、引子、信經指示標紅，所有段落空兩格
    private func parseInlineRubrics(_ text: String) -> AttributedString {
        let paragraphs = text.components(separatedBy: "\n\n")
        let processedText = paragraphs.map { $0.indented }.joined(separator: "\n\n")
        
        var attributed = AttributedString(processedText)
        let nsString = processedText as NSString
        
        // --- 第一部分：處理一般的紅色指示字 (整段變紅) ---
        let patterns = [
                    // 🌟 修正 1：嚴格限制「啓/應」的匹配範圍，只匹配「啓：」或「啓，出處：」
                    "((啓|應)(，[^：。\\n]+)?：)",
                    
                    // 2. 單獨的詩篇出處
                    "(詩\\s*\\d+[：])",
                    
                    // 🌟 修正 2：將「連唱詠」加入到各類頌歌的標題規則中
                    "((進階詠|連唱詠|奉獻頌|領主頌|誦唸信經|誦念「榮歸主頌」)[^：\\n。]*[：。]?)",
                    
                    // 4. 復活期內/外說明
                    "(復活期[內外][^：\\n]*[：。])",
                    
                    // 5. 七旬主日說明
                    "(七旬主日後[^：\\n]*[：。])",
                    
                    // 6. 序文指示
                    "(誦唸.*?序文。)",
                    "(☩)",
                    "(（)",
                    "(）)",
                    "(升天序文、升天感恩經；誦念至聖靈降臨望日（不含）為止。)"
                ]
        
        let pattern = patterns.joined(separator: "|")
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: processedText, options: [], range: NSRange(location: 0, length: nsString.length))
            for match in matches.reversed() {
                if let range = Range(match.range, in: attributed) {
                    attributed[range].foregroundColor = UIColor(.rubricRed)
                    attributed[range].font = .system(size: 17, weight: .bold)
                }
            }
        }
        
        // --- 第二部分：處理括號內的哈利路亞 (僅括號變紅，哈利路亞為預設黑色) ---
        let bracketPattern = "([（\\(])(哈利路亞。)([）\\)])"
        if let bracketRegex = try? NSRegularExpression(pattern: bracketPattern, options: []) {
            let matches = bracketRegex.matches(in: processedText, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches.reversed() {
                if let openRange = Range(match.range(at: 1), in: attributed) {
                    attributed[openRange].foregroundColor = UIColor(.rubricRed)
                    attributed[openRange].font = .system(size: 17, weight: .bold)
                }
                
                if let closeRange = Range(match.range(at: 3), in: attributed) {
                    attributed[closeRange].foregroundColor = UIColor(.rubricRed)
                    attributed[closeRange].font = .system(size: 17, weight: .bold)
                }
            }
        }
        
        return attributed
    }
}
