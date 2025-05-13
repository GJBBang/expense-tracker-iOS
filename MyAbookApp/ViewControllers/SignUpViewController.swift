//
//  SignUpViewController.swift
//  MyAbookApp
//
//  Created by GiJinBang on 5/12/25.
//

import UIKit

class SignUpViewController: UIViewController {
    
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        handleSignUp()
    }
    
    func handleSignUp() {
        guard let userName = userNameTextField.text, !userName.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            print("ID와 비밀번호를 모두 입력하세요.")
            return
        }

        let signUpRequest = SignUpRequest(userName: userName, email: email, password: password)
        signUpAPI(request: signUpRequest)
    }

    func signUpAPI(request: SignUpRequest) {
        guard let url = URL(string: "https://localhost:8080/api/v1/members/join") else { return }

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
                let response = try JSONDecoder().decode(SignUpResponse.self, from: data)
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


struct SignUpRequest: Codable {
    let userName: String
    let email: String
    let password: String
}

struct SignUpResponse: Codable {
    let success: Bool
    let token: String?
    let message: String?
}
