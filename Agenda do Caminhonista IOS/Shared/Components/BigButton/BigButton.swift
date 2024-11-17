//
//  BigButton.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 02/11/2024.
//

import SwiftUI

struct BigButton: View {
    var text: String
    var isLoading: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            if isLoading {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
            } else {
                Text("\(text)")
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .fontWeight(.bold)
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)    }
}

#Preview {
    BigButton(text: "Criar", isLoading: true, action: {
        print("Ola")
    })
}
