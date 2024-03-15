//
//  StartAllButton.swift
//  Stopwatches
//
//  Created by Matsulenko on 05.02.2024.
//

import SwiftUI

struct StartAllButton: View {
    @State var allStarted: Bool
    var buttonTapped: (() -> Void)?
    
    var body: some View {
        VStack {
            Spacer()
            Button(
                action: {
                    buttonTapped?()
                    allStarted.toggle()
                },
                label: {
                    Text(allStarted ? "Stop all" : "Start all")
                })
            .buttonStyle(
                DefaultButton(
                    backgroundColor: allStarted ? Color.red : nil, 
                    textColor: allStarted ? Color.white : nil, 
                    width: 150
                )
            )
        }
        .padding()
    }
}

#Preview {
    StartAllButton(allStarted: false)
}
