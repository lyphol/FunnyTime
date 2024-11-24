import SwiftUI

struct TimeEye: View {
    let rotation: Double
    let isDark: Bool
    
    var body: some View {
        ZStack {
            // 眼睛外圈
            Circle()
                .stroke(
                    LinearGradient(
                        colors: isDark ? [
                            Color(red: 100/255, green: 149/255, blue: 237/255),
                            Color(red: 70/255, green: 130/255, blue: 180/255)
                        ] : [
                            Color(red: 70/255, green: 130/255, blue: 180/255),
                            Color(red: 100/255, green: 149/255, blue: 237/255)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 20
                )
                .frame(width: 120, height: 120)
            
            // 时针（眼珠）
            RoundedRectangle(cornerRadius: 5)
                .fill(
                    LinearGradient(
                        colors: isDark ? [
                            Color(red: 100/255, green: 149/255, blue: 237/255),
                            Color(red: 70/255, green: 130/255, blue: 180/255)
                        ] : [
                            Color(red: 70/255, green: 130/255, blue: 180/255),
                            Color(red: 100/255, green: 149/255, blue: 237/255)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 10, height: 50)
                .offset(y: -20)
                .rotationEffect(.degrees(rotation))
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        TimeEye(rotation: 45, isDark: false)
        TimeEye(rotation: -45, isDark: true)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
} 