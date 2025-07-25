import Foundation
import SwiftData

@Model
final class AttendanceRecord {
    var id: UUID
    var checkInTime: Date
    var checkOutTime: Date?
    var location: String
    var withPhoto: Bool
    var photoData: Data?
    var notes: String?
    var createdAt: Date
    
    init(checkInTime: Date = Date(), location: String = "", withPhoto: Bool = false) {
        self.id = UUID()
        self.checkInTime = checkInTime
        self.location = location
        self.withPhoto = withPhoto
        self.createdAt = Date()
    }
}