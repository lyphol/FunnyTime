import SwiftUI

struct StatisticsSummary: View {
    let periodStats: (average: Double, total: Double)
    
    var body: some View {
        HStack(spacing: 24) {
            StatCard(
                title: "平均工时",
                value: String(format: "%.1f", periodStats.average),
                unit: "小时/天",
                icon: "clock.fill",
                color: ColorTheme.Statistics.barColor
            )
            
            StatCard(
                title: "总工时",
                value: String(format: "%.1f", periodStats.total),
                unit: "小时",
                icon: "sum",
                color: ColorTheme.Statistics.weekendBarColor
            )
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(ColorTheme.Statistics.cardSubtitle)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(.title, design: .rounded, weight: .medium))
                    .foregroundColor(ColorTheme.Statistics.cardValue)
                Text(unit)
                    .font(.caption)
                    .foregroundColor(ColorTheme.Statistics.cardSubtitle)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
} 