//
//  CustomButton.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/20/24.
//

import SwiftUI

struct CustomButton: View {
    let title: String
    let backgroundColor: Color
    let foregroundColor: Color
    let borderColor: Color?
    let icon: Image?
    let action: () async -> Void
    let width: CGFloat?
    let height: CGFloat?
    
    @State private var isLoading = false
    
    init(
        title: String,
        backgroundColor: Color? = nil,
        foregroundColor: Color? = nil,
        borderColor: Color? = nil,
        icon: Image? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        action: @escaping () async -> Void
    ) {
        self.title = title
        self.backgroundColor = backgroundColor ?? .blue
        self.foregroundColor = foregroundColor ?? .white
        self.borderColor = borderColor
        self.icon = icon
        self.width = width
        self.height = height
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            Task {
                isLoading = true
                await action()
                isLoading = false
            }
        }) {
            HStack {
                if let icon = icon {
                    icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: height.map { $0 * 0.5 } ?? 20)
                }
                Text(title)
                    .font(.headline)
            }
            .foregroundColor(foregroundColor)
            .padding()
            .frame(width: width, height: height)
            .background(backgroundColor)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor ?? .clear, lineWidth: borderColor != nil ? 1 : 0)
            )
            .opacity(isLoading ? 0.7 : 1)
            .overlay(
                Group {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                    }
                }
            )
        }
        .disabled(isLoading)
    }
}
