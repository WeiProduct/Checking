import Foundation
import SwiftUI

@MainActor
class UserService: ObservableObject {
    @Published var currentUser: User = User(id: "user1", name: "普通用户", isAdmin: false)
    @Published var isShowingUserSwitcher = false
    
    var availableUsers: [User] {
        TestData.allAccounts.map { account in
            User(id: account.id, name: account.name, isAdmin: account.isAdmin)
        }
    }
    
    func switchUser(to user: User) {
        withAnimation {
            currentUser = user
            isShowingUserSwitcher = false
        }
    }
    
    func toggleUserSwitcher() {
        withAnimation(.spring()) {
            isShowingUserSwitcher.toggle()
        }
    }
    
    func logout() {
        // Reset to a default empty user state
        currentUser = User(id: "", name: "", isAdmin: false)
    }
}

struct User: Identifiable, Equatable {
    let id: String
    let name: String
    let isAdmin: Bool
    
    var initials: String {
        name.prefix(2).uppercased()
    }
    
    var backgroundColor: Color {
        isAdmin ? .orange : .blue
    }
}