import SwiftUI
import SwiftData
import Foundation

struct StatisticsView: View {
    let records: [TimeRecord]
    let weeklyWorkdays: [WeeklyWorkdays]
    @Binding var selectedType: StatisticsViewType
    @Binding var selectedDate: Date
    
    private var dateRange: (start: Date, end: Date) {
        var calendar = Calendar(identifier: .iso8601)
        calendar.locale = Locale(identifier: "zh_CN")
        calendar.firstWeekday = 2
        
        switch selectedType {
        case .week:
            let weekOfYear = calendar.component(.weekOfYear, from: selectedDate)
            let year = calendar.component(.year, from: selectedDate)
            
            var components = DateComponents()
            components.year = year
            components.weekOfYear = weekOfYear
            components.weekday = 2
            
            let weekStart = calendar.date(from: components)!
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
            
            return (weekStart, weekEnd)
        case .month:
            let components = calendar.dateComponents([.year, .month], from: selectedDate)
            let monthStart = calendar.date(from: components)!
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!
            return (monthStart, monthEnd)
        }
    }
    
    private var periodStats: (average: Double, total: Double) {
        let dailyStats = getDailyStats()
        let workingDays = dailyStats.filter { $0.hours > 0 }
        let totalHours = workingDays.reduce(0) { $0 + $1.hours }
        let workdayCount = workingDays.count
        return (workdayCount > 0 ? totalHours / Double(workdayCount) : 0, totalHours)
    }
    
    private func getDailyStats() -> [(date: Date, hours: Double)] {
        var calendar = Calendar(identifier: .iso8601)
        calendar.locale = Locale(identifier: "zh_CN")
        calendar.firstWeekday = 2
        
        var result: [(Date, Double)] = []
        var currentDate = dateRange.start
        
        while currentDate < dateRange.end {
            let weekOfYear = calendar.component(.weekOfYear, from: currentDate)
            let year = calendar.component(.year, from: currentDate)
            let weekday = calendar.component(.weekday, from: currentDate)
            let adjustedWeekday = weekday == 1 ? 7 : weekday - 1
            
            let isWorkday = weeklyWorkdays.first(where: { 
                $0.year == year && $0.week == weekOfYear 
            })?.workdays.contains(adjustedWeekday) ?? (1...5).contains(adjustedWeekday)
            
            let dayRecords = records.filter { record in
                calendar.isDate(record.date, inSameDayAs: currentDate)
            }
            
            let hours = dayRecords.reduce(0.0) { total, record in
                if isWorkday && record.checkInTime != nil && record.checkOutTime != nil {
                    return total + record.workingHours
                } else {
                    return total
                }
            }
            
            result.append((currentDate, hours))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return result
    }
    
    var periodTitle: String {
        var calendar = Calendar(identifier: .iso8601)
        calendar.locale = Locale(identifier: "zh_CN")
        calendar.firstWeekday = 2
        
        switch selectedType {
        case .week:
            let weekOfYear = calendar.component(.weekOfYear, from: selectedDate)
            let year = calendar.component(.year, from: selectedDate)
            return "\(year)年第\(weekOfYear)周"
        case .month:
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.dateFormat = "yyyy年M月"
            return formatter.string(from: selectedDate)
        }
    }
    
    private var earliestSelectableDate: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: selectedType == .week ? .weekOfYear : .month, 
                           value: -50, 
                           to: Date()) ?? Date()
    }
    
    var canGoBack: Bool {
        switch selectedType {
        case .week:
            let newDate = Calendar.current.date(byAdding: .day, value: -7, to: selectedDate)!
            return newDate >= earliestSelectableDate
        case .month:
            let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)!
            return newDate >= earliestSelectableDate
        }
    }
    
    var canGoForward: Bool {
        let calendar = Calendar.current
        let newDate: Date
        switch selectedType {
        case .week:
            newDate = calendar.date(byAdding: .day, value: 7, to: selectedDate)!
        case .month:
            newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
        }
        return newDate <= Date()
    }
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Picker("统计类型", selection: $selectedType) {
                    Text("周统计").tag(StatisticsViewType.week)
                    Text("月统计").tag(StatisticsViewType.month)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 200)
                
                HStack {
                    Button(action: {
                        withAnimation {
                            if selectedType == .week {
                                selectedDate = Calendar.current.date(byAdding: .day, value: -7, to: selectedDate)!
                            } else {
                                selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)!
                            }
                        }
                    }) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title2)
                            .foregroundColor(canGoBack ? ColorTheme.Statistics.cardTitle : ColorTheme.Button.disabled)
                    }
                    .disabled(!canGoBack)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            selectedDate = Date()
                        }
                    }) {
                        Text(periodTitle)
                            .font(.headline)
                            .frame(minWidth: 150)
                            .foregroundColor(selectedDate == Date() ? ColorTheme.secondaryLabel : ColorTheme.Statistics.cardTitle)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            if selectedType == .week {
                                selectedDate = Calendar.current.date(byAdding: .day, value: 7, to: selectedDate)!
                            } else {
                                selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate)!
                            }
                        }
                    }) {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.title2)
                            .foregroundColor(canGoForward ? ColorTheme.Statistics.cardTitle : ColorTheme.Button.disabled)
                    }
                    .disabled(!canGoForward)
                }
            }
            
            StatisticsSummary(periodStats: periodStats)
            
            StatisticsChart(
                selectedType: selectedType,
                dailyStats: getDailyStats(),
                weeklyWorkdays: weeklyWorkdays
            )
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(ColorTheme.background)
                .shadow(color: ColorTheme.cardShadow.opacity(0.1), radius: 10)
        )
        .onChange(of: selectedType) { _, _ in
            if selectedDate > Date() {
                selectedDate = Date()
            } else if selectedDate < earliestSelectableDate {
                selectedDate = earliestSelectableDate
            }
        }
    }
} 
