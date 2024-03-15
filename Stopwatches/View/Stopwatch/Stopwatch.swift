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
    var startAllIsHidden: ((Bool) -> Void)?
    var nameString: String {
        if stopWatchUnit.name != "" {
            stopWatchUnit.name
        } else {
            String(localized: "Stopwatch") + " " + String(stopWatchUnit.num)
        }
    }
    
    var body: some View {
        
        VStack {
            if isCompact == false {
                VStack {
                    HStack {
                        Text(nameString)
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
                        if isCompact {
                            Image(systemName: "arrow.clockwise")
                        } else {
                            Text(leftButtonText())
                        }
                    })
                .buttonStyle(
                    DefaultButton(
                            backgroundColor: leftButtonBgColor(),
                            textColor: leftButtonTextColor(),
                            width: isCompact ? 50 : 100
                        )
                    
                )
                
                if isCompact {
                    Spacer()
                    VStack {
                        HStack {
                            Text(nameString)
                                .multilineTextAlignment(.leading)
                            Spacer()
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
                        if isCompact {
                            Image(systemName: stopWatchUnit.status == .active ? "pause.fill" : "play.fill")
                        } else {
                            Text(rightButtonText())
                        }
                    })
                .buttonStyle(
                    DefaultButton(
                        backgroundColor: rightButtonBgColor(),
                        textColor: rightButtonTextColor(),
                        width: isCompact ? 50 : 100
                    )
                )
            }
            .frame(minHeight: 60)
            .alert("Enter your stopwatch name", isPresented: $alertShowing) {
                TextField("Stopwatch name", text: $stopWatchUnit.name)
                    .foregroundStyle(Color.text)
                    .background(Color.background)
                Button("OK", role: .cancel) {
                    saveStopwatch()
                }
            }
            
        }
        .onChange(of: stopWatchUnit.status) { _ in
            setLeftButtonType()
            saveStopwatch()
        }
        .onChange(of: stopWatchUnit.startAll) { _ in
            if stopWatchUnit.startAll == true {
                rightButtonTapped()
                stopWatchUnit.startAll = false
            }
        }
        .onChange(of: alertShowing) { _ in
            startAllIsHidden?(alertShowing)
        }
        .onAppear {
            switch stopWatchUnit.status {
            case .new:
                stopWatchUnit.status = .zero
                progressTime = currentProgress()
                currentDate = Date()
                saveStopwatch()
            case .zero, .paused:
                progressTime = currentProgress()
                if progressTime > 0 {
                    currentDate = Date()
                }
            case .active:
                currentDate = Date()
                if stopWatchUnit.startDate == nil {
                    stopWatchUnit.startDate = Date()
                }
                timer = Timer.scheduledTimer(withTimeInterval: 0.021, repeats: true, block: { _ in
                    currentDate = Date()
                    progressTime = currentProgress()
                })
            case .deleted:
                currentDate = Date()
            }
            setLeftButtonType()
        }
        .onChange(of: isCompact) { _ in
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
        if isCompact {
            resetStopwatch()
        } else if leftButtonType == .name {
            setName()
        } else if leftButtonType == .reset {
            resetStopwatch()
            leftButtonType = .name
        }
    }
    
    private func setLeftButtonType() {
        if isCompact {
            leftButtonType = .reset
        } else {
            if stopWatchUnit.status == .paused {
                leftButtonType = .reset
            } else {
                leftButtonType = .name
            }
        }
    }
    
    private func setName() {
        alertShowing.toggle()
    }
    
    private func resetStopwatch() {
        stopWatchUnit.status = .zero
        stopWatchUnit.startDate = nil
        currentDate = nil
        stopWatchUnit.accumulatedTime = 0
        progressTime = 0
        saveStopwatch()
    }
    
    private func rightButtonTapped() {
        changeStatus()
        if stopWatchUnit.status == .active {
            stopWatchUnit.status = .paused
        } else {
            stopWatchUnit.status = .active
        }
    }
    
    private func changeStatus() {
        if stopWatchUnit.status == .active {
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
        if stopWatchUnit.status == .active {
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
        if stopWatchUnit.status == .active {
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
        if stopWatchUnit.status == .active {
            Color.white
        } else {
            Color.black
        }
    }
    
    private func rightButtonBgColor() -> Color {
        if stopWatchUnit.status == .active {
            Color.red
        } else {
            Color.green
        }
    }
}

#Preview {
    Stopwatch(stopWatchUnit: .constant(StopwatchData(
        id: UUID().uuidString,
        status: .zero,
        name: "",
        accumulatedTime: 0,
        creationDate: Date(),
        num: 1
    )), isCompact: .constant(true))
}
