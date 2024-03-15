//
//  DefaultButton.swift
//  Stopwatches
//
//  Created by Matsulenko on 05.02.2024.
//

import SwiftUI

struct DefaultButton: ButtonStyle {
    var backgroundColor: Color?
    var textColor: Color?
    var width: CGFloat = 100
    
    func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(minWidth: width, minHeight: 50)
                .background(backgroundColor ?? .yellow)
                .foregroundStyle(textColor ?? .black)
                .font(.title3)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .scaleEffect(configuration.isPressed ? 1.2 : 1)
                .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
