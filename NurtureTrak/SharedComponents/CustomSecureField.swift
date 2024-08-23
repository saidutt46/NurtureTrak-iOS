//
//  CustomSecureField.swift
//  NurtureTrak
//
//  Created by Sai Dutt Ganduri on 8/20/24.
//

import Foundation
import SwiftUI

struct CustomSecureField: View {
    let placeholder: String
    @Binding var text: String
    @State private var isSecure: Bool = true
    var error: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .trailing) {
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .padding()
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(error.isEmpty ? Color.clear : Color.red, lineWidth: 1)
                )
                
                Button(action: {
                    isSecure.toggle()
                }) {
                    Image(systemName: isSecure ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)
            }
            
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


struct CustomSecureField_Previews: PreviewProvider {
    static var previews: some View {
        CustomSecureField(placeholder: "Enter password", text: .constant(""))
            .padding()
    }
}
