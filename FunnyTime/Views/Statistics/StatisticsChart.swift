import SwiftUI

struct StatisticsChart: View {
    let selectedType: StatisticsViewType
    let dailyStats: [(date: Date, hours: Double)]
    let weeklyWorkdays: [WeeklyWorkdays]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("每日工时")
                .font(.subheadline)
                .foregroundColor(ColorTheme.Statistics.chartAxisLabel)
            
            let maxHours = dailyStats.map { $0.hours }.max() ?? 8.0
            
            if selectedType == .week {
                // 周视图
                HStack(alignment: .bottom, spacing: 8) {
                    // 重新排序日期，将周日放到最后
                    let sortedStats = dailyStats.sorted { stat1, stat2 in
                        let calendar = Calendar.current
                        let weekday1 = calendar.component(.weekday, from: stat1.date)
                        let weekday2 = calendar.component(.weekday, from: stat2.date)
                        // 将周日(1)转换为7，其他期-1
                        let adjusted1 = weekday1 == 1 ? 7 : weekday1 - 1
                        let adjusted2 = weekday2 == 1 ? 7 : weekday2 - 1
                        return adjusted1 < adjusted2
                    }
                    
                    ForEach(sortedStats, id: \.date) { stat in
                        DailyStatBar(stat: stat, maxHours: maxHours)
                    }
                }
                .frame(height: 150)
            } else {
                // 月视图使用网格布局
                let calendar = Calendar.current
                let weekday = calendar.component(.weekday, from: dailyStats.first?.date ?? Date())
                let offset = weekday == 1 ? 6 : weekday - 2 // 调整起始偏移
                
                VStack(spacing: 12) {
                    // 星期题行
                    HStack(spacing: 0) {
                        ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { day in
                            Text(day)
                                .font(.caption2)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(ColorTheme.Statistics.chartAxisLabel)
                        }
                    }
                    
                    // 日历网格
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                        // 添加空白占位
                        ForEach(0..<offset, id: \.self) { _ in
                            Color.clear
                                .aspectRatio(1, contentMode: .fit)
                                .frame(height: 45)
                        }
                        
                        // 显示每天的数据
                        ForEach(dailyStats, id: \.date) { stat in
                            DailyStatCell(stat: stat, maxHours: maxHours)
                        }
                        
                        // 添加月末空白占位
                        let totalDays = dailyStats.count + offset
                        let remainingCells = (7 - (totalDays % 7)) % 7
                        if remainingCells > 0 {
                            ForEach(0..<remainingCells, id: \.self) { _ in
                                Color.clear
                                    .aspectRatio(1, contentMode: .fit)
                                    .frame(height: 45)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(ColorTheme.background)
        .cornerRadius(12)
        .shadow(color: ColorTheme.cardShadow.opacity(0.1), radius: 5, x: 0, y: 2)
    }
} 
