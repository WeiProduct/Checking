import Foundation
import SwiftUI
import SwiftData

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var userSettings: UserSettings?
    @Published var workStartTime = Date()
    @Published var workEndTime = Date()
    @Published var enablePhotoCheckIn = true
    @Published var enableNotifications = true
    @Published var defaultLocation = "办公室"
    @Published var showExportSheet = false
    @Published var showClearDataAlert = false
    
    private var modelContext: ModelContext?
    
    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadSettings()
    }
    
    func loadSettings() {
        guard let modelContext = modelContext else { return }
        
        let descriptor = FetchDescriptor<UserSettings>()
        
        do {
            let settings = try modelContext.fetch(descriptor)
            if let existingSettings = settings.first {
                userSettings = existingSettings
                updatePublishedProperties()
            } else {
                createDefaultSettings()
            }
        } catch {
            print("Failed to load settings: \(error)")
            createDefaultSettings()
        }
    }
    
    private func createDefaultSettings() {
        guard let modelContext = modelContext else { return }
        
        let newSettings = UserSettings()
        modelContext.insert(newSettings)
        
        do {
            try modelContext.save()
            userSettings = newSettings
            updatePublishedProperties()
        } catch {
            print("Failed to create settings: \(error)")
        }
    }
    
    private func updatePublishedProperties() {
        guard let settings = userSettings else { return }
        
        workStartTime = settings.workStartTime
        workEndTime = settings.workEndTime
        enablePhotoCheckIn = settings.enablePhotoCheckIn
        enableNotifications = settings.enableNotifications
        defaultLocation = settings.defaultLocation
    }
    
    func saveSettings() {
        guard let settings = userSettings else { return }
        
        settings.workStartTime = workStartTime
        settings.workEndTime = workEndTime
        settings.enablePhotoCheckIn = enablePhotoCheckIn
        settings.enableNotifications = enableNotifications
        settings.defaultLocation = defaultLocation
        
        do {
            try modelContext?.save()
        } catch {
            print("Failed to save settings: \(error)")
        }
    }
    
    func exportData() {
        showExportSheet = true
    }
    
    func clearAllData() {
        guard let modelContext = modelContext else { return }
        
        do {
            try modelContext.delete(model: AttendanceRecord.self)
            try modelContext.save()
        } catch {
            print("Failed to clear data: \(error)")
        }
    }
    
    func generateExportData() -> String {
        guard let modelContext = modelContext else { return "" }
        
        let descriptor = FetchDescriptor<AttendanceRecord>(
            sortBy: [SortDescriptor(\.checkInTime, order: .reverse)]
        )
        
        do {
            let records = try modelContext.fetch(descriptor)
            var exportText = "日期,上班时间,下班时间,工作时长,地点,拍照打卡\n"
            
            for record in records {
                let date = record.checkInTime.formattedDate()
                let checkIn = record.checkInTime.formattedTime()
                let checkOut = record.checkOutTime?.formattedTime() ?? "未打卡"
                
                var duration = "进行中"
                if let checkOutTime = record.checkOutTime {
                    let hours = Int(checkOutTime.timeIntervalSince(record.checkInTime)) / 3600
                    let minutes = (Int(checkOutTime.timeIntervalSince(record.checkInTime)) % 3600) / 60
                    duration = "\(hours)小时\(minutes)分钟"
                }
                
                let location = record.location
                let photoCheckIn = record.withPhoto ? "是" : "否"
                
                exportText += "\(date),\(checkIn),\(checkOut),\(duration),\(location),\(photoCheckIn)\n"
            }
            
            return exportText
        } catch {
            print("Failed to export data: \(error)")
            return ""
        }
    }
}