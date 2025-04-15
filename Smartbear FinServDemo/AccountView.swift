//
//  AccountView.swift
//  Smartbear FinServDemo
//
//  Created by Gary Wood.
//
import SwiftUI
import Bugsnag
import BugsnagPerformance
import BugsnagPerformanceSwift

struct AccountView: View {
    // Access shared user profile data (e.g., account number)
    @EnvironmentObject var userProfileData: UserProfileData // Provides access to user profile data throughout the view

    // Observe live account balance updates
    @ObservedObject var accountData: AccountData // Observes account data for changes in balance

    var body: some View {
        VStack(spacing: 20) {
            HeaderView() // Custom reusable header UI
            Spacer()
            // Display the current account number with label
            Text("Account " + userProfileData.accountNumber + " Balances") // User-facing label for account balances
                .font(.headline)
            
            // Section showing checking account balance
            VStack {
                Text("Checking Account") // User-facing label for checking account section
                    .font(.subheadline)
                    .padding(.top, 5)
                Text("$\(String(format: "%.2f", accountData.checkingBalance))") // Displays formatted checking account balance
                    .font(.largeTitle)
                    .padding()
            }
            .background(Color.gray.opacity(0.1)) // Background styling for checking account section
            .cornerRadius(10)
            .padding()

            // Section showing savings account balance
            VStack {
                Text("Savings Account") // User-facing label for savings account section
                    .font(.subheadline)
                    .padding(.top, 5)
                Text("$\(String(format: "%.2f", accountData.savingsBalance))") // Displays formatted savings account balance
                    .font(.largeTitle)
                    .padding()
            }
            .background(Color.gray.opacity(0.1)) // Background styling for savings account section
            .cornerRadius(10)
            .padding()
            .bugsnagTraced("Account View") // Trace this view for performance monitoring and analytics
            Spacer()
            
        }
        .navigationTitle("Accounts") // Set navigation title for this screen
    }
}
