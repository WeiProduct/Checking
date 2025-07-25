import SwiftUI

struct FloatingUserSwitcher: View {
    @ObservedObject var userService: UserService
    @State private var dragOffset = CGSize.zero
    @State private var position = CGPoint(x: UIScreen.main.bounds.width - 70, y: 200)
    @State private var isDragging = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            FloatingButton(user: userService.currentUser, isDragging: isDragging) {
                userService.toggleUserSwitcher()
            }
            .position(position)
            .offset(dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        withAnimation(.spring()) {
                            position.x += value.translation.width
                            position.y += value.translation.height
                            dragOffset = .zero
                            isDragging = false
                            
                            
                            let bounds = UIScreen.main.bounds
                            position.x = min(max(50, position.x), bounds.width - 50)
                            position.y = min(max(100, position.y), bounds.height - 100)
                        }
                    }
            )
            
            
            if userService.isShowingUserSwitcher {
                UserSelectionPanel(userService: userService)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

struct FloatingButton: View {
    let user: User
    let isDragging: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(user.backgroundColor)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: 60, height: 60)
                
                VStack(spacing: 2) {
                    Image(systemName: user.isAdmin ? "crown.fill" : "person.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                    
                    Text(user.initials)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        .scaleEffect(isDragging ? 1.2 : 1.0)
        .opacity(isDragging ? 0.8 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: user.id)
    }
}

struct UserSelectionPanel: View {
    @ObservedObject var userService: UserService
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            
            HStack {
                Text("Switch Account")
                    .font(.headline)
                Spacer()
                Button(action: {
                    userService.toggleUserSwitcher()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            Divider()
            
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(userService.availableUsers) { user in
                        UserRow(
                            user: user,
                            isSelected: user.id == userService.currentUser.id
                        ) {
                            userService.switchUser(to: user)
                        }
                    }
                }
                .padding()
            }
            .frame(maxHeight: 400)
        }
        .frame(width: 300)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 20)
        .padding(.top, 150)
    }
}

struct UserRow: View {
    let user: User
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                
                ZStack {
                    Circle()
                        .fill(user.backgroundColor)
                        .frame(width: 40, height: 40)
                    
                    if user.isAdmin {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    } else {
                        Text(user.initials)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text(user.id)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("·")
                            .foregroundColor(.secondary)
                        Text(user.isAdmin ? "Admin" : "Employee")
                            .font(.caption)
                            .foregroundColor(user.isAdmin ? .orange : .blue)
                    }
                }
                
                Spacer()
                
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}