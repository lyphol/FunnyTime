import Foundation

struct ExportData: Codable {
    var records: [RecordData]
    var workdays: [WorkdayData]
    
    struct RecordData: Codable {
        var date: Date
        var checkInTime: Date?
        var checkOutTime: Date?
    }
    
    struct WorkdayData: Codable {
        var year: Int
        var week: Int
        var workdays: [Int]
    }
} 