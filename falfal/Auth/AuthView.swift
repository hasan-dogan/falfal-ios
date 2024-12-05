import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices

struct AuthView: View {
    @EnvironmentObject var appState: AppState
    @State var email = ""
    @State var password = ""
    @State var confirmPassword = ""
    @State var name = ""
    @State var lastName = ""
    @State var isLogin = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigationPath = NavigationPath()
    @State private var showMessage: Bool = false
    @State private var messageTitle: String = ""
    @State private var messageContent: String = ""
    @State private var isErrorMessage: Bool = false
    var adManager = AdManager()
	
	@Environment(\.colorScheme) var colorScheme

    var body: some View {
        
        NavigationStack(path: $navigationPath) {
            
            ScrollView {
                VStack {
                    
                    Picker(selection: $isLogin, label: Text("")) {
                        Text("Giriş Yap").tag(true)
                        Text("Kayıt Ol").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .cornerRadius(8)
                    
                    Group {
                        if !isLogin {
                            // Kayıt olma formu
                            TextField("Ad", text: $name)
                                .padding(12)
                                .cornerRadius(8)
                            
                            TextField("Soyad", text: $lastName)
                                .padding(12)
                                .cornerRadius(8)
                        }
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding(12)
                            .cornerRadius(8)
                        SecureField("Şifre", text: $password)
                            .autocapitalization(.none)
                            .padding(12)
                            .cornerRadius(8)
                        if !isLogin {
                            SecureField("Şifreyi Onayla", text: $confirmPassword)
                                .autocapitalization(.none)
                                .padding(12)
                                .cornerRadius(8)

                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    
                    .padding(12)
                    .cornerRadius(8)
                    
                    
                    
                    Button {
                        if isLogin {
                            login(email: email, password: password)
                        } else {
                            // Confirm Password Kontrolü
                            if password != confirmPassword {
                                self.showAlert = true
                                self.alertMessage = "Şifreler uyuşmuyor. Lütfen tekrar kontrol edin."
                            } else {
                                register(email: email, password: password, confirmPassword: confirmPassword, name: name, lastName: lastName)
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text(isLogin ? "Giriş Yap" : "Kayıt Ol")
								.foregroundColor(colorScheme == .dark ? .black : .white)  // Rengi modlara göre değiştiriyoruz
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }
                        .padding(.vertical, 14)
                        .background(colorScheme == .dark ? Color.white : Color.black) // Arka plan rengini belirle
                        .cornerRadius(8)
                        .shadow(color: colorScheme == .dark ? .gray : .black, radius: 10, y: 5)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text(alertMessage))
                    }
                    
                    
                    Text("—————— Veya ——————")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)

                    
                    // Google ile giriş butonu
                    Button(action: {
                        googleLogin()
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "g.circle.fill") // Google ikonu için sistem simgesi
                            Text("Google ile Giriş Yap")
                                .foregroundColor(.black)
                                .bold()

                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding([.top, .bottom, .trailing], 14.0)
                        .font(.system(size: 14, weight: .semibold))
                        .background(Color.red)
                        .cornerRadius(8)

                    }
                    
                    // Apple ile giriş butonu
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authResults):
                                // Token veya kullanıcı bilgilerini işleme
                                handleAppleSignIn(result: authResults)
                            case .failure(let error):
                                print("Apple Login Hatası: \(error.localizedDescription)")
                            }
                        }
                    )
                    .frame(height: 50) // Yüksekliği ayarlayın
                    .cornerRadius(8)
					.background(colorScheme == .dark ? Color.white : Color.black) // Karanlık mod uyumu
					.shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 3) // Hafif bir gölge ekliyoruz

                    .padding([.top], 10)
                    
                    
                }
                .padding()

            }
            .navigationTitle(isLogin ? "Giriş Yap" : "Kayıt Ol")
            .navigationDestination(for: String.self) { _ in
				ContentView()
                       .navigationBarBackButtonHidden(true) // Geri butonunu tamamen gizler
            }
        }.preferredColorScheme(.light) // Tema her zaman açık renk
    }
	
	private func showAlert(message: String) {
		  alertMessage = message
		  showAlert = true
	  }
	
	private func inputsAreValid() -> Bool {
		   if isLogin {
			   return !email.isEmpty && !password.isEmpty
		   } else {
			   return !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && !name.isEmpty && !lastName.isEmpty
		   }
	   }
	
	private func socialLoginButton(title: String, color: Color, icon: String, action: @escaping () -> Void) -> some View {
			Button(action: action) {
				HStack {
					Image(systemName: icon)
						.foregroundColor(.white)
					Text(title)
						.fontWeight(.semibold)
						.foregroundColor(.white)
				}
				.padding()
				.frame(maxWidth: .infinity)
				.background(color)
				.cornerRadius(12)
				.shadow(radius: 5)
			}
		}
	

    
    func handleAppleSignIn(result: ASAuthorization) {
        guard let credential = result.credential as? ASAuthorizationAppleIDCredential else { return }

        if let identityToken = credential.identityToken,
           let tokenString = String(data: identityToken, encoding: .utf8) {
            print("Apple ID Token: \(tokenString)")

            // API isteği yapma
            sendAppleTokenToAPI(token: tokenString)
        } else {
            print("Apple Kimlik Doğrulama Jetonu alınamadı.")
        }
    }

    func sendAppleTokenToAPI(token: String) {
        guard let url = URL(string: "https://falsal.com/api/connect/apple/check") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["idToken": token]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Apple API isteği hatası: \(error.localizedDescription)")
                return
            }

            guard let data = data else { return }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let token = json["token"] as? String {
                    DispatchQueue.main.async {
                        appState.login(token: token)
                    }
                    Keychain.save(key: "authToken", value: token)
                    navigationPath.append("Content")
                }
            } catch {
                print("Apple JSON işleme hatası: \(error.localizedDescription)")
            }
        }.resume()
        
    }
    
    
    
    
    
    func login(email: String, password: String) {
        guard let url = URL(string: "https://falsal.com/api/login") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.alertMessage = "Error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else { return }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                dump(jsonResponse)
                
                if let jsonDict = jsonResponse as? [String: Any],
                   let token = jsonDict["token"] as? String {
                    Keychain.save(key: "authToken", value: token)
                    DispatchQueue.main.async {
                        self.showMessage(title: "Başarılı", message: "Tarot falı işleniyor!", isError: false)
                        appState.login(token: token) // Giriş yapıldığı bilgisi kaydedilir
                        navigationPath.append("Content") // veya `TabBarView()` gösterimi
                }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert = true
                        self.alertMessage = "Giriş bilgilerinizde bir sorun var gibi görünüyor"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.alertMessage = "Sunucu ile bağımız koptu... durumun farkındayız toparlıyoruz."
                }
            }
        }.resume()
    }
    
    func register(email: String, password: String, confirmPassword: String, name: String, lastName: String) {
        guard let url = URL(string: "https://falsal.com/api/register") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "email": email,
            "password": password,
            "confirmPassword": confirmPassword,
            "name": name,
            "lastName": lastName
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.alertMessage = "Error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else { return }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])                
                if let jsonDict = jsonResponse as? [String: Any],
                   let token = jsonDict["token"] as? String {
                    Keychain.save(key: "authToken", value: token)
                    DispatchQueue.main.async {
                        self.showMessage(title: "Başarılı", message: "Kaydınız başarıyla tamamlandı. Giriş yapabilirsiniz.", isError: false)
                        appState.login(token: token) // Giriş yapıldığı bilgisi kaydedilir
                            navigationPath.append("Content") // veya `TabBarView()` gösterimi

                    }
                } else {
                    DispatchQueue.main.async {
                        self.showAlert = true
                        self.alertMessage = "Kayıt işlemi sırasında bir sorun oluştu, dilersen daha sonra tekrar dene"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.alertMessage = "Sunucu ile bağımız koptu... durumun farkındayız toparlıyoruz."
                }
            }
        }.resume()
    }
    
    func showMessage(title: String, message: String, isError: Bool) {
        self.messageTitle = title
        self.messageContent = message
        self.isErrorMessage = isError
        self.showMessage = true
    }
    
    func googleLogin() {
        guard let path = Bundle.main.path(forResource: "googleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientID = plist["CLIENT_ID"] as? String else {
            print("Google Client ID bulunamadı!")
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // UIWindowScene'den Root View Controller elde edilir
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let rootViewController = windowScene?.windows.first?.rootViewController
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController!) { result, error in
            if let error = error {
                print("Google Login Hatası: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user, let idToken = user.idToken else {
                print("Kullanıcı veya Token alınamadı.")
                return
            }
            
            print("Google Login Başarılı!")
            print("User: \(user.profile?.email ?? "Email Yok")")
            print("Token: \(idToken.tokenString)")
            
            // Google giriş başarılıysa kullanıcı durumu güncellenir
            DispatchQueue.main.async {
                // API'ye gönderme ve token'ı alıp kaydetme
                self.sendGoogleTokenToAPI(idToken: idToken.tokenString)
            }
        }
    }
    
    func sendGoogleTokenToAPI(idToken: String) {
        let url = URL(string: "https://falsal.com/api/connect/google/check")!
        
        // API isteği için gerekli parametreler
        let parameters: [String: Any] = [
            "idToken": idToken
        ]
        
        // API isteğini yapmak için URLRequest oluşturuyoruz
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        // URLSession kullanarak API isteği gönderiyoruz
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API isteği hatası: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("API'den veri alınamadı.")
                return
            }

            // Gelen HTTP yanıt başlıkları
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                print("HTTP Response Headers: \(httpResponse.allHeaderFields)")
            }

            // Gelen veri
            if let jsonString = String(data: data, encoding: .utf8) {
                print("API'den Gelen Veri: \(jsonString)") // API yanıtını raw formatta yazdır
            }

            // JSON işlemeyi deneyelim
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    if let token = json["token"] as? String {
                        DispatchQueue.main.async {
                       appState.login(token: token)
                                   }
                        Keychain.save(key: "authToken", value: token)
                        navigationPath.append("Content")
                    } else {
                        self.alertMessage = "Bir şeyler ters gitmiş gibi görünüyor."
                    }
                }
            } catch {
            }
        }.resume()
        
    }
    
   
}


#Preview {
    AuthView()
        .environmentObject(AppState()) // Preview'da AppState sağlamayı unutmayın
}


extension View {
	func styledInputField() -> some View {
		self
			.padding()
			.background(Color.gray.opacity(0.2))
			.cornerRadius(12)
			.overlay(
				RoundedRectangle(cornerRadius: 12)
					.stroke(Color.gray.opacity(0.5), lineWidth: 1)
			)
			.padding(.horizontal)
	}
}
