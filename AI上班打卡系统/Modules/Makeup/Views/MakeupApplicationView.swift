import SwiftUI

struct MakeupApplicationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var selectedDate = Date()
    @State private var makeupType = MakeupType.checkIn
    @State private var makeupTime = Date()
    @State private var reason = ""
    @State private var showingDatePicker = false
    @State private var showingTimePicker = false
    @State private var showingSubmitAlert = false
    
    enum MakeupType: String, CaseIterable {
        case checkIn = "上班补卡"
        case checkOut = "下班补卡"
        case both = "全天补卡"
        
        var icon: String {
            switch self {
            case .checkIn: return "sunrise.fill"
            case .checkOut: return "sunset.fill"
            case .both: return "clock.badge.exclamationmark.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .checkIn: return .orange
            case .checkOut: return .purple
            case .both: return .red
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("补卡信息") {
                    
                    HStack {
                        Label("补卡日期", systemImage: "calendar")
                        Spacer()
                        Text(selectedDate.formattedDate())
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showingDatePicker = true
                    }
                    
                    
                    Picker("补卡类型", selection: $makeupType) {
                        ForEach(MakeupType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    
                    if makeupType != .both {
                        HStack {
                            Label("补卡时间", systemImage: "clock.fill")
                            Spacer()
                            Text(makeupTime.formattedTime())
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showingTimePicker = true
                        }
                    }
                }
                
                Section("补卡原因") {
                    VStack(alignment: .leading) {
                        Menu {
                            Button("系统故障") {
                                reason = "系统故障，无法正常打卡"
                            }
                            Button("忘记打卡") {
                                reason = "忘记打卡"
                            }
                            Button("网络问题") {
                                reason = "网络连接问题，打卡失败"
                            }
                            Button("其他") {
                                reason = ""
                            }
                        } label: {
                            HStack {
                                Text("快速选择")
                                    .foregroundColor(.blue)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        TextEditor(text: $reason)
                            .frame(minHeight: 100)
                            .overlay(
                                Group {
                                    if reason.isEmpty {
                                        Text("请输入补卡原因...")
                                            .foregroundColor(.gray.opacity(0.5))
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 8)
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }
                }
                
                Section("证明材料") {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.blue)
                            Text("添加照片证明（可选）")
                                .foregroundColor(.primary)
                            Spacer()
                        }
                    }
                }
                
                Section {
                    Button(action: submitApplication) {
                        HStack {
                            Spacer()
                            Label("提交申请", systemImage: "paperplane.fill")
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                    .disabled(reason.isEmpty)
                }
            }
            .navigationTitle("补卡申请")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                DateSelectionSheet(selectedDate: $selectedDate)
            }
            .sheet(isPresented: $showingTimePicker) {
                TimeSelectionSheet(selectedTime: $makeupTime)
            }
            .alert("提交成功", isPresented: $showingSubmitAlert) {
                Button("确定") {
                    dismiss()
                }
            } message: {
                Text("您的补卡申请已提交，请等待审批")
            }
        }
    }
    
    private func submitApplication() {
        
        showingSubmitAlert = true
    }
}

struct DateSelectionSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            DatePicker(
                "选择日期",
                selection: $selectedDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .padding()
            .navigationTitle("选择补卡日期")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("确定") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TimeSelectionSheet: View {
    @Binding var selectedTime: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            DatePicker(
                "选择时间",
                selection: $selectedTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .padding()
            .navigationTitle("选择补卡时间")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("确定") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    MakeupApplicationView()
}