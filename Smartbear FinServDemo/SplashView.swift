//
//  SplashView.swift
//  Smartbear FinServDemo
//
//  Created by Gary Wood.
//
// Splash Page
import SwiftUI
import Bugsnag
import BugsnagPerformance
import BugsnagPerformanceSwift

struct SplashView: View {
    // Track whether the splash screen should transition to the main app
    @State private var isActive = false
    @State private var isAnimating = false

    var body: some View {
        if isActive {
            // Navigate to the main content once splash is done
            MainView()
        } else {
            VStack {
                // SmartBear logo
                Image("Smartbear-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.tint)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .shadow(color: .orange.opacity(0.7), radius: isAnimating ? 20 : 5)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)

                // App title
                Text("Smartbear Financial Services")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding()

                // Tagline powered by Insight Hub
                Text("Powered by Insight Hub")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)

                // Decorative image representing multi-hub architecture
                Image("hubs_multi-loop")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        maxWidth: UIScreen.main.bounds.width * 0.8,  // 80% of screen width
                        maxHeight: UIScreen.main.bounds.height * 0.4  // 40% of screen height
                    )
                    .padding()
                    .foregroundStyle(.tint)
            }
            .bugsnagTraced("Splash View") // Trace splash screen load duration
            .onAppear {
                isAnimating = true
                let baseDelay: Double = 3.0
                var extraDelay: Double = 0.0
                // Introduce delays for older devices for performance demo
                if let modelCode = UIDevice.current.modelIdentifier {
                    switch modelCode {
                    case let code where code.hasPrefix("iPhone10"): // iPhone 8
                        extraDelay = 1.5
                    case let code where code.hasPrefix("iPhone11"): // iPhone XR, XS, XS Max
                        extraDelay = 1.2
                    case let code where code.hasPrefix("iPhone12"): // iPhone 11 series
                        extraDelay = 1.0
                    case let code where code.hasPrefix("iPhone13"): // iPhone 12 series
                        extraDelay = 0.8
                    case let code where code.hasPrefix("iPhone14"): // iPhone 13 series
                        extraDelay = 0.6
                    default:
                        extraDelay = 0.0
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + baseDelay + extraDelay) {
                    isActive = true
                }
            }
        }
    }

    // Alternative manual method for navigating to main view via window root change
    func navigateToMain() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UIHostingController(rootView: MainView())
            window.makeKeyAndVisible()
        }
    }
}

import Foundation

extension UIDevice {
    var modelIdentifier: String? {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0)
            }
        }
    }
}
