import SwiftUI


@MainActor
private func getDepartmentName(_ dept: String) -> String {
    switch dept {
    case "TechDept": return "dashboard.techDept".localized()
    case "MarketDept": return "dashboard.marketDept".localized()
    case "AdminDept": return "dashboard.adminDept".localized()
    case "FinanceDept": return "dashboard.financeDept".localized()
    case "HRDept": return "dashboard.hrDept".localized()
    default: return dept
    }
}

struct ApprovalCenterView: View {
    @State private var selectedTab = 0
    @State private var pendingApprovals: [ApprovalItem] = ApprovalItem.samplePendingData
    @State private var approvedItems: [ApprovalItem] = ApprovalItem.sampleApprovedData
    @State private var showingApprovalDetail: ApprovalItem?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                Picker("", selection: $selectedTab) {
                    Text("approval.pending".localized()).tag(0)
                    Text("approval.approved".localized()).tag(1)
                    Text("approval.all".localized()).tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                
                Group {
                    switch selectedTab {
                    case 0:
                        PendingApprovalsList(items: pendingApprovals, onApprove: approveItem, onReject: rejectItem)
                    case 1:
                        ApprovedItemsList(items: approvedItems)
                    default:
                        AllApprovalsList(pending: pendingApprovals, approved: approvedItems)
                    }
                }
            }
            .navigationTitle("approval.title".localized())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {}) {
                            Label("Filter by Type", systemImage: "line.3.horizontal.decrease.circle")
                        }
                        Button(action: {}) {
                            Label("Sort by Time", systemImage: "arrow.up.arrow.down")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
    
    private func approveItem(_ item: ApprovalItem) {
        
        if let index = pendingApprovals.firstIndex(where: { $0.id == item.id }) {
            var approvedItem = pendingApprovals.remove(at: index)
            approvedItem.status = .approved
            approvedItem.approvalTime = Date()
            approvedItems.insert(approvedItem, at: 0)
        }
    }
    
    private func rejectItem(_ item: ApprovalItem) {
        
        if let index = pendingApprovals.firstIndex(where: { $0.id == item.id }) {
            var rejectedItem = pendingApprovals.remove(at: index)
            rejectedItem.status = .rejected
            rejectedItem.approvalTime = Date()
            approvedItems.insert(rejectedItem, at: 0)
        }
    }
}

struct ApprovalItem: Identifiable {
    let id = UUID()
    let applicantName: String
    let department: String
    let type: ApprovalType
    let reason: String
    let startDate: Date
    let endDate: Date?
    let submitTime: Date
    var status: ApprovalStatus
    var approvalTime: Date?
    
    enum ApprovalType: String {
        case leave = "leave"
        case overtime = "overtime"
        case makeup = "makeup"
        case businessTrip = "businessTrip"
        
        @MainActor
        var localizedName: String {
            switch self {
            case .leave: return "approval.leaveRequest".localized()
            case .overtime: return "approval.overtimeRequest".localized()
            case .makeup: return "approval.makeupRequest".localized()
            case .businessTrip: return "approval.businessTrip".localized()
            }
        }
        
        var icon: String {
            switch self {
            case .leave: return "calendar.badge.minus"
            case .overtime: return "clock.badge.plus"
            case .makeup: return "clock.badge.exclamationmark"
            case .businessTrip: return "airplane"
            }
        }
        
        var color: Color {
            switch self {
            case .leave: return .orange
            case .overtime: return .blue
            case .makeup: return .purple
            case .businessTrip: return .green
            }
        }
    }
    
    enum ApprovalStatus {
        case pending, approved, rejected
    }
    
    static let samplePendingData = [
        ApprovalItem(
            applicantName: "Wang Xiaoming",
            department: "TechDept",
            type: .leave,
            reason: "Family matters",
            startDate: Date().addingTimeInterval(86400),
            endDate: Date().addingTimeInterval(86400 * 2),
            submitTime: Date().addingTimeInterval(-3600),
            status: .pending
        ),
        ApprovalItem(
            applicantName: "Li Xiaohong",
            department: "MarketDept",
            type: .makeup,
            reason: "System error, unable to check in",
            startDate: Date().addingTimeInterval(-86400),
            endDate: nil,
            submitTime: Date().addingTimeInterval(-7200),
            status: .pending
        ),
        ApprovalItem(
            applicantName: "Zhang San",
            department: "FinanceDept",
            type: .overtime,
            reason: "Month-end settlement",
            startDate: Date(),
            endDate: Date().addingTimeInterval(14400),
            submitTime: Date().addingTimeInterval(-1800),
            status: .pending
        )
    ]
    
