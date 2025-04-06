import SwiftUI
import SwiftData

struct AccountView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var credentials: [Credential]
    
    @State private var isEditingProfile = false
    @State private var displayName = "Andres"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {

                VStack(alignment: .leading, spacing: 22) {
                    Text("Server Credentials")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    if let credential = credentials.first {
                        VStack(spacing: 16) {
                            credentialRow(label: "Server URL", value: credential.serverUrl)
                            
                            Divider()
                                .background(Color.gray.opacity(0.2))
                            
                            credentialRow(label: "Username", value: credential.username)
                            
                            Divider()
                                .background(Color.gray.opacity(0.2))
                            
                            credentialRow(label: "Password", value: "••••••••")
                            
                            HStack(spacing: 12) {
                                Button(action: {
                                    // Edit credentials action
                                }) {
                                    Text("Edit Credentials")
                                        .foregroundColor(.white)
                                        .padding(.vertical, 12)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.red)
                                        .cornerRadius(10)
                                }
                                .buttonStyle(.plain)
                                
                                Button(action: {
                                    // Sign out action
                                }) {
                                    Text("Sign Out")
                                        .foregroundColor(.white)
                                        .padding(.vertical, 12)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.red)
                                        .cornerRadius(10)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.top, 8)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        
                    } else {
                        Button(action: {
                            // Add credentials action
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.headline)
                                Text("Add Server Credentials")
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(Color.accent)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer(minLength: 50)
            }
            .padding(.vertical)
        }
        .background(Color.black.opacity(0.03).ignoresSafeArea())
    }
    
    @ViewBuilder
    private func credentialRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    NavigationStack {
        AccountView()
    }
}
