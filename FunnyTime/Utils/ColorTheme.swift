import SwiftUI

struct ColorTheme {
    // 基础颜色
    static let background = Color(.secondarySystemGroupedBackground)
    static let label = Color(.label)
    static let secondaryLabel = Color(.secondaryLabel)
    
    // 时间显示相关颜色
    static let timeDisplayText = Color(.label)
    
    // 签到卡片相关颜色
    static let cardBorder = Color(.systemGray4)
    static let cardShadow = Color(.systemGray3)
    
    // 按钮颜色
    struct Button {
        static let checkIn = Color.purple
        static let checkOut = Color.blue
        static let completed = Color.green
        static let disabled = Color(.systemGray3)
    }
    
    // 统计模块颜色
    struct Statistics {
        static let chartBackground = Color(.systemBackground)
        static let chartAxisLabel = Color(.secondaryLabel)
        static let barColor = Color.accentColor
        
        // 统计卡片颜色
        static let cardBackground = Color(.systemGray6)
        static let cardTitle = Color(.label)
        static let cardValue = Color(.label)
        static let cardSubtitle = Color(.secondaryLabel)
        
        // 图表颜色
        static let weekendBarColor = Color(.systemGray3)
    }
    
    // 历史记录模块颜色
    struct History {
        // 卡片样式
        static let cardTitle = Color(.label)
        
        // 列表样式
        static let cellBackground = Color(.secondarySystemGroupedBackground)
        static let separatorColor = Color(.opaqueSeparator)
        
        // 记录项样式
        static let timeText = Color(.label)
        static let dateText = Color(.secondaryLabel)
        
        // 状态标签颜色
        static let normalStatus = Color(.systemGreen)
        
        // 空状态提示
        static let emptyStateText = Color(.tertiaryLabel)
    }
} 
