import SwiftUI
import SwiftData

struct DailyStatBar: View {
    let stat: (date: Date, hours: Double)
    let maxHours: Double
    @Query private var weeklyWorkdays: [WeeklyWorkdays]
    @State private var showingCheckInPicker = false
    @State private var showingCheckOutPicker = false
    @State private var showingAlert = false
    @State private var tempCheckInTime: Date = Date()
    @State private var tempCheckOutTime: Date = Date()
    @Environment(\.modelContext) private var modelContext
    @State private var shouldShowCheckOutAfterCheckIn = false
    @State private var showingActionSheet = false
    @State private var showingTimeError = false
    
    private var isWorkday: Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: stat.date)
        let adjustedWeekday = weekday == 1 ? 7 : weekday - 1
        let year = calendar.component(.yearForWeekOfYear, from: stat.date)
        let week = calendar.component(.weekOfYear, from: stat.date)
        
        return weeklyWorkdays.first(where: { $0.year == year && $0.week == week })?.workdays.contains(adjustedWeekday) ?? (1...5).contains(adjustedWeekday)
    }
    
    private var record: TimeRecord? {
        let calendar = Calendar.current
        do {
            let descriptor = FetchDescriptor<TimeRecord>()
            let records = try modelContext.fetch(descriptor)
            return records.first {
                calendar.isDate($0.date, inSameDayAs: stat.date)
            }
        } catch {
            print("Error fetching record: \(error)")
            return nil
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 4)
                    .fill(getBarColor(hours: stat.hours))
                    .frame(width: 24, height: getBarHeight(hours: stat.hours, maxHours: maxHours))
                    .position(x: geometry.size.width / 2, y: geometry.size.height - getBarHeight(hours: stat.hours, maxHours: maxHours) / 2)
            }
            .frame(height: 120)
            
            if stat.hours > 0 {
                Text(String(format: "%.1f", stat.hours))
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            } else {
                Text(isWorkday ? "-" : "休")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            
            Text(formatDayLabel(stat.date))
                .font(.caption2)
                .foregroundStyle(isWorkday ? .primary : .secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            handleTap()
        }
        .alert("休息日", isPresented: $showingAlert) {
            Button("确定", role: .cancel) {}
        } message: {
            Text("今天是休息日")
        }
        .sheet(isPresented: $showingCheckInPicker) {
            TimePickerSheet(
                title: "修改签到时间",
                time: $tempCheckInTime,
                isPresented: $showingCheckInPicker
            ) {
                handleCheckInSave()
            }
        }
        .sheet(isPresented: $showingCheckOutPicker) {
            TimePickerSheet(
                title: "修改签退时间",
                time: $tempCheckOutTime,
                isPresented: $showingCheckOutPicker
            ) {
                handleCheckOutSave()
            }
        }
        .confirmationDialog("修改时间", isPresented: $showingActionSheet) {
            Button("修改签到时间") {
                showingCheckInPicker = true
            }
            Button("修改签退时间") {
                showingCheckOutPicker = true
            }
            Button("取消", role: .cancel) {}
        }
        .alert("时间错误", isPresented: $showingTimeError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text("签退时间必须晚于签到时间")
        }
    }
    
    private func handleTap() {
        if !isWorkday {
            showingAlert = true
            return
        }
        
        if let record = record {
            if record.checkInTime == nil {
                tempCheckInTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: stat.date) ?? stat.date
                showingCheckInPicker = true
            } else if record.checkOutTime == nil {
                tempCheckOutTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: stat.date) ?? stat.date
                showingCheckOutPicker = true
            } else {
                showModifyTimeActionSheet()
            }
        } else {
            tempCheckInTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: stat.date) ?? stat.date
            tempCheckOutTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: stat.date) ?? stat.date
            showingCheckInPicker = true
        }
    }
    
    private func showModifyTimeActionSheet() {
        tempCheckInTime = record?.checkInTime ?? stat.date
        tempCheckOutTime = record?.checkOutTime ?? stat.date
        showingActionSheet = true
    }
    
    private func handleCheckInSave() {
        let calendar = Calendar.current
        let proposedCheckInTime = calendar.date(
            bySettingHour: calendar.component(.hour, from: tempCheckInTime),
            minute: calendar.component(.minute, from: tempCheckInTime),
            second: 0,
            of: stat.date
        )!
        
        if let record = record {
            record.checkInTime = proposedCheckInTime
        } else {
            let newRecord = TimeRecord(
                date: stat.date,
                checkInTime: proposedCheckInTime
            )
            modelContext.insert(newRecord)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                tempCheckOutTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: stat.date) ?? stat.date
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingCheckOutPicker = true
                }
            }
        }
    }
    
    private func handleCheckOutSave() {
        let calendar = Calendar.current
        let selectedHour = calendar.component(.hour, from: tempCheckOutTime)
        let selectedMinute = calendar.component(.minute, from: tempCheckOutTime)
        let proposedCheckOutTime = calendar.date(
            bySettingHour: selectedHour,
            minute: selectedMinute,
            second: 0,
            of: stat.date
        )!
        
        if let record = record {
            record.checkOutTime = proposedCheckOutTime
        } else {
            let newRecord = TimeRecord(
                date: stat.date,
                checkInTime: nil,
                checkOutTime: proposedCheckOutTime
            )
            modelContext.insert(newRecord)
        }
    }
    
    private func getBarHeight(hours: Double, maxHours: Double) -> CGFloat {
        if hours == 0 { return 4 }
        return max(4, min(120, CGFloat(hours / maxHours) * 120))
    }
    
    private func getBarColor(hours: Double) -> Color {
        if !isWorkday {
            return hours > 0 ? .orange : .gray.opacity(0.3)
        } else if hours == 0 {
            return .gray.opacity(0.3)
        } else if hours < 8 {
            return .blue
        } else if hours < 10 {
            return .purple
        } else {
            return .red
        }
    }
    
    private func formatDayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
} 