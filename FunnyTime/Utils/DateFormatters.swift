import Foundation

public struct DateFormatters {
    public static let shared = DateFormatters()
    public let fullDateFormatter: DateFormatter
    public let weekdayFormatter: DateFormatter
    public let monthFormatter: DateFormatter
    public let weekNumberFormatter: DateFormatter
    
    private init() {
        fullDateFormatter = DateFormatter()
        fullDateFormatter.locale = Locale(identifier: "zh_CN")
        fullDateFormatter.dateFormat = "yyyy年M月d日"
        
        weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = Locale(identifier: "zh_CN")
        weekdayFormatter.dateFormat = "EEE"
        
        monthFormatter = DateFormatter()
        monthFormatter.locale = Locale(identifier: "zh_CN")
        monthFormatter.dateFormat = "yyyy年M月"
        
        weekNumberFormatter = DateFormatter()
        weekNumberFormatter.dateFormat = "yyyy年第w周"
    }
} 