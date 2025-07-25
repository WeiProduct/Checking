import Foundation
import SwiftUI
import SwiftData

@MainActor
class AttendanceViewModel: ObservableObject {
    @Published var todayRecord: AttendanceRecord?
    @Published var isCheckedIn = false
    @Published var currentTime = Date()
    @Published var showAICamera = false
    
    private var timer: Timer?
    private var modelContext: ModelContext?
    
    init() {
        startTimer()
    }
    
    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadTodayRecord()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.currentTime = Date()
            }
        }
    }
    
    func loadTodayRecord() {
        guard let modelContext = modelContext else { return }
        
        let today = Date().startOfDay()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? Date()
        
        let descriptor = FetchDescriptor<AttendanceRecord>(
            predicate: #Predicate { record in
                record.checkInTime >= today && record.checkInTime < tomorrow
            },
            sortBy: [SortDescriptor(\.checkInTime, order: .reverse)]
        )
        
        do {
            let records = try modelContext.fetch(descriptor)
            todayRecord = records.first
            isCheckedIn = todayRecord != nil && todayRecord?.checkOutTime == nil
        } catch {
            print("Failed to fetch today's record: \(error)")
        }
    }
    
    func checkIn(location: String, withPhoto: Bool = false, screenshot: Data? = nil) {
        guard let modelContext = modelContext else { return }
        
        let record = AttendanceRecord(
            checkInTime: Date(),
            location: location,
            withPhoto: withPhoto
        )
        record.photoData = screenshot
        
        modelContext.insert(record)
        
        do {
            try modelContext.save()
            todayRecord = record
            isCheckedIn = true
        } catch {
            print("Failed to save check-in: \(error)")
        }
    }
    
    func checkOut() {
        guard let modelContext = modelContext,
              let record = todayRecord else { return }
        
        record.checkOutTime = Date()
        
        do {
            try modelContext.save()
            isCheckedIn = false
        } catch {
            print("Failed to save check-out: \(error)")
        }
    }
    
    func toggleAICamera() {
        showAICamera.toggle()
    }
    
    deinit {
        timer?.invalidate()
    }
}