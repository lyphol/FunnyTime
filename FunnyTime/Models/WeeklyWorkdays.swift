import SwiftData

@Model
final class WeeklyWorkdays {
    var year: Int
    var week: Int
    var workdays: [Int]
    
    init(year: Int, week: Int, workdays: [Int] = [1, 2, 3, 4, 5]) {
        self.year = year
        self.week = week
        self.workdays = workdays
    }
} 