    static let sampleApprovedData = [
        ApprovalItem(
            applicantName: "Liu Si",
            department: "AdminDept",
            type: .leave,
            reason: "Annual leave",
            startDate: Date().addingTimeInterval(-86400 * 7),
            endDate: Date().addingTimeInterval(-86400 * 3),
            submitTime: Date().addingTimeInterval(-86400 * 10),
            status: .approved,
            approvalTime: Date().addingTimeInterval(-86400 * 9)
        )
    ]
}

struct PendingApprovalsList: View {
    let items: [ApprovalItem]
    let onApprove: (ApprovalItem) -> Void
    let onReject: (ApprovalItem) -> Void
    
    var body: some View {
        if items.isEmpty {
            ContentUnavailableView(
                "approval.noPending".localized(),
                systemImage: "checkmark.circle",
                description: Text("approval.noPendingDesc".localized())
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(items) { item in
                        ApprovalCard(item: item, onApprove: {
                            onApprove(item)
                        }, onReject: {
                            onReject(item)
                        })
                    }
                }
                .padding()
            }
        }
    }
}

struct ApprovedItemsList: View {
    let items: [ApprovalItem]
    
    var body: some View {
        if items.isEmpty {
            ContentUnavailableView(
                "approval.noApproved".localized(),
                systemImage: "doc.text",
                description: Text("approval.noApprovedDesc".localized())
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(items) { item in
                        ApprovedItemCard(item: item)
                    }
                }
                .padding()
            }
        }
    }
}

struct AllApprovalsList: View {
    let pending: [ApprovalItem]
    let approved: [ApprovalItem]
    
    var allItems: [ApprovalItem] {
        (pending + approved).sorted { $0.submitTime > $1.submitTime }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(allItems) { item in
                    if item.status == .pending {
                        ApprovalCard(item: item, onApprove: {}, onReject: {})
                    } else {
                        ApprovedItemCard(item: item)
                    }
                }
            }
            .padding()
        }
    }
}

struct ApprovalCard: View {
    let item: ApprovalItem
    let onApprove: () -> Void
    let onReject: () -> Void
    @State private var showingRejectReason = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(item.type.color.gradient)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(item.applicantName.prefix(1)))
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                        )
                    
                    VStack(alignment: .leading) {
                        Text(item.applicantName)
                            .font(.headline)
                        Text("\(getDepartmentName(item.department)) · \(item.type.localizedName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Label("approval.status.pending".localized(), systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(6)
            }
            
            
            VStack(alignment: .leading, spacing: 8) {
                DetailRow(label: "approval.applicationType".localized(), value: item.type.localizedName, icon: item.type.icon, color: item.type.color)
                DetailRow(label: "approval.startTime".localized(), value: item.startDate.formattedDateTime())
                if let endDate = item.endDate {
                    DetailRow(label: "approval.endTime".localized(), value: endDate.formattedDateTime())
                }
                DetailRow(label: "approval.reason".localized(), value: item.reason)
                DetailRow(label: "approval.submitTime".localized(), value: item.submitTime.formattedDateTime())
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
            
            
            HStack(spacing: 12) {
                Button(action: onApprove) {
                    Label("approval.approve".localized(), systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    showingRejectReason = true
                }) {
                    Label("approval.reject".localized(), systemImage: "xmark")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .alert("approval.rejectReason".localized(), isPresented: $showingRejectReason) {
            TextField("Enter rejection reason", text: .constant(""))
            Button("common.cancel".localized(), role: .cancel) {}
            Button("approval.confirmReject".localized(), role: .destructive) {
                onReject()
            }
        }
    }
}

struct ApprovedItemCard: View {
    let item: ApprovalItem
    
    var statusInfo: (text: String, color: Color, icon: String) {
        switch item.status {
        case .approved:
            return ("approval.status.approved".localized(), .green, "checkmark.circle.fill")
        case .rejected:
            return ("approval.status.rejected".localized(), .red, "xmark.circle.fill")
        default:
            return ("", .gray, "")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(item.applicantName.prefix(1)))
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                        )
                    
                    VStack(alignment: .leading) {
                        Text(item.applicantName)
                            .font(.headline)
                        Text("\(getDepartmentName(item.department)) · \(item.type.localizedName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Label(statusInfo.text, systemImage: statusInfo.icon)
                    .font(.caption)
                    .foregroundColor(statusInfo.color)
            }
            
            HStack {
                Text("\("approval.approvalTime".localized()): \(item.approvalTime?.formattedDateTime() ?? "-")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var icon: String? = nil
    var color: Color = .primary
    
    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 20)
            }
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.subheadline)
            Spacer()
        }
    }
}

#Preview {
    ApprovalCenterView()
}