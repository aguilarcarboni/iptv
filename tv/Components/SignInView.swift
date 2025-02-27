import SwiftUI
import SwiftData

struct SignInView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var credentials: [Credential]
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var serverUrl: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            
            VStack {
                Spacer()
                
                // Sign-in form
                VStack(spacing: 24) {
                    
                    Text("Welcome back to your TV")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    
                    // Server URL field
                    HStack {
                        Image(systemName: "server.rack")
                            .foregroundColor(.foreground)
                            .frame(width: 24)
                        
                        TextField("Server URL", text: $serverUrl)
                            .disableAutocorrection(true)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(.muted)
                    .cornerRadius(12)
                    
                    // Username field
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.foreground)
                            .frame(width: 24)
                        
                        TextField("Username", text: $username)
                            .disableAutocorrection(true)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(.muted)
                    .cornerRadius(12)
                    
                    // Password field
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.foreground)
                            .frame(width: 24)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(.muted)
                    .cornerRadius(12)
                    
                    // Sign in button
                    Button(action: {
                        withAnimation {
                            isLoading = true
                            
                            // Add a small delay to show the loading state
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                saveCredentials()
                                isLoading = false
                            }
                        }
                    }) {
                        ZStack {
                            if isLoading {
                                Text("Loading...")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: 250)
                            } else {
                                Text("Sign In")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: 250)
                            }
                        }
                    }
                    .background(.accent)
                    .cornerRadius(12)
                    .disabled(isLoading)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Additional info / footer
                Text("Version 1.0")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom)
                
            }
            .padding()
        }
        .alert("Sign In", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveCredentials() {
        guard !serverUrl.isEmpty, !username.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill in all fields"
            showAlert = true
            return
        }
        
        let credential = Credential(serverUrl: serverUrl, username: username, password: password)
        modelContext.insert(credential)
        
        // Clear the form
        serverUrl = ""
        username = ""
        password = ""
        
        alertMessage = "Credentials saved successfully!"
        showAlert = true
    }
}

#Preview {
    SignInView()
}
