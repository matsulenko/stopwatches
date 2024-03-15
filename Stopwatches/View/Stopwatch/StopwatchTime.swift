//
//  StopwatchTime.swift
//  Stopwatches
//
//  Created by Matsulenko on 05.02.2024.
//

import SwiftUI

struct StopwatchTime: View {
    @Binding var isCompact: Bool
    @Binding var progressTime: Double
    
    var dividerValue: CGFloat {
        switch progressTime {
        case 3600..<36000: 6
        case 36000...: 7
        default: 5
        }
    }
    var hours: String {
        let timeValue = Int(progressTime) / 3600
        return addZeros(timeValue: timeValue, timeValueType: .hr)
    }

    var minutes: String {
        let timeValue = (Int(progressTime) % 3600) / 60
        return addZeros(timeValue: timeValue, timeValueType: .min)
    }

    var seconds: String {
        let timeValue = Int(progressTime) % 60
        return addZeros(timeValue: timeValue, timeValueType: .sec)
    }
    
    var miliseconds: String {
        let timeValue = Int(progressTime * 1000) - Int(progressTime)*1000
        return addZeros(timeValue: timeValue, timeValueType: .ms)
    }
    
    var body: some View {
        let currentTime = hours + minutes + seconds + miliseconds
        if isCompact {
            HStack {
                Text(currentTime)
                    .font(.title2)
                    .lineLimit(0)
                Spacer()
            }
        } else {
            GeometryReader { proxy in
                HStack {
                    Text(currentTime)
                        .font(.system(size: proxy.size.width/dividerValue))
                        .minimumScaleFactor(0.1)
                        .foregroundStyle(.primary)
                        .lineLimit(0)
                    Spacer()
                }
            }
        }
    }
    
    private func addZeros(timeValue: Int, timeValueType: TimeValueType) -> String {
        let delimiter: String = {
            if timeValueType == .sec {
                return "."
            } else {
                return ":"
            }
        }()
        if timeValueType == .ms {
            if timeValue < 10 {
                return "00" + String(timeValue)
            } else if timeValue < 100 {
                return "0" + String(timeValue)
            } else {
                return String(timeValue)
            }
        } else if timeValueType == .hr {
            if timeValue == 0 {
                return ""
            } else {
                return String(timeValue) + delimiter
            }
        } else {
            if timeValue < 10 {
                return "0" + String(timeValue) + delimiter
            } else {
                return String(timeValue) + delimiter
            }
        }
    }
}

enum TimeValueType {
    case hr, min, sec, ms
}

#Preview {
    StopwatchTime(isCompact: .constant(true), progressTime: .constant(0))
}
