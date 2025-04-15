//
//  PaymentsView.swift
//  Smartbear FinServDemo
//
//  Created by Gary Wood.
//
import SwiftUI
import Bugsnag
import BugsnagPerformance
import BugsnagPerformanceSwift

struct PaymentsView: View {
    @EnvironmentObject var userProfileData: UserProfileData
    @ObservedObject var accountData: AccountData
    @State private var recipient = ""
    @State private var paymentAmount = ""
    @State private var fromAccount = "Checking"
    @State private var paymentMessage: String?
    @State private var selectedCurrency = "USD"
    @State private var convertedAmount: Double?
    let supportedCurrencies = ["USD", "EUR", "CAD"]
    
    // Dictionary to hold vendor names and their corresponding webhook URLs
    let vendorEndpoints: [String: String] = [
        "Acme Utilities": "https://webhook.site/700e0e01-159a-4e70-9350-653e90485850",
        "TechCorp Internet": "https://webhook.site/700e0e01-159a-4e70-9350-653e90485850",
        "Metro Mobile": "https://webhook.site/700e0e01-159a-4e70-9350-653e90485850",
        "NextGen Cable": "https://webhook.site/700e0e01-159a-4e70-9350-653e90485850",
        "EcoPower Grid": "https://webhook.site/700e0e01-159a-4e70-9350-653e90485850",
        "SwiftClean Services": "https://webhook.site/700e0e01-159a-4e70-9350-653e90485850"
    ]
    @State private var selectedVendor = "Acme Utilities"

