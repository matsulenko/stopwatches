//
//  CustomDivider.swift
//  Stopwatches
//
//  Created by Matsulenko on 05.02.2024.
//

import SwiftUI

struct CustomDivider: View {
    var color: Color = .accentColor
    let width: CGFloat = 1
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(gradient: Gradient(colors: [Color.text, Color.accentColor, Color.accentColor, Color.accentColor, Color.text]), startPoint: .leading, endPoint: .trailing))
            .frame(height: width)
            .edgesIgnoringSafeArea(.horizontal)
    }
}

#Preview {
    CustomDivider()
}
