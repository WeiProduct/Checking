import SwiftUI
import SwiftData

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var userService: UserService
    @State private var showingLogoutAlert = false
    @State private var isLoggedOut = false
    
    var body: some View {
        NavigationStack {
            Form {
                WorkTimeSection(
                    startTime: $viewModel.workStartTime,
                    endTime: $viewModel.workEndTime
                )
                
                FeatureSettingsSection(
                    enablePhoto: $viewModel.enablePhotoCheckIn,
                    enableNotifications: $viewModel.enableNotifications,
                    defaultLocation: $viewModel.defaultLocation
                )
                
                DataManagementSection(
                    onExport: viewModel.exportData,
                    onClear: { viewModel.showClearDataAlert = true }
                )
                
                if userService.currentUser.isAdmin {
                    AdminSection()
                }
                
                AboutSection()
                
                // Logout Section
                Section {
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                                .foregroundColor(.red)
                            Text("profile.logout".localized())
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("settings.title".localized())
            .onAppear {
                viewModel.setup(modelContext: modelContext)
            }
            .onChange(of: viewModel.workStartTime) { _, _ in
                viewModel.saveSettings()
            }
            .onChange(of: viewModel.workEndTime) { _, _ in
                viewModel.saveSettings()
            }
            .onChange(of: viewModel.enablePhotoCheckIn) { _, _ in
                viewModel.saveSettings()
            }
            .onChange(of: viewModel.enableNotifications) { _, _ in
                viewModel.saveSettings()
            }
            .onChange(of: viewModel.defaultLocation) { _, _ in
                viewModel.saveSettings()
            }
            .sheet(isPresented: $viewModel.showExportSheet) {
                ExportView(exportData: viewModel.generateExportData())
            }
            .alert("settings.clearData".localized(), isPresented: $viewModel.showClearDataAlert) {
                Button("common.cancel".localized(), role: .cancel) {}
                Button("common.delete".localized(), role: .destructive) {
                    viewModel.clearAllData()
                }
            } message: {
                Text("settings.clearDataWarning".localized())
            }
            .alert("profile.confirmLogout".localized(), isPresented: $showingLogoutAlert) {
                Button("common.cancel".localized(), role: .cancel) {}
                Button("profile.logout".localized(), role: .destructive) {
                    // Perform logout
                    userService.logout()
                    isLoggedOut = true
                }
            }
            .fullScreenCover(isPresented: $isLoggedOut) {
                LoginView()
                    .environmentObject(UserService())
            }
        }
    }
}

struct WorkTimeSection: View {
    @Binding var startTime: Date
    @Binding var endTime: Date
    
    var body: some View {
        Section("settings.workTime".localized()) {
            DatePicker(
                "settings.startTime".localized(),
                selection: $startTime,
                displayedComponents: .hourAndMinute
            )
            
            DatePicker(
                "settings.endTime".localized(),
                selection: $endTime,
                displayedComponents: .hourAndMinute
            )
        }
    }
}

struct FeatureSettingsSection: View {
    @Binding var enablePhoto: Bool
    @Binding var enableNotifications: Bool
    @Binding var defaultLocation: String
    
    var body: some View {
        Section("settings.features".localized()) {
            Toggle("settings.enablePhoto".localized(), isOn: $enablePhoto)
            
            Toggle("settings.enableNotifications".localized(), isOn: $enableNotifications)
            
            HStack {
                Text("settings.defaultLocation".localized())
                Spacer()
                TextField("settings.inputLocation".localized(), text: $defaultLocation)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}

struct DataManagementSection: View {
    let onExport: () -> Void
    let onClear: () -> Void
    
    var body: some View {
        Section("settings.dataManagement".localized()) {
            Button(action: onExport) {
                HStack {
                    Label("settings.exportData".localized(), systemImage: "square.and.arrow.up")
                    Spacer()
                }
            }
            
            Button(action: onClear) {
                HStack {
                    Label("settings.clearData".localized(), systemImage: "trash")
                        .foregroundColor(.red)
                    Spacer()
                }
            }
        }
    }
}

struct AdminSection: View {
    var body: some View {
        Section("settings.adminFeatures".localized()) {
            NavigationLink(destination: Text("settings.userManagement".localized())) {
                Label("settings.userManagement".localized(), systemImage: "person.3.fill")
            }
            
            NavigationLink(destination: Text("settings.systemSettings".localized())) {
                Label("settings.systemSettings".localized(), systemImage: "gearshape.2.fill")
            }
            
            NavigationLink(destination: Text("settings.auditLog".localized())) {
                Label("settings.auditLog".localized(), systemImage: "doc.text.magnifyingglass")
            }
        }
    }
}

struct AboutSection: View {
    var body: some View {
        Section("settings.about".localized()) {
            HStack {
                Text("profile.version".localized())
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("profile.developer".localized())
                Spacer()
                Text("profile.developerName".localized())
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ExportView: View {
    let exportData: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Data ready for export")
                    .font(.headline)
                    .padding()
                
                ScrollView {
                    Text(exportData)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()
                
                ShareLink(
                    item: exportData,
                    subject: Text("\("app.name".localized()) Data Export"),
                    message: Text("Attendance data export file")
                ) {
                    Label("Share Data", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("settings.exportData".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("common.ok".localized()) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [AttendanceRecord.self, UserSettings.self])
}