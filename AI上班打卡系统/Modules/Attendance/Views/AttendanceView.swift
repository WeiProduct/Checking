import SwiftUI
import SwiftData

struct AttendanceView: View {
    @StateObject private var viewModel = AttendanceViewModel()
    @StateObject private var locationService = LocationService()
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var userService: UserService
    @State private var showCheckInAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                
                CurrentUserBadge(user: userService.currentUser)
                    .padding(.top, 10)
                ClockView(currentTime: viewModel.currentTime)
                
                LocationInfoView(location: locationService.currentLocation)
                
                CheckInButton(
                    isCheckedIn: viewModel.isCheckedIn,
                    action: handleCheckInOut
                )
                
                if let record = viewModel.todayRecord {
                    TodayRecordView(record: record)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("attendance.title".localized())
            .sheet(isPresented: $viewModel.showAICamera) {
                PhotoCameraView { screenshot in
                    performCheckIn(withPhoto: true, screenshot: screenshot)
                    viewModel.showAICamera = false
                }
                .onDisappear {
                    viewModel.showAICamera = false
                }
            }
            .alert("attendance.selectMethod".localized(), isPresented: $showCheckInAlert) {
                Button("attendance.normalCheckIn".localized()) {
                    performCheckIn(withPhoto: false)
                }
                Button("attendance.photoCheckIn".localized()) {
                    viewModel.toggleAICamera()
                }
                Button("attendance.cancel".localized(), role: .cancel) {}
            }
            .onAppear {
                viewModel.setup(modelContext: modelContext)
                locationService.requestLocationPermission()
            }
        }
    }
    
    private func handleCheckInOut() {
        if viewModel.isCheckedIn {
            viewModel.checkOut()
        } else {
            showCheckInAlert = true
        }
    }
    
    private func performCheckIn(withPhoto: Bool, screenshot: Data? = nil) {
        viewModel.checkIn(
            location: locationService.currentLocation,
            withPhoto: withPhoto,
            screenshot: screenshot
        )
    }
}

struct ClockView: View {
    let currentTime: Date
    
    var body: some View {
        VStack {
            Text(currentTime.formattedTime())
                .font(.system(size: 60, weight: .thin, design: .rounded))
            Text(currentTime.formattedDate())
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct LocationInfoView: View {
    let location: String
    
    var body: some View {
        HStack {
            Image(systemName: "location.fill")
                .foregroundColor(.blue)
            Text(location)
                .font(.headline)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(20)
    }
}

struct CheckInButton: View {
    let isCheckedIn: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isCheckedIn ? Color.red : Color.green)
                    .frame(width: 200, height: 200)
                
                VStack {
                    Image(systemName: isCheckedIn ? "clock.badge.checkmark.fill" : "clock.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                    Text(isCheckedIn ? "attendance.checkOut".localized() : "attendance.checkIn".localized())
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: isCheckedIn)
    }
}

struct TodayRecordView: View {
    let record: AttendanceRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("attendance.workTime".localized(), systemImage: "sunrise.fill")
                    .foregroundColor(.orange)
                Spacer()
                Text(record.checkInTime.formattedTime())
                    .fontWeight(.medium)
            }
            
            if let checkOutTime = record.checkOutTime {
                HStack {
                    Label("attendance.offTime".localized(), systemImage: "sunset.fill")
                        .foregroundColor(.purple)
                    Spacer()
                    Text(checkOutTime.formattedTime())
                        .fontWeight(.medium)
                }
                
                HStack {
                    Label("attendance.workDuration".localized(), systemImage: "timer")
                        .foregroundColor(.blue)
                    Spacer()
                    Text(calculateWorkDuration())
                        .fontWeight(.medium)
                }
            }
            
            if record.withPhoto {
                HStack {
                    Label("attendance.photoVerified".localized(), systemImage: "camera.fill")
                        .foregroundColor(.blue)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(15)
    }
    
    private func calculateWorkDuration() -> String {
        guard let checkOutTime = record.checkOutTime else { return "In Progress" }
        let duration = checkOutTime.timeIntervalSince(record.checkInTime)
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

struct CurrentUserBadge: View {
    let user: User
    
    var body: some View {
        HStack {
            Image(systemName: user.isAdmin ? "crown.fill" : "person.fill")
                .font(.caption)
                .foregroundColor(user.backgroundColor)
            
            Text("\("attendance.currentUser".localized()): \(user.name)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(user.isAdmin ? "(\("attendance.admin".localized()))" : "(\("attendance.employee".localized()))")
                .font(.caption2)
                .foregroundColor(user.backgroundColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(20)
    }
}

#Preview {
    AttendanceView()
        .modelContainer(for: [AttendanceRecord.self, UserSettings.self])
        .environmentObject(UserService())
}