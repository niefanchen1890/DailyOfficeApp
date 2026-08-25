import SwiftUI

struct OfficeHymnSectionView: View {
    let hymn: OfficeHymnData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text(hymn.title)
                    .font(.system(size: 20, weight: .bold))
                
                if !hymn.latinTitle.isEmpty {
                    Text(hymn.latinTitle)
                        .font(.system(size: 15))
                        .italic()
                        .foregroundColor(.secondary)
                }
            }
            
            if let note = hymn.seasonNote, !note.isEmpty {
                Text(note)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
            
            Divider().padding(.vertical, 14)
            
            VStack(alignment: .leading, spacing: 18) {
                ForEach(Array(hymn.verses.enumerated()), id: \.offset) { _, verse in
                    Text(verse)
                        .font(.system(size: 17))
                        .lineSpacing(8)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            if let versicle = hymn.versicle {
                Divider().padding(.vertical, 14)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("啟應")
                        .font(.system(size: 17, weight: .semibold))
                    
                    HStack(alignment: .top, spacing: 4) {
                        Text("司：").font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary).frame(width: 32, alignment: .leading)
                        Text(versicle.leader)
                            .font(.system(size: 16))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    HStack(alignment: .top, spacing: 4) {
                        Text("眾：").font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary).frame(width: 32, alignment: .leading)
                        Text(versicle.people)
                            .font(.system(size: 16))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}
