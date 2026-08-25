import Foundation

struct OfficeHymnData: Codable, Equatable {
    let title: String
    let latinTitle: String
    let seasonNote: String?
    let verses: [String]
    let versicle: OfficeVersicle?
    
    struct OfficeVersicle: Codable, Equatable {
        let leader: String
        let people: String
    }
}
