import SwiftUI
import SwiftData
import Foundation

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TimeRecord.date, order: .reverse) private var allRecords: [TimeRecord]
    @Query private var weeklyWorkdays: [WeeklyWorkdays]
    @State private var showingSettings = false
    @State private var selectedType: StatisticsViewType = .week
    @State private var selectedDate: Date = Date()
    @State private var showingExportSheet = false
    @State private var showingImportPicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var todayRecord: TimeRecord? {
        allRecords.first { Calendar.current.isDate($0.date, inSameDayAs: Date()) }
    }
    
    var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        switch selectedType {
        case .week:
            let weekday = calendar.component(.weekday, from: selectedDate)
            let mondayOffset = weekday == 1 ? -6 : -(weekday - 2)
            let weekStart = calendar.date(byAdding: .day, value: mondayOffset, to: selectedDate)!
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
            return (weekStart, weekEnd)
        case .month:
            let components = calendar.dateComponents([.year, .month], from: selectedDate)
            let monthStart = calendar.date(from: components)!
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!
            return (monthStart, monthEnd)
        }
    }
    
    var filteredRecords: [TimeRecord] {
        allRecords.filter { record in
            record.date >= dateRange.start && record.date < dateRange.end
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    CheckInCard(
                        todayRecord: todayRecord,
                        onCheckAction: handleCheckAction
                    )
                    
                    StatisticsView(
                        records: allRecords,
                        weeklyWorkdays: weeklyWorkdays,
                        selectedType: $selectedType,
                        selectedDate: $selectedDate
                    )
                    
                    RecordsCard(records: filteredRecords)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("考勤记录")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: { showingExportSheet = true }) {
                            Label("导出数据", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: { showingImportPicker = true }) {
                            Label("导入数据", systemImage: "square.and.arrow.down")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.primary)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(selectedDate: selectedDate)
            }
            .sheet(isPresented: $showingExportSheet) {
                ShareSheet(items: [createExportFile()])
            }
            .fileImporter(
                isPresented: $showingImportPicker,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result)
            }
            .alert("提示", isPresented: $showingAlert) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func handleCheckAction() {
        let today = Date()
        if let record = todayRecord {
            if record.checkInTime == nil {
                record.checkInTime = today
            } else if record.checkOutTime == nil {
                record.checkOutTime = today
            }
        } else {
            let newRecord = TimeRecord(date: today, checkInTime: today)
            modelContext.insert(newRecord)
        }
    }
    
    private func createExportFile() -> URL {
        DataManager.createExportFile(records: allRecords, weeklyWorkdays: weeklyWorkdays)
    }
    
    private func handleImport(_ result: Result<[URL], Error>) {
        do {
            guard let selectedFile = try result.get().first else { return }
            alertMessage = try DataManager.importData(from: selectedFile, into: modelContext)
        } catch {
            alertMessage = "导入失败：\(error.localizedDescription)"
        }
        showingAlert = true
    }
} 