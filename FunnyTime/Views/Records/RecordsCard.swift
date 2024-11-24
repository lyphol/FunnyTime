import SwiftUI
import SwiftData

struct RecordsCard: View {
    @Environment(\.modelContext) private var modelContext
    let records: [TimeRecord]
    @State private var recordToDelete: TimeRecord?
    
    private func getDeleteConfirmMessage(_ record: TimeRecord) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日"
        let dateString = formatter.string(from: record.date)
        
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = Locale(identifier: "zh_CN")
        weekdayFormatter.dateFormat = "EEE"
        let weekdayString = weekdayFormatter.string(from: record.date)
        
        return "是否删除 \(dateString) \(weekdayString) 的记录？"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("历史记录")
                .font(.headline)
                .foregroundColor(ColorTheme.History.cardTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
            
            Divider()
                .background(ColorTheme.History.separatorColor)
            
            if records.isEmpty {
                Text("暂无记录")
                    .foregroundColor(ColorTheme.History.emptyStateText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(24)
            } else {
                List {
                    ForEach(records) { record in
                        RecordRow(record: record)
                            .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                            .listRowSeparator(.visible)
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(ColorTheme.background)
                            )
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    recordToDelete = record
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .frame(height: max(CGFloat(records.count) * 70, 70))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(ColorTheme.background)
                .shadow(color: ColorTheme.cardShadow.opacity(0.1), radius: 10)
        )
        .confirmationDialog(
            "确认删除",
            isPresented: .constant(recordToDelete != nil)
        ) {
            Button("删除", role: .destructive) {
                if let record = recordToDelete {
                    withAnimation {
                        deleteRecord(record)
                    }
                }
                recordToDelete = nil
            }
            Button("取消", role: .cancel) {
                recordToDelete = nil
            }
        } message: {
            if let record = recordToDelete {
                Text(getDeleteConfirmMessage(record))
            }
        }
    }
    
    private func deleteRecord(_ record: TimeRecord) {
        modelContext.delete(record)
        try? modelContext.save()
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
} 
