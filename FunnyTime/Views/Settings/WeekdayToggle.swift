import SwiftUI

struct WeekdayToggle: View {
    let day: Int
    let isWorkday: Bool
    let onToggle: (Bool) -> Void
    
    private let weekdays = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
    
    var body: some View {
        Toggle(weekdays[day - 1], isOn: Binding(
            get: { isWorkday },
            set: { onToggle($0) }
        ))
    }
} 