//
//  MainView.swift
//  Smartbear FinServDemo
//
//  Created by Gary Wood.
//
// Main View with Tab Bar
import SwiftUI
import Bugsnag
import BugsnagPerformance
import BugsnagPerformanceSwift

struct MainView: View {
    // Shared data for account balances and transfers/payments
    @StateObject var accountData = AccountData()
    
    // Shared user profile data across views
    @StateObject var userProfileData = UserProfileData()
    
    var body: some View {
        TabView {
            // Tab for viewing account balances
            AccountView(accountData: accountData)
                .environmentObject(userProfileData)
                .tabItem {
                    Label("Account", systemImage: "creditcard")
                }

            // Tab for viewing and editing user profile
            ProfileView()
                .environmentObject(userProfileData)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }

            // Tab for transferring money between accounts
            TransferView(accountData: accountData)
                .environmentObject(userProfileData)
                .tabItem {
                    Label("Transfer", systemImage: "arrow.right.arrow.left")
                }

            // Tab for sending payments
            PaymentsView(accountData: accountData)
                .environmentObject(userProfileData)
                .tabItem {
                    Label("Payments", systemImage: "dollarsign.circle")
                }
        }
    }
}
class AccountData: ObservableObject {
    @Published var checkingBalance: Double = 2000.00
    @Published var savingsBalance: Double = 5000.00
    @Published var accountNumber: String = "ABCDE"

    func transfer(fromAccount: String, toAccount: String, amount: Double) throws {
        let span = BugsnagPerformance.startSpan(name: "transfer Function")
        span.setAttribute("AccountNumber", withValue: accountNumber)
        span.setAttribute("From", withValue: fromAccount)
        span.setAttribute("To", withValue: toAccount)
        span.setAttribute("Amount", withValue: amount)
        
        // Validate transfer amount is positive
        guard amount > 0 else {
            throw NSError(domain: "TransferError", code: 1006, userInfo: [NSLocalizedDescriptionKey: "Invalid transfer amount"])
        }
        
        // Handle transfer from checking to savings
        if fromAccount.lowercased() == "checking" && toAccount.lowercased() == "savings" {
            guard checkingBalance >= amount else {
                throw NSError(domain: "TransferError", code: 1007, userInfo: [NSLocalizedDescriptionKey: "Insufficient balance in checking"])
            }
            checkingBalance -= amount
            savingsBalance += amount
        }
        // Handle transfer from savings to checking
        else if fromAccount.lowercased() == "savings" && toAccount.lowercased() == "checking" {
            guard savingsBalance >= amount else {
                throw NSError(domain: "TransferError", code: 1008, userInfo: [NSLocalizedDescriptionKey: "Insufficient balance in savings"])
            }
            savingsBalance -= amount
            checkingBalance += amount
        }
        // Handle invalid account selection
        else {
            throw NSError(domain: "TransferError", code: 1009, userInfo: [NSLocalizedDescriptionKey: "Invalid account selection"])
        }
        span.end()
    }

    func makePayment(fromAccount: String, amount: Double) throws {
        let span = BugsnagPerformance.startSpan(name: "makePayment Function")
        span.setAttribute("AccountNumber", withValue: accountNumber)
        span.setAttribute("Account", withValue: fromAccount)
        span.setAttribute("Amount", withValue: amount)
        
        // Validate payment amount is positive
        guard amount > 0 else {
           throw NSError(domain: "PaymentError", code: 2010, userInfo: [NSLocalizedDescriptionKey: "Invalid payment amount"])
        }

        // Handle payment from checking account
        if fromAccount.lowercased() == "checking" {
            guard checkingBalance >= amount else {
                throw NSError(domain: "PaymentError", code: 2011, userInfo: [NSLocalizedDescriptionKey: "Insufficient balance in checking"])
            }
            checkingBalance -= amount
        } 
        // Handle payment from savings account
        else if fromAccount.lowercased() == "savings" {
            guard savingsBalance >= amount else {
                throw NSError(domain: "PaymentError", code: 2012, userInfo: [NSLocalizedDescriptionKey: "Insufficient balance in savings"])
            }
            savingsBalance -= amount
        }
        // Handle invalid account selection
        else {
            throw NSError(domain: "PaymentError", code: 2013, userInfo: [NSLocalizedDescriptionKey: "Invalid account selection"])
        }
        span.end()
    }
}
