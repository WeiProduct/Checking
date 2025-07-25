import SwiftUI

struct LeaveApplicationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var leaveType = LeaveType.personal
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var reason = ""
    @State private var selectedApprover = "Manager Zhang"
    @State private var showingDatePicker = false
    @State private var datePickerMode: DatePickerMode = .start
    @State private var showingSubmitAlert = false
    
    enum LeaveType: String, CaseIterable {
        case personal = "personal"
        case sick = "sick"
        case annual = "annual"
        case compensatory = "compensatory"
        
        @MainActor
        var localizedName: String {
            switch self {
            case .personal: return "leave.personal".localized()
            case .sick: return "leave.sick".localized()
            case .annual: return "leave.annual".localized()
            case .compensatory: return "leave.compensatory".localized()
            }
        }
        
        var icon: String {
            switch self {
            case .personal: return "person.fill"
            case .sick: return "cross.case.fill"
            case .annual: return "calendar.badge.plus"
            case .compensatory: return "clock.arrow.2.circlepath"
            }
        }
        
        var color: Color {
            switch self {
            case .personal: return .blue
            case .sick: return .red
            case .annual: return .green
            case .compensatory: return .orange
            }
        }
    }
    
    enum DatePickerMode {
        case start, end
    }
    
    var leaveDuration: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour], from: startDate, to: endDate)
        let days = components.day ?? 0
        let hours = components.hour ?? 0
        
        if days > 0 {
            return "\(days) days \(hours) hours"
        } else {
            return "\(hours) hours"
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Leave Information") {
                    
                    Picker("leave.type".localized(), selection: $leaveType) {
                        ForEach(LeaveType.allCases, id: \.self) { type in
                            Label(type.localizedName, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    
                    HStack {
                        Label("leave.startTime".localized(), systemImage: "calendar")
                        Spacer()
                        Text(startDate.formattedDateTime())
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        datePickerMode = .start
                        showingDatePicker = true
                    }
                    
                    
                    HStack {
                        Label("leave.endTime".localized(), systemImage: "calendar.badge.clock")
                        Spacer()
                        Text(endDate.formattedDateTime())
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        datePickerMode = .end
                        showingDatePicker = true
                    }
                    
                    
                    HStack {
                        Label("leave.duration".localized(), systemImage: "timer")
                        Spacer()
                        Text(leaveDuration)
                            .fontWeight(.medium)
                            .foregroundColor(leaveType.color)
                    }
                }
                
                Section("leave.reason".localized()) {
                    TextEditor(text: $reason)
                        .frame(minHeight: 100)
                        .overlay(
                            Group {
                                if reason.isEmpty {
                                    Text("leave.reasonPlaceholder".localized())
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )
                }
                
                Section("leave.approver".localized()) {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                            .foregroundColor(.blue)
                        Text(selectedApprover)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Section {
                    Button(action: submitApplication) {
                        HStack {
                            Spacer()
                            Label("leave.submit".localized(), systemImage: "paperplane.fill")
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                    .disabled(reason.isEmpty)
                }
            }
            .navigationTitle("leave.title".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("common.cancel".localized()) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                LeaveDatePickerSheet(
                    selectedDate: datePickerMode == .start ? $startDate : $endDate,
                    title: datePickerMode == .start ? "Select Start Time" : "Select End Time"
                )
            }
            .alert("leave.submitSuccess".localized(), isPresented: $showingSubmitAlert) {
                Button("leave.confirm".localized()) {
                    dismiss()
                }
            } message: {
                Text("leave.submitSuccessDesc".localized())
            }
        }
    }
    
    private func submitApplication() {
        
        showingSubmitAlert = true
    }
}

struct LeaveDatePickerSheet: View {
    @Binding var selectedDate: Date
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            DatePicker(
                "Select Time",
                selection: $selectedDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .padding()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("common.cancel".localized()) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("common.confirm".localized()) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    LeaveApplicationView()
}