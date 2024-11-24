import SwiftUI

struct AppIconPreview: View {
    let isDark: Bool
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: isDark ? IconColors.darkBackground : IconColors.lightBackground,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 主圆形（笑脸背景）
            Circle()
                .fill(isDark ? Color.black.opacity(0.7) : .white)
                .frame(width: 800, height: 800)
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            
            // 滑稽表情
            ZStack {
                // 眼睛（时钟样式）
                HStack(spacing: 160) {
                    TimeEye(rotation: 45, isDark: isDark)
                    TimeEye(rotation: -45, isDark: isDark)
                }
                
                // 嘴巴（弧形）
                Path { path in
                    path.addArc(
                        center: CGPoint(x: 0, y: 50),
                        radius: 200,
                        startAngle: .degrees(-80),
                        endAngle: .degrees(-100),
                        clockwise: true
                    )
                }
                .stroke(
                    LinearGradient(
                        colors: isDark ? IconColors.darkMouth : IconColors.lightMouth,
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 40, lineCap: .round)
                )
                .rotationEffect(.degrees(180))
                
                // 腮红
                HStack(spacing: 400) {
                    Circle()
                        .fill(isDark ? IconColors.darkCheeks : IconColors.lightCheeks)
                        .frame(width: 100, height: 100)
                    Circle()
                        .fill(isDark ? IconColors.darkCheeks : IconColors.lightCheeks)
                        .frame(width: 100, height: 100)
                }
                .offset(y: 50)
            }
            .frame(width: 600, height: 600)
        }
        .frame(width: 1024, height: 1024)
        .clipped()
        .ignoresSafeArea()
    }
}

#Preview {
    VStack(spacing: 20) {
        AppIconPreview(isDark: false)
            .frame(width: 200, height: 200)
        AppIconPreview(isDark: true)
            .frame(width: 200, height: 200)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
} 