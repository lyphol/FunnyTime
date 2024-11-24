import Foundation
import SwiftData

@Model
final class TimeRecord {
    var date: Date
    var checkInTime: Date?
    var checkOutTime: Date?
    
    init(date: Date, checkInTime: Date? = nil, checkOutTime: Date? = nil) {
        self.date = date
        self.checkInTime = checkInTime
        self.checkOutTime = checkOutTime
    }
    
    var workingHours: Double {
        guard let checkIn = checkInTime, let checkOut = checkOutTime else { return 0 }
        return checkOut.timeIntervalSince(checkIn) / 3600
    }
}

