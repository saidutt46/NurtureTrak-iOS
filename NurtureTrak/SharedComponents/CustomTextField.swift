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
                .autocapitalization(.none)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(error.isEmpty ? Color.clear : Color.red, lineWidth: 1)
                )
            
            if !error.isEmpty {
                HStack {
                    Image(systemName: "exclamationmark.circle")
                    Text(error)
                }
                .foregroundColor(.red)
                .font(.caption)
            }
        }
    }
}
