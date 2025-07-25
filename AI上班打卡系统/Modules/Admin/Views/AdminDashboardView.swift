import SwiftUI
import SwiftData
import Charts

struct AdminDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var todayRecords: [AttendanceRecord]
    @State private var totalEmployees = TestData.allAccounts.count
    @State private var checkedInCount = 0
    @State private var departmentStats: [DepartmentStat] = []
    
    var attendanceRate: Double {
        totalEmployees > 0 ? Double(checkedInCount) / Double(totalEmployees) * 100 : 0
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    RealTimeStatsCard(
                        checkedInCount: checkedInCount,
                        totalEmployees: totalEmployees,
                        attendanceRate: attendanceRate
                    )
                    
                    
                    DepartmentOverview(departmentStats: departmentStats)
                    
                    
                    PendingTasksSection()
                    
                    
                    AttendanceTrendChart(records: todayRecords)
                    
                    
                    AbnormalAttendanceSection()
                }
                .padding()
            }
            .navigationTitle("dashboard.title".localized())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: refreshData) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                loadDashboardData()
            }
        }
    }
    
    private func loadDashboardData() {
        
        let today = Date().startOfDay()
        checkedInCount = todayRecords.filter { record in
            record.checkInTime >= today
        }.count
        
        
        // Calculate real department statistics
        let deptCounts = TestData.departmentStats
        departmentStats = [
            DepartmentStat(
                name: "dashboard.techDept".localized(), 
                count: deptCounts["TechDept"] ?? 0,
                rate: Int.random(in: 85...100), // Simulated attendance rate
                trend: .up
            ),
            DepartmentStat(
                name: "dashboard.marketDept".localized(), 
                count: deptCounts["MarketDept"] ?? 0,
                rate: Int.random(in: 85...100), 
                trend: .up
            ),
            DepartmentStat(
                name: "dashboard.adminDept".localized(), 
                count: deptCounts["AdminDept"] ?? 0,
                rate: Int.random(in: 85...100), 
                trend: .down
            ),
            DepartmentStat(
                name: "dashboard.financeDept".localized(), 
                count: deptCounts["FinanceDept"] ?? 0,
                rate: Int.random(in: 85...100), 
                trend: .steady
            ),
            DepartmentStat(
                name: "dashboard.hrDept".localized(), 
                count: deptCounts["HRDept"] ?? 0,
                rate: Int.random(in: 85...100), 
                trend: .up
            )
        ]
    }
    
    private func refreshData() {
        loadDashboardData()
    }
}

struct DepartmentStat: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
    let rate: Int
    let trend: Trend
    
    enum Trend {
        case up, down, steady
    }
}

