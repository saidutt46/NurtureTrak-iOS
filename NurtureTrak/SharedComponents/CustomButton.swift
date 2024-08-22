//
//  CustomButton.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/20/24.
//

import Foundation
import SwiftUI

struct CustomButton: View {
    let title: String
    var action: (() -> Void)? = nil
    let backgroundColor: Color
    
    var body: some View {
        Button(action: action ?? {}) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
                .cornerRadius(10)
        }
        .padding(.horizontal, 40)
    }
}
