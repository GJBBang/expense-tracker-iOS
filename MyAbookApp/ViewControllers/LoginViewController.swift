//
//  LoginViewController.swift
//  MyAbookApp
//
//  Created by GiJinBang on 5/10/25.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        handleLogin()
    }
        
    func handleLogin() {
        guard let userName = userNameTextField.text, !userName.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("ID와 비밀번호를 모두 입력하세요.")
            return
        }

        let loginRequest = LoginRequest(userName: userName, password: password)
        loginAPI(request: loginRequest)
    }
    
    func loginAPI(request: LoginRequest) {
        guard let url = URL(string: "https://localhost:8080/api/v1/members/login") else { return }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
        } catch {
            print("JSON 인코딩 실패: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("네트워크 오류: \(error)")
                return
            }

            guard let data = data else {
                print("응답 데이터 없음")
                return
            }

            do {
                let response = try JSONDecoder().decode(LoginResponse.self, from: data)
                DispatchQueue.main.async {
                    if response.success {
                        print("로그인 성공. 토큰: \(response.token ?? "")")
                        // 다음 화면으로 이동하거나 토큰 저장 등 작업 수행
                    } else {
                        print("로그인 실패: \(response.message ?? "알 수 없는 오류")")
                    }
                }
            } catch {
                print("응답 디코딩 실패: \(error)")
            }
        }

        task.resume()
    }
}


struct LoginRequest: Codable {
    let userName: String
    let password: String
}

struct LoginResponse: Codable {
    let success: Bool
    let token: String?
    let message: String?
}

