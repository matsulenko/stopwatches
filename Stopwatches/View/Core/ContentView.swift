//
//  ContentView.swift
//  Stopwatches
//
//  Created by Matsulenko on 31.01.2024.
//

import StoreKit
import SwiftUI

struct ContentView: View {
    @Environment(\.requestReview) var requestReview
    @AppStorage("appStartUpsCount") var appStartUpsCount = 0
    @State var startUpIsCounted = false
    
    var body: some View {
        StopwatchView()
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
                if !startUpIsCounted {
                    appStartUpsCount += 1
                    startUpIsCounted = true
                }
                
                if appStartUpsCount == 5 || appStartUpsCount % 50 == 0 {
                    requestReview()
                }
            }
            .onDisappear {
                // Re-enable the idle timer when the view disappears
                UIApplication.shared.isIdleTimerDisabled = false
            }
    }
}

#Preview {
    ContentView()
}
