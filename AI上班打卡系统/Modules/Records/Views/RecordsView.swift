import SwiftUI
import SwiftData

struct RecordsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AttendanceRecord.checkInTime, order: .reverse) private var records: [AttendanceRecord]
    @State private var selectedFilter = RecordFilter.thisMonth
    @State private var showDatePicker = false
    @State private var selectedDate = Date()
    
    enum RecordFilter: String, CaseIterable {
        case today = "today"
        case thisWeek = "thisWeek"
        case thisMonth = "thisMonth"
        case lastMonth = "lastMonth"
        case custom = "custom"
        
        @MainActor
        var localizedName: String {
            switch self {
            case .today: return "records.today".localized()
            case .thisWeek: return "records.thisWeek".localized()
            case .thisMonth: return "records.thisMonth".localized()
            case .lastMonth: return "records.lastMonth".localized()
            case .custom: return "records.custom".localized()
            }
        }
        
        var dateRange: (start: Date, end: Date) {
            let calendar = Calendar.current
            let now = Date()
            
            switch self {
            case .today:
                return (now.startOfDay(), now.endOfDay())
            case .thisWeek:
                let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
                return (startOfWeek, now)
            case .thisMonth:
                let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
                return (startOfMonth, now)
            case .lastMonth:
                let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
                let startOfLastMonth = calendar.dateInterval(of: .month, for: lastMonth)?.start ?? lastMonth
                let endOfLastMonth = calendar.dateInterval(of: .month, for: lastMonth)?.end ?? lastMonth
                return (startOfLastMonth, endOfLastMonth)
            case .custom:
                return (now.startOfDay(), now.endOfDay())
            }
        }
    }
    
    var filteredRecords: [AttendanceRecord] {
        let dateRange = selectedFilter.dateRange
        return records.filter { record in
            record.checkInTime >= dateRange.start && record.checkInTime <= dateRange.end
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                FilterBar(selectedFilter: $selectedFilter, showDatePicker: $showDatePicker)
                    .padding()
                
                if filteredRecords.isEmpty {
                    ContentUnavailableView(
                        "records.noRecords".localized(),
                        systemImage: "clock.badge.xmark",
                        description: Text("records.noRecordsDesc".localized())
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(groupedRecords, id: \.key) { date, records in
                                Section {
                                    ForEach(records) { record in
                                        RecordCard(record: record)
                                    }
                                } header: {
                                    DateHeader(date: date)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("records.title".localized())
            .sheet(isPresented: $showDatePicker) {
                DatePickerSheet(selectedDate: $selectedDate, selectedFilter: $selectedFilter)
            }
        }
    }
    
    var groupedRecords: [(key: Date, value: [AttendanceRecord])] {
        let grouped = Dictionary(grouping: filteredRecords) { record in
            Calendar.current.startOfDay(for: record.checkInTime)
        }
        return grouped.sorted { $0.key > $1.key }
    }
}

struct FilterBar: View {
    @Binding var selectedFilter: RecordsView.RecordFilter
    @Binding var showDatePicker: Bool
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(RecordsView.RecordFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.localizedName,
                        isSelected: selectedFilter == filter,
                        action: {
                            if filter == .custom {
                                showDatePicker = true
                            } else {
                                selectedFilter = filter
                            }
                        }
                    )
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .medium : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct DateHeader: View {
    let date: Date
    
    var body: some View {
        HStack {
            Text(date.formattedDate())
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.bottom, 4)
    }
}

struct RecordCard: View {
    let record: AttendanceRecord
    
    var statusInfo: (icon: String, color: Color, status: String) {
        let calendar = Calendar.current
        let checkInHour = calendar.component(.hour, from: record.checkInTime)
        let checkInMinute = calendar.component(.minute, from: record.checkInTime)
        
        if checkInHour > 9 || (checkInHour == 9 && checkInMinute > 0) {
            let lateMinutes = (checkInHour - 9) * 60 + checkInMinute
            return ("exclamationmark.circle.fill", .orange, "\("records.late".localized()) \(lateMinutes)min")
        } else {
            return ("checkmark.circle.fill", .green, "records.normal".localized())
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: "sunrise.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("records.checkInRecord".localized())
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(record.location)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(record.checkInTime.formattedTime())
                        .font(.headline)
                    
                    HStack(spacing: 4) {
                        Image(systemName: statusInfo.icon)
                            .font(.caption)
                        Text(statusInfo.status)
                            .font(.caption)
                    }
                    .foregroundColor(statusInfo.color)
                }
            }
            .padding()
            
            if let checkOutTime = record.checkOutTime {
                Divider()
                    .padding(.horizontal)
                
                
                HStack {
                    HStack(spacing: 12) {
                        Image(systemName: "moon.fill")
                            .font(.title2)
                            .foregroundColor(.indigo)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("records.checkOutRecord".localized())
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(record.location)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(checkOutTime.formattedTime())
                            .font(.headline)
                        
                        let workHours = checkOutTime.timeIntervalSince(record.checkInTime) / 3600
                        Text(String(format: "records.workHours".localized(), workHours))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            
            if record.withPhoto {
                HStack {
                    Image(systemName: "camera.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("attendance.photoCheckIn".localized())
                        .font(.caption)
                        .foregroundColor(.blue)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Binding var selectedFilter: RecordsView.RecordFilter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            DatePicker(
                "common.select".localized() + " " + "Date",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .padding()
            .navigationTitle("common.select".localized() + " " + "Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("common.cancel".localized()) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("common.confirm".localized()) {
                        selectedFilter = .custom
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RecordsView()
        .modelContainer(for: AttendanceRecord.self)
}