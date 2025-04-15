//
//  ProfileView.swift
//  Smartbear FinServDemo
//
//  Created by Gary Wood.
//
// User Profile View
import SwiftUI
import Bugsnag
import BugsnagPerformance
import BugsnagPerformanceSwift

class UserProfileData: ObservableObject {
    // Shared user profile data observed across views
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var accountNumber: String = ""
}

struct UserProfile: Identifiable, Hashable {
    // Represents a selectable user profile for demo
    let id = UUID()
    let name: String
    let email: String
    let accountNumber: String
}

struct ProfileView: View {
    @EnvironmentObject var userProfileData: UserProfileData // Access shared user profile
    @State private var users = [
        UserProfile(name: "John Doe", email: "john.doe@example.com", accountNumber: "A1B2C"),
        UserProfile(name: "Jane Smith", email: "jane.smith@example.com", accountNumber: "D3E4F"),
        UserProfile(name: "Sam Johnson", email: "sam.johnson@example.com", accountNumber: "G5H6I"),
        UserProfile(name: "Lisa Ray", email: "lisa.ray@example.com", accountNumber: "J7K8L"),
        UserProfile(name: "Alex Kim", email: "alex.kim@example.com", accountNumber: "M9N0O")
    ] // Predefined user list for quick selection
    @State private var selectedUser: UserProfile? = UserProfile(name: "John Doe", email: "john.doe@example.com", accountNumber: "A1B2C") // Currently selected profile

    var body: some View {
        VStack {
            HeaderView() // Reusable app header

            Form {
                Section(header: Text("User Info")) {
                    // Picker to load predefined profiles or enter custom
                    Picker("Select User", selection: $selectedUser) {
                        Text("Custom").tag(UserProfile?.none)
                        ForEach(users) { user in
                            Text(user.name).tag(Optional(user))
                        }
                    }
                    // Update shared user profile data when selection changes
                    .onChange(of: selectedUser) { newValue in
                        if let user = newValue {
                            userProfileData.name = user.name
                            userProfileData.email = user.email
                            userProfileData.accountNumber = user.accountNumber
                        } else {
                            // Reset for manual entry
                            userProfileData.name = ""
                            userProfileData.email = ""
                            userProfileData.accountNumber = ""
                        }
                    }
                    .onAppear {
                        if let user = selectedUser {
                            userProfileData.name = user.name
                            userProfileData.email = user.email
                            userProfileData.accountNumber = user.accountNumber
                        }
                    }

                    // Editable fields tied to shared profile state
                    TextField("Name", text: $userProfileData.name)
                    TextField("Email", text: $userProfileData.email)
                    TextField("Account Number", text: $userProfileData.accountNumber)
                }

                // Button to simulate saving the profile info
                Button("Save Changes") {
                    saveProfileChanges()
                }
            }
        }
        .navigationTitle("Profile") // Screen title
        .bugsnagTraced("Profile View") // Performance tracing with Bugsnag
    }

    // Simulated save logic with error tracking
    func saveProfileChanges() {
        do {
            // Check for valid user profile information before saving
            if userProfileData.name.isEmpty || userProfileData.email.isEmpty || userProfileData.accountNumber.isEmpty {
                throw NSError(domain: "ProfileError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Invalid profile information"])
            }
        } catch {
            // Notify Bugsnag of any errors that occur during save
            Bugsnag.notifyError(error)
        }
    }
}
