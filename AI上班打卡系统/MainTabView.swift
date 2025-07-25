import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var userService: UserService
    @ObservedObject private var languageService = LanguageService.shared
    
    var body: some View {
        if userService.currentUser.isAdmin {
            
            AdminTabView(selectedTab: $selectedTab)
        } else {
            
            EmployeeTabView(selectedTab: $selectedTab)
        }
    }
}

struct EmployeeTabView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        TabView(selection: $selectedTab) {
            AttendanceView()
                .tabItem {
                    Label("tab.attendance".localized(), systemImage: "clock.fill")
                }
                .tag(0)
            
            RecordsView()
                .tabItem {
                    Label("tab.records".localized(), systemImage: "clock.arrow.circlepath")
                }
                .tag(1)
            
            StatisticsView()
                .tabItem {
                    Label("tab.statistics".localized(), systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("tab.profile".localized(), systemImage: "person.fill")
                }
                .tag(3)
        }
    }
}

struct AdminTabView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        TabView(selection: $selectedTab) {
            AdminDashboardView()
                .tabItem {
                    Label("tab.dashboard".localized(), systemImage: "gauge.with.dots.needle.33percent")
                }
                .tag(0)
            
            EmployeeManagementView()
                .tabItem {
                    Label("tab.employees".localized(), systemImage: "person.3.fill")
                }
                .tag(1)
            
            ApprovalCenterView()
                .tabItem {
                    Label("tab.approval".localized(), systemImage: "checkmark.seal.fill")
                }
                .tag(2)
            
            AIChatView()
                .tabItem {
                    Label("tab.aiChat".localized(), systemImage: "message.fill")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("tab.settings".localized(), systemImage: "gearshape.fill")
                }
                .tag(4)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(UserService())
}