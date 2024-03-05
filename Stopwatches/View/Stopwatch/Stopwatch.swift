//
//  Stopwatch.swift
//  Stopwatches
//
//  Created by Matsulenko on 05.02.2024.
//

import CoreData
import SwiftUI

enum LeftButtonStopwatch: String {
    case name
    case reset
}

struct Stopwatch: View {
    
    @Binding public var stopWatchUnit: StopwatchData
    @State private var timer: Timer?
    @State private var currentDate: Date?
    @State var progressTime: Double = 0
    @State var leftButtonType: LeftButtonStopwatch = .name
    @State private var alertShowing = false
    @Binding var isCompact: Bool
    var statusChanged: (() -> Void)?
        
    var body: some View {
        
        VStack {
            if isCompact == false {
                VStack {
                    HStack {
                        Text(stopWatchUnit.name)
                            .font(.headline)
                        Spacer()
                    }
                    StopwatchTime(isCompact: $isCompact, progressTime: $progressTime)
                        .frame(height: 100)
                }
            }
            
            HStack {
                Button(
                    action: {
                        leftButtonAction()
                    },
                    label: {
                        Text(leftButtonText())
                            .alert("Enter your stopwatch name", isPresented: $alertShowing) {
                                TextField("Stopwatch name", text: $stopWatchUnit.name)
                                    .foregroundStyle(Color.text)
                                    .background(Color.background)
                                Button("OK") {
                                    alertShowing.toggle()
                                    saveStopwatch()
                                }
                            }
                    })
                .buttonStyle(
                    DefaultButton(
                        backgroundColor: leftButtonBgColor(),
                        textColor: leftButtonTextColor()
                    )
                )
                
                if isCompact {
                    Spacer()
                    VStack {
                        if stopWatchUnit.name != "" {
                            HStack {
                                Text(stopWatchUnit.name)
                                    .lineLimit(1)
                                Spacer()
                            }
                        }
                        StopwatchTime(isCompact: $isCompact, progressTime: $progressTime)
                    }
                }
                
                Spacer()
                
                Button(
                    action: {
                        rightButtonTapped()
                    },
                    label: {
                        Text(rightButtonText())
                    })
                .buttonStyle(
                    DefaultButton(
                        backgroundColor: rightButtonBgColor(),
                        textColor: rightButtonTextColor()
                    )
                )
            }
            .frame(height: 60)
            
        }
        .onChange(of: stopWatchUnit.isRunning) { _ in
            setLeftButtonType()
            saveStopwatch()
            statusChanged?()
        }
        .onChange(of: stopWatchUnit.startAll) { _ in
            if stopWatchUnit.startAll == true {
                rightButtonTapped()
                stopWatchUnit.startAll = false
            }
        }
        .onAppear {
            if stopWatchUnit.isRunning {
                currentDate = Date()
                if stopWatchUnit.startDate == nil {
                    stopWatchUnit.startDate = Date()
                }
                timer = Timer.scheduledTimer(withTimeInterval: 0.021, repeats: true, block: { _ in
                    currentDate = Date()
                    progressTime = currentProgress()
                })
            } else {
                progressTime = currentProgress()
                if progressTime > 0 {
                    currentDate = Date()
                }
            }
            setLeftButtonType()
        }
    }
    
    private func saveStopwatch() {
        CoreDataServiceSW.shared.saveSW(stopwatch: stopWatchUnit) { result in
            if result != .success(true) {
                print("Saving was failed")
            }
        }
    }
    
    private func leftButtonAction() {
        if leftButtonType == .name {
            setName()
        } else if leftButtonType == .reset {
            resetStopwatch()
            leftButtonType = .name
        }
    }
    
    private func setLeftButtonType() {
        if stopWatchUnit.isRunning || currentDate == nil {
            leftButtonType = .name
        } else {
            leftButtonType = .reset
        }
    }
    
    private func setName() {
        alertShowing.toggle()
    }
    
    private func resetStopwatch() {
        stopWatchUnit.startDate = nil
        currentDate = nil
        stopWatchUnit.accumulatedTime = 0
        progressTime = 0
    }
    
    private func rightButtonTapped() {
        changeStatus()
        stopWatchUnit.isRunning.toggle()
    }
    
    private func changeStatus() {
        if stopWatchUnit.isRunning {
            timer?.invalidate()
            currentDate = Date()
            progressTime = currentProgress()
            stopWatchUnit.accumulatedTime = progressTime
        } else {
            currentDate = Date()
            stopWatchUnit.startDate = Date()
            timer = Timer.scheduledTimer(withTimeInterval: 0.021, repeats: true, block: { _ in
                currentDate = Date()
                progressTime = currentProgress()
            })
        }
    }
    
    private func currentProgress() -> Double {
        if stopWatchUnit.isRunning {
            if currentDate != nil {
                return currentDate!.timeIntervalSince(stopWatchUnit.startDate!) + stopWatchUnit.accumulatedTime
            } else {
                return 0
            }
        } else {
            if stopWatchUnit.startDate != nil {
                return stopWatchUnit.accumulatedTime
            } else {
                return 0
            }
        }
    }
    
    private func leftButtonText() -> String {
        if leftButtonType == .name {
            String(localized: "Name")
        } else {
            String(localized: "Reset")
        }
    }
    
    private func rightButtonText() -> String {
        if stopWatchUnit.isRunning {
            String(localized: "Stop")
        } else {
            String(localized: "Start")
        }
    }
    
    private func leftButtonTextColor() -> Color {
        Color.white
    }
    
    private func leftButtonBgColor() -> Color {
        Color.gray
    }
    
    private func rightButtonTextColor() -> Color {
        if stopWatchUnit.isRunning {
            Color.white
        } else {
            Color.black
        }
    }
    
    private func rightButtonBgColor() -> Color {
        if stopWatchUnit.isRunning {
            Color.red
        } else {
            Color.green
        }
    }
}

#Preview {
    Stopwatch(stopWatchUnit: .constant(StopwatchData(
        id: UUID().uuidString,
        isRunning: false,
        name: "",
        accumulatedTime: 0,
        creationDate: Date()
    )), isCompact: .constant(false))
}
