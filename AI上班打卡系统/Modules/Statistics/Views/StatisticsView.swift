import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var userService: UserService
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    PeriodSelector(selectedPeriod: $viewModel.selectedPeriod)
                        .onChange(of: viewModel.selectedPeriod) { _, _ in
                            viewModel.loadStatistics()
                        }
                    
                    if let statistics = viewModel.statistics {
                        StatisticsSummaryView(statistics: statistics)
                        WorkHoursChartView(records: viewModel.attendanceRecords)
                        AttendanceListView(records: viewModel.attendanceRecords)
                    } else {
                        ContentUnavailableView(
                            "common.empty".localized(),
                            systemImage: "chart.bar.xaxis",
                            description: Text("Start checking in to see your attendance statistics")
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("statistics.title".localized())
            .toolbar {
                if userService.currentUser.isAdmin {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(action: {}) {
                                Label("settings.exportData".localized(), systemImage: "square.and.arrow.up")
                            }
                            Button(action: {}) {
                                Label("View All Users", systemImage: "person.3")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .onAppear {
                viewModel.setup(modelContext: modelContext)
            }
        }
    }
}

struct PeriodSelector: View {
    @Binding var selectedPeriod: StatisticsViewModel.StatisticsPeriod
    
    var body: some View {
        Picker("Period", selection: $selectedPeriod) {
            ForEach(StatisticsViewModel.StatisticsPeriod.allCases, id: \.self) { period in
                Text(period.localizedName).tag(period)
            }
        }
        .pickerStyle(.segmented)
    }
}

struct StatisticsSummaryView: View {
    let statistics: AttendanceStatistics
    
    var body: some View {
        VStack(spacing: 16) {
            
            MonthlyOverviewCard(statistics: statistics)
            
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                DetailStatCard(
                    icon: "checkmark.circle.fill",
                    iconColor: .green,
                    value: "\(statistics.completedDays)",
                    title: "statistics.normalAttend".localized(),
                    subtitle: "statistics.completeDays".localized()
                )
                
                DetailStatCard(
                    icon: "clock.badge.exclamationmark.fill",
                    iconColor: .orange,
                    value: "\(statistics.lateCheckIns)",
                    title: "statistics.late".localized(),
                    subtitle: "After 9:00"
                )
                
                DetailStatCard(
                    icon: "arrow.left.square.fill",
                    iconColor: .yellow,
                    value: "\(statistics.earlyCheckOuts)",
                    title: "statistics.earlyLeave".localized(),
                    subtitle: "Before 18:00"
                )
                
                DetailStatCard(
                    icon: "xmark.circle.fill",
                    iconColor: .red,
                    value: "\(statistics.absentDays)",
                    title: "statistics.absent".localized(),
                    subtitle: "No check-in"
                )
                
                DetailStatCard(
                    icon: "calendar.badge.minus",
                    iconColor: .blue,
                    value: "\(statistics.leaveDays)",
                    title: "statistics.leave".localized(),
                    subtitle: "Approved"
                )
                
                DetailStatCard(
                    icon: "moon.stars.fill",
                    iconColor: .indigo,
                    value: "\(statistics.lateCheckOuts)",
                    title: "statistics.overtime".localized(),
                    subtitle: "After 18:00"
                )
            }
            
            
            PhotoCheckInCard(
                verifiedDays: statistics.photoCheckInDays,
                totalDays: statistics.totalDays,
                rate: statistics.photoCheckInRate
            )
            
            
            AverageWorkHoursCard(
                averageHours: statistics.averageWorkHours,
                totalHours: statistics.totalWorkHours
            )
        }
    }
}

struct MonthlyOverviewCard: View {
    let statistics: AttendanceStatistics
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("statistics.monthlyOverview".localized())
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(Date().formattedDate())
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Image(systemName: "chart.pie.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            HStack(spacing: 30) {
                VStack {
                    Text("\(statistics.totalDays)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Text("statistics.shouldAttend".localized())
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                VStack {
                    Text("\(statistics.completedDays)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Text("statistics.actualAttend".localized())
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                VStack {
                    Text(String(format: "%.0f%%", statistics.completionRate))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Text("statistics.attendanceRate".localized())
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.cyan]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}

struct DetailStatCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.08))
        .cornerRadius(12)
    }
}

struct PhotoCheckInCard: View {
    let verifiedDays: Int
    let totalDays: Int
    let rate: Double
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Label("statistics.photoCheckIn".localized(), systemImage: "camera.fill")
                    .font(.headline)
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("\(verifiedDays)天")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("statistics.verified".localized())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(String(format: "%.0f%%", rate))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                        Text("statistics.verificationRate".localized())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: rate / 100)
                    .stroke(Color.green, lineWidth: 8)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .cornerRadius(12)
    }
}

struct AverageWorkHoursCard: View {
    let averageHours: Double
    let totalHours: Double
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Label("statistics.workHourStats".localized(), systemImage: "timer")
                    .font(.headline)
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text(String(format: "%.1fh", averageHours))
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("statistics.dailyAverage".localized())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(String(format: "%.0fh", totalHours))
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("statistics.totalHours".localized())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: averageHours >= 8 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(averageHours >= 8 ? .green : .orange)
        }
        .padding()
        .background(Color.orange.opacity(0.05))
        .cornerRadius(12)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct WorkHoursChartView: View {
    let records: [AttendanceRecord]
    
    var chartData: [(date: Date, hours: Double)] {
        records.compactMap { record in
            guard let checkOut = record.checkOutTime else { return nil }
            let hours = checkOut.timeIntervalSince(record.checkInTime) / 3600
            return (record.checkInTime, hours)
        }.prefix(7).reversed()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Work Hours Trend")
                .font(.headline)
            
            if !chartData.isEmpty {
                Chart(chartData, id: \.date) { item in
                    BarMark(
                        x: .value("日期", item.date, unit: .day),
                        y: .value("小时", item.hours)
                    )
                    .foregroundStyle(.blue.gradient)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisValueLabel(format: .dateTime.day().month())
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let hours = value.as(Double.self) {
                                Text("\(Int(hours))h")
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(15)
    }
}

struct AttendanceListView: View {
    let records: [AttendanceRecord]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Attendance Records")
                .font(.headline)
            
            ForEach(records.prefix(10)) { record in
                AttendanceRowView(record: record)
            }
        }
    }
}

struct AttendanceRowView: View {
    let record: AttendanceRecord
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.checkInTime.formattedDate())
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("\("attendance.checkIn".localized()): \(record.checkInTime.formattedTime())")
                    if let checkOut = record.checkOutTime {
                        Text("\("attendance.checkOut".localized()): \(checkOut.formattedTime())")
                    } else {
                        Text("In Progress")
                            .foregroundColor(.orange)
                    }
                }
                .font(.subheadline)
            }
            
            Spacer()
            
            if record.withPhoto {
                Image(systemName: "camera.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: [AttendanceRecord.self, UserSettings.self])
}