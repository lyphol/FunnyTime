import SwiftUI
import SwiftData

struct WeeklyWorkdaysSection: View {
    let selectedDate: Date
    let weeklyWorkdays: [WeeklyWorkdays]
    let modelContext: ModelContext
    
    private var yearAndWeek: (year: Int, week: Int) {
        let calendar = Calendar.current
        let year = calendar.component(.yearForWeekOfYear, from: selectedDate)
        let week = calendar.component(.weekOfYear, from: selectedDate)
        return (year, week)
    }
    
    private var currentWeekWorkdays: [Int] {
        if let setting = weeklyWorkdays.first(where: { $0.year == yearAndWeek.year && $0.week == yearAndWeek.week }) {
            return setting.workdays.sorted()
        }
        return [1, 2, 3, 4, 5] // 默认工作日
    }
    
    var body: some View {
        Section(header: Text("\(yearAndWeek.year)年第\(yearAndWeek.week)周")) {
            ForEach(1...7, id: \.self) { day in
                WeekdayToggle(
                    day: day,
                    isWorkday: currentWeekWorkdays.contains(day),
                    onToggle: { isOn in
                        updateWorkdays(day: day, isWorkday: isOn)
                    }
                )
            }
        }
    }
    
    private func updateWorkdays(day: Int, isWorkday: Bool) {
        if let setting = weeklyWorkdays.first(where: { $0.year == yearAndWeek.year && $0.week == yearAndWeek.week }) {
            var updatedWorkdays = setting.workdays
            if isWorkday {
                if !updatedWorkdays.contains(day) {
                    updatedWorkdays.append(day)
                }
            } else {
                updatedWorkdays.removeAll { $0 == day }
            }
            setting.workdays = updatedWorkdays.sorted()
        } else {
            var workdays = [1, 2, 3, 4, 5] // 默认工作日
            if isWorkday {
                if !workdays.contains(day) {
                    workdays.append(day)
                }
            } else {
                workdays.removeAll { $0 == day }
            }
            let newSetting = WeeklyWorkdays(year: yearAndWeek.year, week: yearAndWeek.week, workdays: workdays.sorted())
            modelContext.insert(newSetting)
        }
    }
} 