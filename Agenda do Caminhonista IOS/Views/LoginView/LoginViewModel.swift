//
//  LoginViewModel.swift
//  Agenda do Caminhonista IOS
//
//  Created by Andre Rocha on 13/11/2024.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoginButtonLoading: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var isShowingErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    
    func handleLogin(email: String, password: String) async {
        isLoginButtonLoading = true
        
        guard !email.isEmpty, !password.isEmpty else {
            isLoginButtonLoading = false
            isShowingErrorAlert = true
            errorMessage = "Todos os campos devem ser preenchidos."
            return
        }
        
        let body: [String: String] = [
            "email": email,
            "password": password
        ]
        
        UserServices.login(body: body) { (result: Result<LoginResponse, NetworkError>) in
            switch result {
            case .success(let response):
                print(response)
                DispatchQueue.main.async {
                    self.isLoginButtonLoading = false
                    UserAuth.setToken(token: response.token)
                    UserAuth.setUser(user: response.user)
                    self.isLoggedIn = true
                }
            case .failure(let error):
                self.isLoginButtonLoading = false
                self.isShowingErrorAlert = true
                self.errorMessage = error.getErrorMessage()
            }
            
        }
    }
}
