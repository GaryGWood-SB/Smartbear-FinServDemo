// Smartbear FinServDemo iOS App
// Demo for Insight Hub (formerly known as Bugsnag)

import SwiftUI
import Bugsnag
import BugsnagPerformance
import BugsnagPerformanceSwift


@main
struct SmartbearFinServDemoApp: App {
    init() {
        // Initialize Bugsnag
        Bugsnag.start()
        BugsnagPerformance.start()
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}
// Reusable Header View
struct HeaderView: View {
    var body: some View {
        VStack {
            Image("Smartbear-logo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 50)
                .padding(.top, 10)
            Text("Smartbear")
                .font(.headline)
                .padding(.bottom, 10)
        }
    }
}
