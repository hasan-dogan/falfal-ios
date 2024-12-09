//
//  EmailField.swift
//  LoginFlowTemplate
//
//  Created by Jean-Marc Boullianne on 1/23/21.
//

import SwiftUI

struct EmailField: View {
    
    @Binding var email: String
    var error: Bool
    
    var body: some View {
        TextField("", text: $email)
            .textContentType(.emailAddress)
            .disableAutocorrection(true)
            .font(Font.custom("Avenir Next", size: 14))
            .frame(height: 40)
            .padding(.leading, 12)
            .background(Color("PrimaryTextColor").opacity(0.1))
            .foregroundColor(Color("PrimaryTextColor"))
            .overlay(Rectangle()
                        .stroke(error ? Color.red.opacity(0.7) : Color.clear, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [], dashPhase: 0)))
    }
}

struct EmailField_Previews: PreviewProvider {
    static var previews: some View {
        EmailField(email: .constant("email"), error: true)
    }
}
