import Foundation

extension Date {
    func formattedDate() -> String {
        DateFormatters.shared.fullDateFormatter.string(from: self)
    }
    
    func formattedWeekday() -> String {
        DateFormatters.shared.weekdayFormatter.string(from: self)
    }
    
    func formattedMonth() -> String {
        DateFormatters.shared.monthFormatter.string(from: self)
    }
    
    func formattedWeekNumber() -> String {
        DateFormatters.shared.weekNumberFormatter.string(from: self)
    }
    
    func startOfWeek() -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: self)
        let mondayOffset = weekday == 1 ? -6 : -(weekday - 2)
        return calendar.date(byAdding: .day, value: mondayOffset, to: self) ?? self
    }
    
    func endOfWeek() -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 7, to: startOfWeek()) ?? self
    }
    
    func startOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    func endOfMonth() -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .month, value: 1, to: startOfMonth()) ?? self
    }
} 