struct RealTimeStatsCard: View {
    let checkedInCount: Int
    let totalEmployees: Int
    let attendanceRate: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("dashboard.realTimeData".localized())
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(Date().formattedDate())
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.white.opacity(0.8))
            }
            
            HStack(spacing: 30) {
                VStack(alignment: .leading) {
                    Text("\(checkedInCount)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    Text("dashboard.checkedIn".localized())
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                VStack(alignment: .leading) {
                    Text(String(format: "%.0f%%", attendanceRate))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    Text("dashboard.checkInRate".localized())
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
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

struct DepartmentOverview: View {
    let departmentStats: [DepartmentStat]
    @State private var selectedDepartment: String?
    @State private var showingEmployeeList = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("dashboard.departmentOverview".localized())
                .font(.headline)
            
            VStack(spacing: 0) {
                ForEach(departmentStats) { stat in
                    Button(action: {
                        selectedDepartment = getDepartmentKey(from: stat.name)
                        showingEmployeeList = true
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(stat.name)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Text("\(stat.count) " + "employee.people".localized())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Text("\(stat.rate)%")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(stat.rate >= 95 ? .green : stat.rate >= 90 ? .orange : .red)
                                
                                Image(systemName: stat.trend == .up ? "arrow.up" : stat.trend == .down ? "arrow.down" : "minus")
                                    .font(.caption)
                                    .foregroundColor(stat.trend == .up ? .green : stat.trend == .down ? .red : .gray)
                            }
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if stat.id != departmentStats.last?.id {
                        Divider()
                    }
                }
            }
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .sheet(isPresented: $showingEmployeeList) {
            if let dept = selectedDepartment {
                DepartmentEmployeeListView(department: dept)
            }
        }
    }
    
    private func getDepartmentKey(from localizedName: String) -> String {
        // Map localized names back to department keys
        if localizedName == "dashboard.techDept".localized() { return "TechDept" }
        if localizedName == "dashboard.marketDept".localized() { return "MarketDept" }
        if localizedName == "dashboard.adminDept".localized() { return "AdminDept" }
        if localizedName == "dashboard.financeDept".localized() { return "FinanceDept" }
        if localizedName == "dashboard.hrDept".localized() { return "HRDept" }
        return "TechDept"
    }
}

struct PendingTasksSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("dashboard.pendingTasks".localized())
                .font(.headline)
            
            HStack(spacing: 12) {
                PendingTaskCard(
                    icon: "calendar.badge.exclamationmark",
                    count: 5,
                    title: "dashboard.pendingLeave".localized(),
                    color: .red
                )
                
                PendingTaskCard(
                    icon: "clock.badge.exclamationmark",
                    count: 3,
                    title: "dashboard.pendingMakeup".localized(),
                    color: .orange
                )
            }
        }
    }
}

struct PendingTaskCard: View {
    let icon: String
    let count: Int
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct AttendanceTrendChart: View {
    let records: [AttendanceRecord]
    
    var hourlyData: [(hour: Int, count: Int)] {
        let calendar = Calendar.current
        var counts = Array(repeating: 0, count: 24)
        
        for record in records {
            let hour = calendar.component(.hour, from: record.checkInTime)
            counts[hour] += 1
        }
        
        return counts.enumerated().map { (hour: $0, count: $1) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("dashboard.attendanceTrend".localized())
                .font(.headline)
            
            Chart(hourlyData, id: \.hour) { item in
                BarMark(
                    x: .value("Time", "\(item.hour)h"),
                    y: .value("Count", item.count)
                )
                .foregroundStyle(Color.blue.gradient)
            }
            .frame(height: 200)
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

struct AbnormalAttendanceSection: View {
    @Query private var todayRecords: [AttendanceRecord]
    
    var abnormalAttendances: [(employee: TestAccount, type: String, time: String, color: Color)] {
        // For demo purposes, randomly select some employees for abnormal attendance
        let randomEmployees = TestData.workerAccounts.shuffled().prefix(3)
        return randomEmployees.enumerated().map { index, employee in
            switch index {
            case 0:
                return (employee, "records.late".localized(), "09:25", .orange)
            case 1:
                return (employee, "statistics.earlyLeave".localized(), "17:30", .yellow)
            default:
                return (employee, "statistics.absent".localized(), "-", .red)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("dashboard.abnormalAttendance".localized())
                    .font(.headline)
                Spacer()
                Button("dashboard.viewAll".localized()) {
                    
                }
                .font(.caption)
            }
            
            VStack(spacing: 8) {
                ForEach(Array(abnormalAttendances.enumerated()), id: \.offset) { _, item in
                    AbnormalAttendanceRow(
                        name: item.employee.name,
                        department: getDepartmentLocalizedName(item.employee.department),
                        type: item.type,
                        time: item.time,
                        color: item.color
                    )
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
    }
    
    private func getDepartmentLocalizedName(_ dept: String) -> String {
        switch dept {
        case "TechDept": return "dashboard.techDept".localized()
        case "MarketDept": return "dashboard.marketDept".localized()
        case "AdminDept": return "dashboard.adminDept".localized()
        case "FinanceDept": return "dashboard.financeDept".localized()
        case "HRDept": return "dashboard.hrDept".localized()
        default: return dept
        }
    }
}

struct AbnormalAttendanceRow: View {
    let name: String
    let department: String
    let type: String
    let time: String
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(department)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Text(type)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(color.opacity(0.2))
                    .foregroundColor(color)
                    .cornerRadius(4)
                
                Text(time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    AdminDashboardView()
        .modelContainer(for: AttendanceRecord.self)
}