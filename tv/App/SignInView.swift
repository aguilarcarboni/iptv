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
            // Background pattern
            DotPattern(
                backgroundColor: Color("Background"),
                dotColor: Color("Subtitle"),
                opacity: 0.3,
                spacing: 20
            )
            
            ScrollView {
                VStack {
                    // Header area with additional top padding
                    VStack(spacing: 20) {
                        Text("TV App")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color("AccentColor"))
                            .padding(.top, 100) // Increased top padding
                        
                        Text("Welcome back")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("Foreground"))
                    }
                    .padding(.bottom, 40)
                    
                    // Main form inside a card-like container
                    VStack {
                        Text("Sign In")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(Color("Foreground"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Enter your credentials to continue")
                            .font(.subheadline)
                            .foregroundColor(Color("Subtitle"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 20)
                        
                        VStack(spacing: 20) {
                            CustomInput(
                                value: $serverUrl,
                                label: "Server URL",
                                iconName: "server.rack"
                            )
                            
                            CustomInput(
                                value: $username,
                                label: "Username",
                                iconName: "person"
                            )
                            
                            // For password, create consistent styling with other inputs
                            VStack(alignment: .leading) {
                                Text("Password")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .padding(.bottom, 2)
                                    .foregroundColor(Color("Foreground"))

                                SecureField("", text: $password)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .foregroundColor(Color("Foreground"))
                                    .background(Color("Muted"))
                                    .cornerRadius(7)
                                    .textFieldStyle(PlainTextFieldStyle())
                            }
                            
                            // Sign in button
                            CustomButton(
                                action: {
                                    withAnimation {
                                        isLoading = true
                                        // Add a small delay to show the loading state
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            saveCredentials()
                                            isLoading = false
                                        }
                                    }
                                },
                                label: isLoading ? "Loading..." : "Sign In"
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 22)
                    .background(Color("Background"))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
                    .padding(.horizontal, 40)
                    
                    // Footer area with improved spacing
                    Spacer(minLength: 60)
                    Text("Version 1.0")
                        .font(.caption)
                        .foregroundColor(Color("Subtitle"))
                        .padding(.bottom, 40) // Increased bottom padding
                }
                .padding()
            }
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
