import SwiftUI
import SwiftData

struct ProfileView: View {
    @EnvironmentObject var userService: UserService
    @Environment(\.modelContext) private var modelContext
    @State private var showingLogoutAlert = false
    @State private var isLoggedOut = false
    @ObservedObject private var languageService = LanguageService.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    UserInfoCard(user: userService.currentUser)
                    
                    
                    VStack(spacing: 1) {
                        ProfileMenuItem(
                            icon: "person.crop.circle",
                            title: "profile.personalInfo".localized(),
                            color: .blue
                        ) {
                            
                        }
                        
                        ProfileMenuItem(
                            icon: "face.smiling",
                            title: "profile.faceManagement".localized(),
                            color: .green
                        ) {
                            
                        }
                        
                        ProfileMenuItem(
                            icon: "bell",
                            title: "profile.notifications".localized(),
                            color: .orange,
                            badge: 3
                        ) {
                            
                        }
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    
                    VStack(spacing: 1) {
                        NavigationLink {
                            LeaveApplicationView()
                        } label: {
                            ProfileMenuItem(
                                icon: "calendar.badge.plus",
                                title: "profile.leaveApplication".localized(),
                                color: .purple
                            ) {
                                
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink {
                            MakeupApplicationView()
                        } label: {
                            ProfileMenuItem(
                                icon: "clock.badge.exclamationmark",
                                title: "profile.makeupApplication".localized(),
                                color: .pink
                            ) {
                                
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        ProfileMenuItem(
                            icon: "doc.text",
                            title: "profile.myApplications".localized(),
                            color: .indigo
                        ) {
                            
                        }
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    
                    VStack(spacing: 1) {
                        
                        HStack {
                            Image(systemName: "globe")
                                .font(.title3)
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            Text("Language / 语言")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Picker("", selection: $languageService.currentLanguage) {
                                Text("中文").tag(Language.chinese)
                                Text("English").tag(Language.english)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 150)
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        
                        ProfileMenuItem(
                            icon: "gearshape",
                            title: "settings.title".localized(),
                            color: .gray
                        ) {
                            
                        }
                        
                        ProfileMenuItem(
                            icon: "questionmark.circle",
                            title: "profile.help".localized(),
                            color: .teal
                        ) {
                            
                        }
                        
                        ProfileMenuItem(
                            icon: "arrow.right.square",
                            title: "profile.logout".localized(),
                            color: .red,
                            showArrow: false
                        ) {
                            showingLogoutAlert = true
                        }
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("profile.title".localized())
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

struct UserInfoCard: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 16) {
            
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [user.backgroundColor, user.backgroundColor.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                
                if user.isAdmin {
                    Image(systemName: "crown.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                } else {
                    Text(user.initials)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 4)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            
            VStack(spacing: 8) {
                Text(user.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack {
                    Label(user.isAdmin ? "attendance.admin".localized() : "attendance.employee".localized(), systemImage: user.isAdmin ? "crown" : "person")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("·")
                        .foregroundColor(.secondary)
                    
                    Text("dashboard.techDept".localized())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text("\("employee.id".localized()): \(user.id.uppercased())")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let color: Color
    var badge: Int? = nil
    var showArrow: Bool = true
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let badge = badge {
                    Text("\(badge)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                
                if showArrow {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserService())
}