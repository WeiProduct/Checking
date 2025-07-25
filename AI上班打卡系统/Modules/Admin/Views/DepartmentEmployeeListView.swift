import SwiftUI

struct DepartmentEmployeeListView: View {
    let department: String
    @Environment(\.dismiss) private var dismiss
    
    var departmentEmployees: [Employee] {
        TestData.employees.filter { $0.department == department }
    }
    
    var departmentName: String {
        switch department {
        case "TechDept": return "dashboard.techDept".localized()
        case "MarketDept": return "dashboard.marketDept".localized()
        case "AdminDept": return "dashboard.adminDept".localized()
        case "FinanceDept": return "dashboard.financeDept".localized()
        case "HRDept": return "dashboard.hrDept".localized()
        default: return department
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(departmentEmployees) { employee in
                    HStack(spacing: 12) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(employee.avatarColor.gradient)
                                .frame(width: 50, height: 50)
                            
                            Text(employee.initials)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        
                        // Employee Info
                        VStack(alignment: .leading, spacing: 4) {
                            Text(employee.name)
                                .font(.headline)
                            
                            Text(employee.position)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text(employee.employeeId)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                if employee.hasFaceData {
                                    Image(systemName: "face.smiling.fill")
                                        .font(.caption2)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Account Info
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Account")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(employee.employeeId.lowercased())
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(departmentName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("common.close".localized()) {
                        dismiss()
                    }
                }
            }
            .overlay {
                if departmentEmployees.isEmpty {
                    ContentUnavailableView(
                        "No Employees",
                        systemImage: "person.slash",
                        description: Text("No employees in this department")
                    )
                }
            }
        }
    }
}

#Preview {
    DepartmentEmployeeListView(department: "TechDept")
}