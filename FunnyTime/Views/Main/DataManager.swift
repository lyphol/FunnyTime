import SwiftUI
import SwiftData

struct DataManager {
    static func createExportFile(records: [TimeRecord], weeklyWorkdays: [WeeklyWorkdays]) -> URL {
        let exportData = ExportData(
            records: records.map { record in
                ExportData.RecordData(
                    date: record.date,
                    checkInTime: record.checkInTime,
                    checkOutTime: record.checkOutTime
                )
            },
            workdays: weeklyWorkdays.map { setting in
                ExportData.WorkdayData(
                    year: setting.year,
                    week: setting.week,
                    workdays: setting.workdays
                )
            }
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(exportData)
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("FunnyTime_\(Date().timeIntervalSince1970).json")
            try data.write(to: url)
            return url
        } catch {
            print("Export error: \(error)")
            return FileManager.default.temporaryDirectory
        }
    }
    
    static func importData(from url: URL, into context: ModelContext) throws -> String {
        guard url.startAccessingSecurityScopedResource() else {
            throw NSError(domain: "FunnyTime", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法访问文件"])
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let importData = try decoder.decode(ExportData.self, from: data)
        
        // 获取现有记录
        let recordsDescriptor = FetchDescriptor<TimeRecord>()
        let workdaysDescriptor = FetchDescriptor<WeeklyWorkdays>()
        
        let existingRecords = try context.fetch(recordsDescriptor)
        let existingWorkdays = try context.fetch(workdaysDescriptor)
        
        // 清除现有数据
        existingRecords.forEach { context.delete($0) }
        existingWorkdays.forEach { context.delete($0) }
        
        // 导入新数据
        importData.records.forEach { recordData in
            let record = TimeRecord(
                date: recordData.date,
                checkInTime: recordData.checkInTime,
                checkOutTime: recordData.checkOutTime
            )
            context.insert(record)
        }
        
        importData.workdays.forEach { workdayData in
            let setting = WeeklyWorkdays(
                year: workdayData.year,
                week: workdayData.week,
                workdays: workdayData.workdays
            )
            context.insert(setting)
        }
        
        return "数据导入成功"
    }
} 