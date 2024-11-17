//
//  GroupBoxCardStyle.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 02/11/2024.
//

import SwiftUI

struct GroupBoxCardStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .fontWeight(.bold)
                .font(.title3)
            Divider()
            configuration.content
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.05))
        .cornerRadius(5)
    }
}
