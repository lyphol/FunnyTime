import SwiftUI

struct TimeDisplayView: View {
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: currentTime)
        let hour = timeComponents.hour ?? 0
        let minute = timeComponents.minute ?? 0
        
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            // 小时
            Text("\(hour, specifier: "%02d")")
                .font(.system(size: 48, weight: .light, design: .rounded))
                .monospacedDigit()
                .foregroundColor(ColorTheme.timeDisplayText)
            
            // 冒号
            Text(":")
                .font(.system(size: 48, weight: .light, design: .rounded))
                .foregroundColor(ColorTheme.timeDisplayText.opacity(0.6))
                .overlay(
                    Circle()
                        .fill(ColorTheme.timeDisplayText.opacity(0.1))
                        .frame(width: 4, height: 4)
                        .offset(y: 12)
                )
            
            // 分钟
            Text("\(minute, specifier: "%02d")")
                .font(.system(size: 48, weight: .light, design: .rounded))
                .monospacedDigit()
                .foregroundColor(ColorTheme.timeDisplayText)
        }
        .frame(height: 60)
        .padding(.horizontal, 8)
        .onReceive(timer) { time in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                currentTime = time
            }
        }
        .shadow(color: ColorTheme.cardShadow.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

//#Preview {
//    TimeDisplayView()
//        .padding()
//        .background(Color(.systemGroupedBackground))
//} 
