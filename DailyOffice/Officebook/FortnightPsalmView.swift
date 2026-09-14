import SwiftUI

struct FortnightPsalmView: View {
    @ObservedObject private var languageStore = AppLanguageStore.shared
    @State private var selectedCycle = 0
    @State private var selectedWeek = 0
    private var isSimp: Bool { languageStore.isSimplified }
    private var cycle: FortnightPsalmData.Cycle { FortnightPsalmData.cycles[selectedCycle] }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                BodyText(FortnightPsalmData.introduction.adaptChinese(isSimplified: isSimp))

                Picker("循環模式".adaptChinese(isSimplified: isSimp), selection: $selectedCycle) {
                    ForEach(FortnightPsalmData.cycles.indices, id: \.self) { index in
                        Text(FortnightPsalmData.cycles[index].title.adaptChinese(isSimplified: isSimp)).tag(index)
                    }
                }
                .pickerStyle(.segmented)

                Picker("週次".adaptChinese(isSimplified: isSimp), selection: $selectedWeek) {
                    Text("第一週".adaptChinese(isSimplified: isSimp)).tag(0)
                    Text("第二週".adaptChinese(isSimplified: isSimp)).tag(1)
                }
                .pickerStyle(.segmented)

                ForEach(Array(cycle.weeks[selectedWeek].enumerated()), id: \.offset) { _, day in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(day.day.adaptChinese(isSimplified: isSimp))
                            .font(.headline)
                            .foregroundStyle(Color(red: 181/255, green: 8/255, blue: 56/255))
                        ForEach(Array(day.offices.enumerated()), id: \.offset) { index, office in
                            if index > 0 { Divider() }
                            HStack(alignment: .top, spacing: 12) {
                                Text(office.hour.adaptChinese(isSimplified: isSimp))
                                    .font(.subheadline.bold())
                                    .frame(width: 60, alignment: .leading)
                                Text(office.psalms.adaptChinese(isSimplified: isSimp))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
                }

                VStack(alignment: .leading, spacing: 16) {
                    SectionTitle(text: "編排說明".adaptChinese(isSimplified: isSimp))
                    ForEach(Array(cycle.notes.enumerated()), id: \.offset) { _, paragraph in
                        BodyText(paragraph.adaptChinese(isSimplified: isSimp))
                    }
                }
            }
            .frame(maxWidth: 760, alignment: .leading)
            .padding(20)
            .frame(maxWidth: .infinity)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("詩篇兩週循環模式".adaptChinese(isSimplified: isSimp))
        .navigationBarTitleDisplayMode(.inline)
    }
}