    var body: some View {
        VStack {
            HeaderView() // Custom header view
            Form {
                // Section displaying user's account number
                Section(header: Text("Account " + userProfileData.accountNumber)) {
                    //Text("Account Number: \(userProfileData.accountNumber)")
                }
                // Section for entering payment details
                Section(header: Text("Payment Details")) {
                    
                    // Picker for selecting the vendor
                    Picker("Vendor", selection: $selectedVendor) {
                        ForEach(Array(vendorEndpoints.keys), id: \.self) { vendor in
                            Text(vendor)
                        }
                    }
                    .onChange(of: selectedVendor) { newValue in
                        recipient = newValue // Update recipient when vendor changes
                    }
                    // TextField for entering the payment amount
                    TextField("Amount (\(selectedCurrency))", text: $paymentAmount)
                        .keyboardType(.decimalPad)
                    
                    // Picker for selecting the account to make the payment from
                    Picker("From Account", selection: $fromAccount) {
                        Text("Checking").tag("Checking")
                        Text("Savings").tag("Savings")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // Picker for selecting the currency
                    Picker("Currency", selection: $selectedCurrency) {
                        ForEach(supportedCurrencies, id: \.self) { currency in
                            Text(currency)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // Display converted amount if applicable
                    if let converted = convertedAmount, selectedCurrency != "USD" {
                        Text("Converted Amount: $\(String(format: "%.2f", converted)) USD")
                            .foregroundColor(.blue)
                    }
                }

                // Button to send the payment
                Button("Send Payment") {
                    sendPayment()
                }

                // Display message after payment attempt
                if let message = paymentMessage {
                    Text(message)
                        .foregroundColor(message.contains("success") ? .green : .red)
                        .padding()
                }
            }
        }
        .navigationTitle("Payments") // Set navigation title
        .onAppear {paymentMessage = nil} // Reset message on appear
        .onChange(of: paymentAmount) { _ in updateConvertedAmount() } // Update conversion on amount change
        .onChange(of: selectedCurrency) { _ in updateConvertedAmount() } // Update conversion on currency change
        .bugsnagTraced("Payments View") // Trace this view for Bugsnag
    }

    // Function to send the payment
    func sendPayment() {
        // Flag this flow for Bugsnag to distinguish payments using conversion
        Bugsnag.addFeatureFlag(name: "Convert USD")

        // Validate and parse the entered amount
        guard let paymentAmountValue = Double(paymentAmount), paymentAmountValue > 0 else {
            paymentMessage = "Invalid payment amount" // Show error if amount is invalid
            return
        }

        // Convert the amount to USD if needed, then proceed with payment
        convertToUSD(amount: paymentAmountValue, currency: selectedCurrency) { usdAmount in
            DispatchQueue.main.async {
                // Store the converted amount for UI feedback
                convertedAmount = usdAmount
                do {
                    // Deduct the (converted) amount from the selected account
                    try accountData.makePayment(fromAccount: fromAccount, amount: usdAmount)

                    // Show a success message and send payment details to the selected vendor
                    //paymentMessage = "Payment successful!"
                    paymentMessage = "Payment of \(String(format: "%.2f", paymentAmountValue)) \(selectedCurrency) to \(selectedVendor) was successful!"
                    sendToVendor(name: selectedVendor, amount: paymentAmountValue, recipient: recipient)
                } catch {
                    // Show the error message and log to Bugsnag
                    paymentMessage = error.localizedDescription
                    Bugsnag.notifyError(error)
                }
            }
        }
    }
    
    // Function to convert the amount to USD
    func convertToUSD(amount: Double, currency: String, completion: @escaping (Double) -> Void) {
        
        let span = BugsnagPerformance.startSpan(name: "Currency Conversion") // Start performance span
        span.setAttribute("Currency", withValue: currency) // Set currency attribute
        span.setAttribute("Account", withValue: fromAccount) // Set account attribute
        span.setAttribute("Amount", withValue: amount) // Set amount attribute
        if currency == "USD" {
            print("No conversion needed for USD.")
            span.end()
            completion(amount) // No conversion needed, return the same amount
            return
        }
        
        // URL for the currency conversion API
        let urlStr = "https://api.frankfurter.app/latest?amount=\(amount)&from=\(currency)&to=USD"
        guard let url = URL(string: urlStr) else {
            print("Invalid URL: \(urlStr)")
            completion(amount) // If URL is invalid, return the same amount
            return
        }
        
        let randomDelay = Double.random(in: 0.5...1.25) // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                defer { span.end() } // End span after the request completes
                if let data = data {
                    do {
                        // Parse the JSON response
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let rates = json["rates"] as? [String: Double],
                           let result = rates["USD"] {
                            print("Frankfurter API result: \(result)")
                            completion(result) // Return the converted amount
                            return
                        } else {
                            print("Frankfurter response parsing failed or missing USD rate.")
                        }
                    } catch {
                        print("Error parsing Frankfurter JSON: \(error)")
                    }
                } else if let error = error {
                    print("Frankfurter API error: \(error.localizedDescription)")
                } else {
                    print("Frankfurter API call failed for unknown reasons.")
                }
                completion(amount) // If there was an error, return the original amount
            }.resume()
        }
        //span.end()
    }

    // Function to update the converted amount based on the payment amount and selected currency
    func updateConvertedAmount() {
        guard let value = Double(paymentAmount), value > 0 else {
            convertedAmount = nil // Reset if the payment amount is invalid
            return
        }

        convertToUSD(amount: value, currency: selectedCurrency) { usdAmount in
            DispatchQueue.main.async {
                convertedAmount = usdAmount // Update converted amount
            }
        }
    }
    
    // Function to send payment details to the selected vendor
    func sendToVendor(name: String, amount: Double, recipient: String) {
        guard let urlString = vendorEndpoints[name], let url = URL(string: urlString) else {
            print("Invalid vendor URL") // Log if the vendor URL is invalid
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Set the request method to POST
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Set content type

        // Create the request body with payment details
        let body: [String: Any] = [
            "vendor": name,
            "recipient": recipient,
            "amount": amount,
            "currency": selectedCurrency
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body) // Serialize body to JSON

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Vendor POST error: \(error.localizedDescription)") // Log any errors
            } else {
                print("Payment sent to \(name)") // Log success
            }
        }.resume()
    }
}
