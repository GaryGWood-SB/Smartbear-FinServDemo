//
//  TransferView.swift
//  Smartbear FinServDemo
//
//  Created by Gary Wood.
//
import SwiftUI
import Bugsnag
import BugsnagPerformance
import BugsnagPerformanceSwift

struct TransferView: View {
    @EnvironmentObject var userProfileData: UserProfileData  // Contains the user's profile information
    @ObservedObject var accountData: AccountData             // Observes and updates account balances

    @State private var fromAccount = "Checking"              // The account selected for transferring funds from
    @State private var toAccount = "Savings"                 // The account selected for transferring funds to
    @State private var amount = ""                           // The amount the user intends to transfer
    @State private var transferMessage: String?              // Message indicating the result of the transfer attempt

    var body: some View {
        VStack {
            HeaderView() // The header component displaying the app name or logo

            Form {
                Section(header: Text("Transfer Details — Account: \(userProfileData.accountNumber)")) {
                    
                    // Selection for the account to transfer from
                    Group {
                        Text("Transfer From:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Picker("", selection: $fromAccount) {
                            Text("Checking").tag("Checking")
                            Text("Savings").tag("Savings")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(.bottom)

                    // Selection for the account to transfer to
                    Group {
                        Text("Transfer To:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Picker("", selection: $toAccount) {
                            Text("Checking").tag("Checking")
                            Text("Savings").tag("Savings")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    // Input field for the transfer amount
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad) // Numeric keyboard for amount entry
                }

                // Button to initiate the transfer
                Button("Transfer") {
                    handleTransfer() // Call the function to handle the transfer
                }

                // Display the result of the transfer attempt
                if let message = transferMessage {
                    Text(message) // Show the success or error message
                        .foregroundColor(message.contains("success") ? .green : .red) // Color based on the outcome
                        .padding()
                }
            }
        }
        .navigationTitle("Transfer") // Title of the navigation bar
        .onAppear { transferMessage = nil } // Reset the message when the view appears
        .bugsnagTraced("Transfer View") // Trace performance metrics with Bugsnag
    }

    // Function to validate and execute the transfer
    func handleTransfer() {
        guard let transferAmount = Double(amount), transferAmount > 0 else {
            transferMessage = "Invalid transfer amount" // Error message for invalid input
            return
        }

        // Check for valid cents formatting (e.g., "10.00", not "10.0" or "10")
        if !amount.contains(".") || amount.split(separator: ".").last?.count != 2 {
            Bugsnag.leaveBreadcrumb(withMessage: "Invalid cent format")
            let _ = ["Crash: improper cent format"][99] // Unhandled exception for demo
        }

        do {
            // Attempt to perform the transfer between the selected accounts
            try accountData.transfer(fromAccount: fromAccount, toAccount: toAccount, amount: transferAmount)
            transferMessage = "Transfer successful!" // Success message
        } catch {
            // Capture and display the error message, and notify Bugsnag
            transferMessage = error.localizedDescription // Capture error message
            Bugsnag.notifyError(error) // Notify Bugsnag of the error
        }
    }
}
