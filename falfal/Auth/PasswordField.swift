//
//  PasswordField.swift
//  LoginFlowTemplate
//
//  Created by Jean-Marc Boullianne on 1/23/21.
//

import SwiftUI

struct PasswordField: View {
    
    @Binding var password: String
    var error: Bool
    
    @State private var showPassword: Bool = false
    
    var body: some View {
        if showPassword {
            TextField("", text: $password)
                .font(Font.custom("Avenir Next", size: 14))
                .frame(height: 40)
                .padding(.leading, 12)
                .background(Color("PrimaryTextColor").opacity(0.1))
                .foregroundColor(Color("PrimaryTextColor"))
                .overlay(
                    Button(action: {
                        showPassword.toggle()
                    }, label: {
                        Image(systemName: showPassword ? "eye" : "eye.slash")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20, alignment: .center)
                            .padding(.trailing, 16)
                            .foregroundColor(Color("PrimaryTextColor"))
                    }).opacity(password != "" ? 1 : 0)
                ,alignment: .trailing)
                .overlay(Rectangle()
                            .stroke(error ? Color.red.opacity(0.7) : Color.clear, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [], dashPhase: 0)))
        } else {
            SecureField("", text: $password)
                //.font(Font.custom("Avenir Next", size: 14))
                .frame(height: 40)
                .padding(.leading, 12)
                .background(Color("PrimaryTextColor").opacity(0.1))
                .foregroundColor(Color("PrimaryTextColor"))
                .overlay(
                    Button(action: {
                        showPassword.toggle()
                    }, label: {
                        Image(systemName: showPassword ? "eye" : "eye.slash")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20, alignment: .center)
                            .padding(.trailing, 16)
                            .foregroundColor(Color("PrimaryTextColor"))
                    }).opacity(password != "" ? 1 : 0)
                ,alignment: .trailing)
                .overlay(Rectangle()
                            .stroke(error ? Color.red.opacity(0.7) : Color.clear, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [], dashPhase: 0)))
        }
        
    }
}

struct PasswordField_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            PasswordField(password: .constant("123abc"), error: false)
        }
    }
}
