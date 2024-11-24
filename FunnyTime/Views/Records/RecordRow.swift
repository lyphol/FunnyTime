import SwiftUI

struct RecordRow: View {
    let record: TimeRecord
    @State private var showingCheckInPicker = false
    @State private var showingCheckOutPicker = false
    @State private var tempCheckInTime: Date = Date()
    @State private var tempCheckOutTime: Date = Date()
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        
        // 获取周几
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = Locale(identifier: "zh_CN")
        weekdayFormatter.dateFormat = "EEE"
        let weekdayString = weekdayFormatter.string(from: record.date)
        
        // 获取日期
        formatter.dateFormat = "yyyy年M月d日"
        return "\(formatter.string(from: record.date)) \(weekdayString)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 日期
            Text(formattedDate)
                .font(.subheadline)
                .foregroundColor(ColorTheme.History.dateText)
            
            // 时间显示
            HStack {
                // 签到时间
                if let checkIn = record.checkInTime {
                    Button(action: {
                        tempCheckInTime = checkIn
                        showingCheckInPicker = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.forward.circle.fill")
                                .foregroundStyle(ColorTheme.History.normalStatus)
                                .font(.headline)
                            Text(checkIn, style: .time)
                                .font(.headline)
                                .monospacedDigit()
                                .foregroundColor(ColorTheme.History.timeText)
                        }
                        .padding(.top, 5)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                
                Spacer()
                
                // 签退时间
                if let checkOut = record.checkOutTime {
                    Button(action: {
                        tempCheckOutTime = checkOut
                        showingCheckOutPicker = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.backward.circle.fill")
                                .foregroundStyle(ColorTheme.Button.checkOut)
                                .font(.headline)
                            Text(checkOut, style: .time)
                                .font(.headline)
                                .monospacedDigit()
                                .foregroundColor(ColorTheme.History.timeText)
                        }
                        .padding(.top, 5)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
        .padding(.vertical, 6)
        .sheet(isPresented: $showingCheckInPicker) {
            TimePickerSheet(
                title: "修改签到时间",
                time: $tempCheckInTime,
                isPresented: $showingCheckInPicker
            ) {
                record.checkInTime = Calendar.current.date(
                    bySettingHour: Calendar.current.component(.hour, from: tempCheckInTime),
                    minute: Calendar.current.component(.minute, from: tempCheckInTime),
                    second: 0,
                    of: record.date
                )
            }
        }
        .sheet(isPresented: $showingCheckOutPicker) {
            TimePickerSheet(
                title: "修改签退时间",
                time: $tempCheckOutTime,
                isPresented: $showingCheckOutPicker
            ) {
                record.checkOutTime = Calendar.current.date(
                    bySettingHour: Calendar.current.component(.hour, from: tempCheckOutTime),
                    minute: Calendar.current.component(.minute, from: tempCheckOutTime),
                    second: 0,
                    of: record.date
                )
            }
        }
    }
}

//#Preview {
//    RecordRow(
//        record: TimeRecord(
//            date: Date(),
//            checkInTime: Date(),
//            checkOutTime: Date()
//        )
//    )
//    .padding()
//} 
