import Foundation
import SwiftUI

// Centralized test data structure for consistent testing
struct TestData {
    
    // Admin accounts: admin001-admin005
    static let adminAccounts = [
        TestAccount(id: "admin001", password: "admin001p", name: "Admin Zhang", isAdmin: true, department: "AdminDept"),
        TestAccount(id: "admin002", password: "admin002p", name: "Admin Li", isAdmin: true, department: "HRDept"),
        TestAccount(id: "admin003", password: "admin003p", name: "Admin Wang", isAdmin: true, department: "FinanceDept"),
        TestAccount(id: "admin004", password: "admin004p", name: "Admin Chen", isAdmin: true, department: "TechDept"),
        TestAccount(id: "admin005", password: "admin005p", name: "Admin Liu", isAdmin: true, department: "MarketDept")
    ]
    
    // Worker accounts: worker001-worker010
    static let workerAccounts = [
        TestAccount(id: "worker001", password: "worker001p", name: "Wang Xiaoming", isAdmin: false, department: "TechDept", position: "Frontend Engineer"),
        TestAccount(id: "worker002", password: "worker002p", name: "Li Xiaohong", isAdmin: false, department: "MarketDept", position: "Marketing Manager"),
        TestAccount(id: "worker003", password: "worker003p", name: "Zhang Wei", isAdmin: false, department: "TechDept", position: "Backend Engineer"),
        TestAccount(id: "worker004", password: "worker004p", name: "Liu Qiang", isAdmin: false, department: "FinanceDept", position: "Finance Analyst"),
        TestAccount(id: "worker005", password: "worker005p", name: "Chen Mei", isAdmin: false, department: "AdminDept", position: "Admin Assistant"),
        TestAccount(id: "worker006", password: "worker006p", name: "Yang Hua", isAdmin: false, department: "TechDept", position: "iOS Developer"),
        TestAccount(id: "worker007", password: "worker007p", name: "Zhao Lei", isAdmin: false, department: "MarketDept", position: "Marketing Specialist"),
        TestAccount(id: "worker008", password: "worker008p", name: "Sun Yu", isAdmin: false, department: "HRDept", position: "HR Specialist"),
        TestAccount(id: "worker009", password: "worker009p", name: "Zhou Ming", isAdmin: false, department: "FinanceDept", position: "Senior Accountant"),
        TestAccount(id: "worker010", password: "worker010p", name: "Wu Jing", isAdmin: false, department: "TechDept", position: "Tech Lead")
    ]
    
    // All accounts combined
    static var allAccounts: [TestAccount] {
        adminAccounts + workerAccounts
    }
    
    // Get employees for Employee model
    static var employees: [Employee] {
        allAccounts.map { account in
            Employee(
                name: account.name,
                employeeId: account.id.uppercased(), // Display as uppercase
                department: account.department,
                position: account.position ?? (account.isAdmin ? "Administrator" : "Employee"),
                hasFaceData: Bool.random(), // Random for testing
                avatarColor: getColorForDepartment(account.department)
            )
        }
    }
    
    // Get department statistics
    static var departmentStats: [String: Int] {
        var stats: [String: Int] = [:]
        for account in allAccounts {
            stats[account.department, default: 0] += 1
        }
        return stats
    }
    
    // Helper function to get color for department
    static func getColorForDepartment(_ dept: String) -> Color {
        switch dept {
        case "TechDept": return .blue
        case "MarketDept": return .orange
        case "AdminDept": return .green
        case "FinanceDept": return .purple
        case "HRDept": return .pink
        default: return .gray
        }
    }
    
    // Validate login credentials
    static func validateLogin(id: String, password: String) -> TestAccount? {
        allAccounts.first { account in
            account.id.lowercased() == id.lowercased() && account.password == password
        }
    }
}

// Test account structure
struct TestAccount {
    let id: String
    let password: String
    let name: String
    let isAdmin: Bool
    let department: String
    let position: String?
    
    init(id: String, password: String, name: String, isAdmin: Bool, department: String, position: String? = nil) {
        self.id = id
        self.password = password
        self.name = name
        self.isAdmin = isAdmin
        self.department = department
        self.position = position
    }
}