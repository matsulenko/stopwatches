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
            .onAppear{
                if !startUpIsCounted {
                    appStartUpsCount += 1
                    startUpIsCounted = true
                }
                
                if appStartUpsCount == 5 || appStartUpsCount % 50 == 0 {
                    requestReview()
                }
            }
    }
}

#Preview {
    ContentView()
}
