import SwiftUI

struct TestAccountsListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab selector
                Picker("", selection: $selectedTab) {
                    Text("Admin Accounts (5)").tag(0)
                    Text("Worker Accounts (10)").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if selectedTab == 0 {
                            // Admin accounts
                            ForEach(TestData.adminAccounts, id: \.id) { account in
                                AccountCard(account: account)
                            }
                        } else {
                            // Worker accounts
                            ForEach(TestData.workerAccounts, id: \.id) { account in
                                AccountCard(account: account)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Test Accounts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AccountCard: View {
    let account: TestAccount
    @State private var showingCopied = false
    
    var departmentName: String {
        switch account.department {
        case "TechDept": return "技术部"
        case "MarketDept": return "市场部"
        case "AdminDept": return "行政部"
        case "FinanceDept": return "财务部"
        case "HRDept": return "人事部"
        default: return account.department
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Avatar
                Circle()
                    .fill(account.isAdmin ? Color.orange.gradient : Color.blue.gradient)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(account.name.prefix(1)))
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(account.name)
                        .font(.headline)
                    HStack {
                        Text(departmentName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if let position = account.position {
                            Text("·")
                                .foregroundColor(.secondary)
                            Text(position)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                if account.isAdmin {
                    Text("ADMIN")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.orange)
                        .cornerRadius(4)
                }
            }
            
            Divider()
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Account")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(account.id)
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.medium)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Password")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(account.password)
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Button(action: {
                    copyToClipboard()
                }) {
                    Image(systemName: showingCopied ? "checkmark" : "doc.on.doc")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = "\(account.id) / \(account.password)"
        
        withAnimation {
            showingCopied = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showingCopied = false
            }
        }
    }
}

#Preview {
    TestAccountsListView()
}