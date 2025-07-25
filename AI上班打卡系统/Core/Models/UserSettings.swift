import Foundation
import SwiftData

@Model
final class UserSettings {
    var id: UUID
    var workStartTime: Date
    var workEndTime: Date
    var enablePhotoCheckIn: Bool
    var enableNotifications: Bool
    var defaultLocation: String
    
    init() {
        self.id = UUID()
        let calendar = Calendar.current
        let now = Date()
        self.workStartTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now) ?? now
        self.workEndTime = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: now) ?? now
        self.enablePhotoCheckIn = true
        self.enableNotifications = true
        self.defaultLocation = "办公室"
    }
}