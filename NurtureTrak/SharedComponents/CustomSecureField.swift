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
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
            
            Button(action: {
                isSecure.toggle()
            }) {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 8)
        }
    }
}

struct CustomSecureField_Previews: PreviewProvider {
    static var previews: some View {
        CustomSecureField(placeholder: "Enter password", text: .constant(""))
            .padding()
    }
}
