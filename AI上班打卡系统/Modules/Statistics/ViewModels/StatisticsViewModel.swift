import Foundation
import SwiftUI
import SwiftData

@MainActor
class StatisticsViewModel: ObservableObject {
    @Published var selectedPeriod: StatisticsPeriod = .week
    @Published var attendanceRecords: [AttendanceRecord] = []
    @Published var statistics: AttendanceStatistics?
    
    private var modelContext: ModelContext?
    
    enum StatisticsPeriod: String, CaseIterable {
        case week = "week"
        case month = "month"
        case all = "all"
        
        @MainActor
        var localizedName: String {
            switch self {
            case .week: return "records.thisWeek".localized()
            case .month: return "records.thisMonth".localized()
            case .all: return "common.all".localized()
            }
        }
        
        var dateRange: (start: Date, end: Date) {
            let calendar = Calendar.current
            let now = Date()
            
            switch self {
            case .week:
                let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
                return (startOfWeek, now)
            case .month:
                let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
                return (startOfMonth, now)
            case .all:
                return (Date.distantPast, now)
            }
        }
    }
    
    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadStatistics()
    }
    
    func loadStatistics() {
        guard let modelContext = modelContext else { return }
        
        let dateRange = selectedPeriod.dateRange
        let startDate = dateRange.start
        let endDate = dateRange.end
        
        let descriptor = FetchDescriptor<AttendanceRecord>(
            predicate: #Predicate { record in
                record.checkInTime >= startDate && record.checkInTime <= endDate
            },
            sortBy: [SortDescriptor(\.checkInTime, order: .reverse)]
        )
        
        do {
            attendanceRecords = try modelContext.fetch(descriptor)
            calculateStatistics()
        } catch {
            print("Failed to fetch records: \(error)")
        }
    }
    
    private func calculateStatistics() {
        guard !attendanceRecords.isEmpty else {
            statistics = nil
            return
        }
        
        let totalDays = attendanceRecords.count
        let completedDays = attendanceRecords.filter { $0.checkOutTime != nil }.count
        let photoCheckInDays = attendanceRecords.filter { $0.withPhoto }.count
        
        var totalWorkHours: TimeInterval = 0
        var earlyCheckIns = 0
        var lateCheckIns = 0
        var earlyCheckOuts = 0
        var lateCheckOuts = 0
        
        let calendar = Calendar.current
        let workStartHour = 9
        let workStartMinute = 0
        let workEndHour = 18
        let workEndMinute = 0
        
        for record in attendanceRecords {
            
            if let checkOutTime = record.checkOutTime {
                totalWorkHours += checkOutTime.timeIntervalSince(record.checkInTime)
            }
            
            
            let checkInHour = calendar.component(.hour, from: record.checkInTime)
            let checkInMinute = calendar.component(.minute, from: record.checkInTime)
            if checkInHour > workStartHour || (checkInHour == workStartHour && checkInMinute > workStartMinute) {
                lateCheckIns += 1
            } else if checkInHour < workStartHour {
                earlyCheckIns += 1
            }
            
            
            if let checkOutTime = record.checkOutTime {
                let checkOutHour = calendar.component(.hour, from: checkOutTime)
                let checkOutMinute = calendar.component(.minute, from: checkOutTime)
                if checkOutHour < workEndHour || (checkOutHour == workEndHour && checkOutMinute < workEndMinute) {
                    earlyCheckOuts += 1
                } else if checkOutHour > workEndHour || (checkOutHour == workEndHour && checkOutMinute > workEndMinute) {
                    lateCheckOuts += 1
                }
            }
        }
        
        let averageWorkHours = completedDays > 0 ? totalWorkHours / Double(completedDays) / 3600 : 0
        let totalWorkHoursInHours = totalWorkHours / 3600
        
        
        let absentDays = max(0, 22 - totalDays) 
        let leaveDays = 0 
        
        statistics = AttendanceStatistics(
            totalDays: totalDays,
            completedDays: completedDays,
            averageWorkHours: averageWorkHours,
            totalWorkHours: totalWorkHoursInHours,
            earlyCheckIns: earlyCheckIns,
            earlyCheckOuts: earlyCheckOuts,
            lateCheckIns: lateCheckIns,
            lateCheckOuts: lateCheckOuts,
            photoCheckInDays: photoCheckInDays,
            absentDays: absentDays,
            leaveDays: leaveDays
        )
    }
}

struct AttendanceStatistics {
    let totalDays: Int
    let completedDays: Int
    let averageWorkHours: Double
    let totalWorkHours: Double
    let earlyCheckIns: Int
    let earlyCheckOuts: Int
    let lateCheckIns: Int
    let lateCheckOuts: Int
    let photoCheckInDays: Int
    let absentDays: Int
    let leaveDays: Int
    
    var completionRate: Double {
        totalDays > 0 ? Double(completedDays) / Double(totalDays) * 100 : 0
    }
    
    var photoCheckInRate: Double {
        totalDays > 0 ? Double(photoCheckInDays) / Double(totalDays) * 100 : 0
    }
}