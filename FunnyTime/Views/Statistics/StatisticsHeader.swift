import SwiftUI

struct StatisticsHeader: View {
    @Binding var selectedType: StatisticsViewType
    @Binding var selectedDate: Date
    let periodTitle: String
    let canGoBack: Bool
    let canGoForward: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // 周/月切换
            Picker("统计类型", selection: $selectedType) {
                Text("周统计").tag(StatisticsViewType.week)
                Text("月统计").tag(StatisticsViewType.month)
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 200)
            
            // 日期导航
            HStack {
                Button(action: {
                    withAnimation {
                        if selectedType == .week {
                            selectedDate = Calendar.current.date(byAdding: .day, value: -7, to: selectedDate)!
                        } else {
                            selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)!
                        }
                    }
                }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.title2)
                        .foregroundStyle(canGoBack ? .blue : .gray.opacity(0.3))
                }
                .disabled(!canGoBack)
                
                Text(periodTitle)
                    .font(.headline)
                    .frame(width: 150)
                    .foregroundStyle(.primary)
                
                Button(action: {
                    withAnimation {
                        if selectedType == .week {
                            selectedDate = Calendar.current.date(byAdding: .day, value: 7, to: selectedDate)!
                        } else {
                            selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate)!
                        }
                    }
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title2)
                        .foregroundStyle(canGoForward ? .blue : .gray.opacity(0.3))
                }
                .disabled(!canGoForward)
            }
        }
        .padding(.bottom, 8)
    }
} 