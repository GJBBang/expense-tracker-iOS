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
        guard let url = URL(string: "http://localhost:8080/api/v1/members/join") else {
            print("잘못된 URL")
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Basic Authentication을 위한 ID와 비밀번호 결합
        let username = "user"
        let password = "123123"
        let credentials = "\(username):\(password)"
        
        // Base64로 인코딩
        if let encodedCredentials = credentials.data(using: .utf8)?.base64EncodedString() {
            // Authorization 헤더에 Basic 인증 정보 추가
            urlRequest.addValue("Basic \(encodedCredentials)", forHTTPHeaderField: "Authorization")
        }
        
        print(url)

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

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                do {
                    let response = try JSONDecoder().decode(SignUpResponse.self, from: data)
                    DispatchQueue.main.async {
                        if response.success {
                            print("회원 가입 성공. 토큰: \(response.token ?? "")")
                        } else {
                            print("회원 가입 실패: \(response.message ?? "알 수 없는 오류")")
                        }
                    }
                } catch {
                    print("응답 디코딩 실패: \(error)")
                }
            } else {
                print("서버 응답 오류. 상태 코드: \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
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
