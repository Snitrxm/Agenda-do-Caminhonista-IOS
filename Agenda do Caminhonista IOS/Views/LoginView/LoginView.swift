//
//  ContentView.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 28/10/2024.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(10)
                
                SecureField("Senha", text: $viewModel.password)
                    .textInputAutocapitalization(.never)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(10)
                
                BigButton(text: "Entrar", isLoading: viewModel.isLoginButtonLoading, action: {
                    Task {
                        await viewModel.handleLogin(email: viewModel.email, password: viewModel.password)
                    }
                })
            }
            .padding()
            .navigationTitle("Agenda do Caminhonista")
            .navigationDestination(isPresented: $viewModel.isLoggedIn) {
                HomeView()
                    .navigationBarBackButtonHidden(true)
            }
            .alert(isPresented: $viewModel.isShowingErrorAlert) {
                Alert(title: Text("Não foi possivel fazer o login"), message: Text("\(viewModel.errorMessage)"))
            }
            .onAppear {
                Task {
                    await viewModel.handleLogin(email: "andre@gmail.com", password: "Snitr@m13")
                }
            }
        }
    }
}

#Preview {
    LoginView()    
}
