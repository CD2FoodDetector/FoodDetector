//
//  ContentView.swift
//  FoodDetector
//
//  Created by 강다연 on 2021/10/06.
//

import SwiftUI


struct Response: Codable{
    var status_code: Int?
    var token: String?
    var msg: String?
}

class CommonVar: ObservableObject {
    @Published var token: String = ""
}

struct ContentView: View {
    
    @State var username: String = ""
    @State var password: String = ""
    
    @State var authenticationDidSucceed: Int = 0
    
    @EnvironmentObject var cv: CommonVar
    
    var body: some View {
        NavigationView{
            VStack {
                TitleText()
            
                HStack{
                    VStack{
                        UsernameTextField(username: $username)
                        PasswordSecureField(password: $password)
                    } // End VStack
                    .padding()
                    
                    NavigationLink(
                        destination: TabDesignView(),
                        isActive: .constant(self.authenticationDidSucceed == 1),
                        label: {
                            Button(action: {
                                check_user(username, password)
                            }) {
                                LoginButtonContent()
                            }
                        })
                } // End HStack
                
                if authenticationDidSucceed == 2 {
                    Text("존재하지 않는 아이디입니다.")
                        .offset(y: -10)
                        .foregroundColor(.red)
                }
                else if authenticationDidSucceed == 3 {
                    Text("잘못된 비밀번호입니다.")
                        .offset(y: -10)
                        .foregroundColor(.red)
                }
                
                HStack{
                    NavigationLink(destination: SignupView()){
                        SmallButton1()
                    }
                    SmallButton2()
                } // End HStack
                .navigationBarHidden(true)
            } // End VStack
            .padding()
        }
    }
    
    func check_user(_ id: String, _ pwd: String) {
        guard let url = URL(string: "http://3.36.103.81:80/account/app_login") else {
            print("Invalid url")
            return
        }
        var request = URLRequest(url: url)
        let params = try! JSONSerialization.data(withJSONObject: ["id":id, "passwd":pwd], options: [])
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = params
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let result = try! JSONDecoder().decode(Response.self, from: data!)
            print(result.msg!)
            cv.token = result.token!
            print("token = \(cv.token)")
            self.authenticationDidSucceed = result.status_code!
        }.resume()
         
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}

struct TitleText: View {
    var body: some View {
        Text("Food Detector!")
            .font(.largeTitle)
            .fontWeight(.semibold)
            .padding(.bottom, 20)
    }
}

struct LoginButtonContent: View {
    var body: some View {
        Text("LOGIN")
            .font(.body)
            .foregroundColor(.white)
            .padding()
            .frame(width: 90, height:50)
            .background(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
            .cornerRadius(20.0)
    }
}

struct UsernameTextField: View {
    
    @Binding var username: String
    
    var body: some View {
        TextField("Username", text: $username)
            .padding()
            .background(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
            .cornerRadius(5.0)
            .padding(.bottom, 20)
            .disableAutocorrection(true)
            .autocapitalization(.none)
    }
}

struct PasswordSecureField: View {
    
    @Binding var password: String
    
    var body: some View {
        SecureField("Password", text: $password)
            .padding()
            .background(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
            .cornerRadius(5.0)
            .padding(.bottom, 20)
    }
}

struct SmallButton1: View {
    var body: some View {
        Text("회원가입")
            .font(.footnote)
            .foregroundColor(.white)
            .padding()
            .frame(height:30)
            .background(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
            .cornerRadius(11.0)
    }
}

struct SmallButton2: View {
    var body: some View {
        Text("아이디/비밀번호 찾기")
            .font(.footnote)
            .foregroundColor(.white)
            .padding()
            .frame(height:30)
            .background(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
            .cornerRadius(11.0)
    }
}
