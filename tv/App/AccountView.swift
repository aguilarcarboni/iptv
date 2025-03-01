import SwiftUI
import SwiftData

struct AccountView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var credentials: [Credential]
    
    @State private var isEditingProfile = false
    @State private var displayName = "Andres"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile header
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.accent)
                            .frame(width: 100, height: 100)
                        
                        Text(String(displayName.prefix(1)))
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 10)
                    
                    if isEditingProfile {
                        TextField("Display Name", text: $displayName)
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal)
                        
                        Button("Save") {
                            isEditingProfile = false
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(Color.accent)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    } else {
                        Text(displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Button("Edit Profile") {
                            isEditingProfile = true
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(.muted)
                        .buttonStyle(PlainButtonStyle())
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.05))
                )
                .padding(.horizontal)
                                
                // Server credentials
                VStack(alignment: .leading, spacing: 15) {
                    Text("Server Credentials")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if let credential = credentials.first {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Server URL:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text(credential.serverUrl)
                                    .foregroundColor(.gray)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Username:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text(credential.username)
                                    .foregroundColor(.gray)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Password:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("••••••••")
                                    .foregroundColor(.gray)
                            }
                            
                            Button("Edit Credentials") {
                                // Edit credentials action
                            }
                            .frame(maxWidth: 200)
                            .padding(.vertical, 10)
                            .background(.accent)
                            .foregroundColor(.white)
                            .buttonStyle(PlainButtonStyle())
                            .cornerRadius(8)
                            .padding(.top, 10)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.05))
                        )
                        .padding(.horizontal)
                    } else {
                        Button("Add Server Credentials") {
                            // Add credentials action
                        }
                        .frame(maxWidth: 200)
                        .padding(.vertical, 15)
                        .background(.accent)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                    }
                }
                
                Button(action: {
                    // Sign out action
                }) {
                    Text("Sign Out")
                        .fontWeight(.bold)
                        .frame(maxWidth: 200)
                        .padding(.vertical, 15)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    NavigationStack {
        AccountView()
    }
}
