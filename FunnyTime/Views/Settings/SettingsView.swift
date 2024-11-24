import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var weeklyWorkdays: [WeeklyWorkdays]
    
    let selectedDate: Date
    
    var body: some View {
        NavigationStack {
            Form {
                WeeklyWorkdaysSection(
                    selectedDate: selectedDate,
                    weeklyWorkdays: weeklyWorkdays,
                    modelContext: modelContext
                )
            }
            .navigationTitle("工作日设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
} 