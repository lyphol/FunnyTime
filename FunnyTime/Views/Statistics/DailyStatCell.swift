import SwiftUI
import SwiftData

struct DailyStatCell: View {
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
        VStack(spacing: 2) {
            // 日期
            Text(formatDayNumber(stat.date))
                .font(.caption2)
                .foregroundStyle(stat.hours > 0 ? ColorTheme.Statistics.cardTitle : (isWorkday ? ColorTheme.Statistics.cardTitle : ColorTheme.Statistics.cardSubtitle))
            
            // 工时显示
            Group {
                if stat.hours > 0 {
                    Text(String(format: "%.1f", stat.hours))
                        .font(.system(size: 9))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(getBarColor(hours: stat.hours))
                        )
                } else {
                    // 非工作日或未打卡显示
                    Text(isWorkday ? "-" : "休")
                        .font(.caption)
                        .foregroundStyle(ColorTheme.Statistics.cardSubtitle)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 45)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isWorkday ? ColorTheme.Statistics.cardBackground : ColorTheme.Statistics.chartBackground)
                .strokeBorder(ColorTheme.cardBorder.opacity(0.2), lineWidth: 1)
        )
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
    }
    
    // MARK: - Private Methods
    private func handleTap() {
        if !isWorkday {
            showingAlert = true
            return
        }
        
        if let record = record {
            if record.checkInTime == nil {
                tempCheckInTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: stat.date) ?? stat.date
                shouldShowCheckOutAfterCheckIn = true
                showingCheckInPicker = true
            } else if record.checkOutTime == nil {
                tempCheckOutTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: stat.date) ?? stat.date
                showingCheckOutPicker = true
            } else {
                showModifyTimeActionSheet()
            }
        } else {
            tempCheckInTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: stat.date) ?? stat.date
            shouldShowCheckOutAfterCheckIn = true
            showingCheckInPicker = true
        }
    }
    
    private func showModifyTimeActionSheet() {
        tempCheckInTime = record?.checkInTime ?? stat.date
        tempCheckOutTime = record?.checkOutTime ?? stat.date
        showingActionSheet = true
    }
    
    private func handleCheckInSave() {
        if let record = record {
            record.checkInTime = Calendar.current.date(
                bySettingHour: Calendar.current.component(.hour, from: tempCheckInTime),
                minute: Calendar.current.component(.minute, from: tempCheckInTime),
                second: 0,
                of: stat.date
            )
        } else {
            let newRecord = TimeRecord(
                date: stat.date,
                checkInTime: Calendar.current.date(
                    bySettingHour: Calendar.current.component(.hour, from: tempCheckInTime),
                    minute: Calendar.current.component(.minute, from: tempCheckInTime),
                    second: 0,
                    of: stat.date
                )
            )
            modelContext.insert(newRecord)
        }
        
        if shouldShowCheckOutAfterCheckIn {
            shouldShowCheckOutAfterCheckIn = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                tempCheckOutTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: stat.date) ?? stat.date
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingCheckOutPicker = true
                }
            }
        }
    }
    
    private func handleCheckOutSave() {
        if let record = record {
            record.checkOutTime = Calendar.current.date(
                bySettingHour: Calendar.current.component(.hour, from: tempCheckOutTime),
                minute: Calendar.current.component(.minute, from: tempCheckOutTime),
                second: 0,
                of: stat.date
            )
        }
    }
    
    private func formatDayNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private func getBarColor(hours: Double) -> Color {
        if !isWorkday {
            return .orange
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
} 