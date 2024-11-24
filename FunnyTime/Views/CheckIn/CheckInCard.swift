import SwiftUI

struct CheckInCard: View {
    let todayRecord: TimeRecord?
    let onCheckAction: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 16) {
            TimeDisplayView()
                .padding(.top, 8)
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        isPressed = false
                    }
                    onCheckAction()
                }
            }) {
                ZStack {
                    // 主按钮
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    getButtonColor(),
                                    getButtonColor().opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .overlay(
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            getButtonColor().opacity(0.3),
                                            getButtonColor().opacity(0.1),
                                            .clear
                                        ]),
                                        center: .center,
                                        startRadius: 40,
                                        endRadius: 60
                                    )
                                )
                                .scaleEffect(1.2)
                        )
                        .shadow(color: getButtonColor().opacity(0.3), radius: 8, x: 0, y: 4)
                        .scaleEffect(isPressed ? 0.95 : 1.0)
                    
                    // 按钮内容
                    VStack(spacing: 8) {
                        Image(systemName: getButtonImageName())
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                        
                        Text(getButtonText())
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.vertical, 8)
            
            // 时间显示部分
            VStack(spacing: 12) {
                HStack {
                    Text("签到时间")
                        .foregroundColor(ColorTheme.secondaryLabel)
                    Spacer()
                    if let checkIn = todayRecord?.checkInTime {
                        Text(checkIn, style: .time)
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.medium)
                            .monospacedDigit()
                            .foregroundColor(ColorTheme.label)
                    } else {
                        Text("--:--")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(ColorTheme.secondaryLabel)
                    }
                }
                
                HStack {
                    Text("签退时间")
                        .foregroundColor(ColorTheme.secondaryLabel)
                    Spacer()
                    if let checkOut = todayRecord?.checkOutTime {
                        Text(checkOut, style: .time)
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.medium)
                            .monospacedDigit()
                            .foregroundColor(ColorTheme.label)
                    } else {
                        Text("--:--")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(ColorTheme.secondaryLabel)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(ColorTheme.background)
                .shadow(color: ColorTheme.cardShadow.opacity(0.1), radius: 10)
        )
    }
    
    private func getButtonImageName() -> String {
        if todayRecord?.checkOutTime != nil {
            return "checkmark.circle"
        } else if todayRecord?.checkInTime != nil {
            return "arrow.left.circle"
        } else {
            return "arrow.right.circle"
        }
    }
    
    private func getButtonText() -> String {
        if todayRecord?.checkOutTime != nil {
            return "今日已完成"
        } else if todayRecord?.checkInTime != nil {
            return "签退"
        } else {
            return "签到"
        }
    }
    
    private func getButtonColor() -> Color {
        if todayRecord?.checkOutTime != nil {
            return ColorTheme.Button.completed
        } else if todayRecord?.checkInTime != nil {
            return ColorTheme.Button.checkOut
        } else {
            return ColorTheme.Button.checkIn
        }
    }
} 
