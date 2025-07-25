import SwiftUI

struct EmployeeManagementView: View {
    @State private var searchText = ""
    @State private var selectedDepartment = "All"
    @State private var showingAddEmployee = false
    @State private var employees: [Employee] = Employee.sampleData
    
    let departments = ["All", "TechDept", "MarketDept", "AdminDept", "FinanceDept", "HRDept"]
    
    var localizedDepartments: [String] {
        departments.map { dept in
            switch dept {
            case "All": return "common.all".localized()
            case "TechDept": return "dashboard.techDept".localized()
            case "MarketDept": return "dashboard.marketDept".localized()
            case "AdminDept": return "dashboard.adminDept".localized()
            case "FinanceDept": return "dashboard.financeDept".localized()
            case "HRDept": return "dashboard.hrDept".localized()
            default: return dept
            }
        }
    }
    
    var filteredEmployees: [Employee] {
        employees.filter { employee in
            let matchesSearch = searchText.isEmpty || 
                employee.name.localizedCaseInsensitiveContains(searchText) ||
                employee.employeeId.localizedCaseInsensitiveContains(searchText)
            
            let matchesDepartment = selectedDepartment == "All" || 
                employee.department == selectedDepartment
            
            return matchesSearch && matchesDepartment
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                VStack(spacing: 12) {
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("employee.search".localized(), text: $searchText)
                        }
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        
                        Menu {
                            ForEach(Array(zip(departments, localizedDepartments)), id: \.0) { dept, localizedDept in
                                Button(localizedDept) {
                                    selectedDepartment = dept
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                Text(localizedDepartments[departments.firstIndex(of: selectedDepartment) ?? 0])
                                    .font(.caption)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    
                    HStack {
                        Text(String(format: "employee.total".localized(), filteredEmployees.count))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .padding()
                
                Divider()
                
                
                if filteredEmployees.isEmpty {
                    ContentUnavailableView(
                        "employee.notFound".localized(),
                        systemImage: "person.slash",
                        description: Text("employee.adjustSearch".localized())
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 1) {
                            ForEach(filteredEmployees) { employee in
                                EmployeeRow(employee: employee)
                                    .background(Color(UIColor.systemBackground))
                            }
                        }
                        .background(Color.gray.opacity(0.1))
                    }
                }
            }
            .navigationTitle("employee.title".localized())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddEmployee = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEmployee) {
                AddEmployeeView()
            }
        }
    }
}

struct Employee: Identifiable {
    let id = UUID()
    let name: String
    let employeeId: String
    let department: String
    let position: String
    let hasFaceData: Bool
    let avatarColor: Color
    
    var initials: String {
        String(name.prefix(1))
    }
    
    static let sampleData = TestData.employees
}

struct EmployeeRow: View {
    let employee: Employee
    @State private var showingActions = false
    
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
    
    var body: some View {
        HStack(spacing: 12) {
            
            ZStack {
                Circle()
                    .fill(employee.avatarColor.gradient)
                    .frame(width: 50, height: 50)
                
                Text(employee.initials)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            
            
            VStack(alignment: .leading, spacing: 4) {
                Text(employee.name)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    Text(getDepartmentName(employee.department))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("·")
                        .foregroundColor(.secondary)
                    
                    Text(employee.employeeId)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(employee.position)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            
            HStack(spacing: 16) {
                Button(action: {}) {
                    Image(systemName: employee.hasFaceData ? "face.smiling.fill" : "face.smiling")
                        .foregroundColor(employee.hasFaceData ? .green : .gray)
                }
                
                Button(action: { showingActions = true }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .actionSheet(isPresented: $showingActions) {
            ActionSheet(
                title: Text("\(employee.name) - \(employee.employeeId)"),
                buttons: [
                    .default(Text("employee.edit".localized())) {},
                    .default(Text("employee.viewRecords".localized())) {},
                    .default(Text("employee.resetPassword".localized())) {},
                    .destructive(Text("employee.delete".localized())) {},
                    .cancel()
                ]
            )
        }
    }
}

struct AddEmployeeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var employeeId = ""
    @State private var department = "TechDept"
    @State private var position = ""
    
    let departments = ["TechDept", "MarketDept", "AdminDept", "FinanceDept", "HRDept"]
    
    var localizedDepartments: [String] {
        departments.map { dept in
            switch dept {
            case "TechDept": return "dashboard.techDept".localized()
            case "MarketDept": return "dashboard.marketDept".localized()
            case "AdminDept": return "dashboard.adminDept".localized()
            case "FinanceDept": return "dashboard.financeDept".localized()
            case "HRDept": return "dashboard.hrDept".localized()
            default: return dept
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("employee.basicInfo".localized()) {
                    TextField("employee.name".localized(), text: $name)
                    TextField("employee.id".localized(), text: $employeeId)
                    
                    Picker("employee.department".localized(), selection: $department) {
                        ForEach(Array(zip(departments, localizedDepartments)), id: \.0) { dept, localizedDept in
                            Text(localizedDept).tag(dept)
                        }
                    }
                    
                    TextField("employee.position".localized(), text: $position)
                }
                
                Section("employee.accountSettings".localized()) {
                    HStack {
                        Text("employee.initialPassword".localized())
                        Spacer()
                        Text("123456")
                            .foregroundColor(.secondary)
                    }
                    
                    Toggle("employee.sendWelcomeEmail".localized(), isOn: .constant(true))
                }
            }
            .navigationTitle("employee.add".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("common.cancel".localized()) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("employee.save".localized()) {
                        
                        dismiss()
                    }
                    .disabled(name.isEmpty || employeeId.isEmpty || position.isEmpty)
                }
            }
        }
    }
}

#Preview {
    EmployeeManagementView()
}