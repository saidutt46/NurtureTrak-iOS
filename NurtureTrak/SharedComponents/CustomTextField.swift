//
//  CustomTextField.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/20/24.
//

import Foundation
import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var error: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(error.isEmpty ? Color.clear : Color.red, lineWidth: 1)
                )
            
            if !error.isEmpty {
                Label(error, systemImage: "exclamationmark.circle")
                    .foregroundColor(.red)
                    .font(.caption)
                    .accessibilityLabel("Error: \(error)")
            }
        }
    }
}
