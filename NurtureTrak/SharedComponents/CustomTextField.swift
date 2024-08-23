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
    
    var body: some View {
        TextField(placeholder, text: $text)
            .autocapitalization(.none) // Prevents automatic capitalization
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
    }
}
