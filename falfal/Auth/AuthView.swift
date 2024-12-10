import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices


struct AuthView: View {
	@EnvironmentObject var appState: AppState
	
	@Binding var user: User?
	@State private var isAppleSignInProcessing = false
	@State private var navigateToTabBar = false

	// Form Data Variables
	@State private var name: String = ""
	@State private var email: String = ""
	@State private var password: String = ""
	@State private var lastName: String = ""
	@State private var confirmPassword: String = ""
	@State private var alertMessage: String = ""
	
	
	// UI State and Form error handling variables
	@State private var showFields: Bool = false
	@State private var hasAccount: Bool = true
	@State private var nameError: Bool = false
	@State private var lastNameError: Bool = false
	@State private var emailError: Bool = false
	@State private var passwordError: Bool = false
	@State private var confirmPasswordError: Bool = false
	@State private var forgotPassword: Bool = false
	@State private var showAlert: Bool = false
	
	@State private var navigationPath = NavigationPath()
	@State private var showMessage: Bool = false
	@State private var messageTitle: String = ""
	@State private var messageContent: String = ""
	@State private var isErrorMessage: Bool = false
	@StateObject private var signInDelegate = SignInDelegate() // Delegate'i tutmak için StateObject

	
	@Environment(\.colorScheme) var colorScheme
	@State private var isTapped = false
	
	@StateObject private var keyboardResponder = KeyboardResponder()
	
	@FocusState private var focusedField: FocusedField?
	
	
	var backgroundImage: Image
	
	enum FocusedField {
		case name, lastName
	}
	
	var body: some View {
		
		NavigationStack {
			
			ZStack(alignment: .bottom) {
				// Change your Background Image in `Assets.xcassets`
				backgroundImage
					.resizable()
					.edgesIgnoringSafeArea(.all)
				
				
				// Change your Brand Image in `Assets.xcassets`
				ScrollView(showsIndicators: false) {
					
					VStack(spacing: -50) {
						Spacer()
							.frame(height: UIScreen.main.bounds.height * 0.10) // Üstten boşluk
						
						Color.white
							.frame(width: 55, height: 5, alignment: .center)
							.cornerRadius(3)
							.padding(.bottom, 12)
						
						VStack(alignment: .leading, spacing: 8) {
							Text(forgotPassword ? "Reset Password" : (hasAccount ? "Giriş" : "Kayıt Ol"))
								.font(Font.custom("Avenir Next", size: 25).weight(.bold))
								.foregroundColor(Color("PrimaryTextColor"))
							
							if !hasAccount {
								Text("Adınız")
									.font(Font.custom("Avenir Next", size: 12))
									.foregroundColor(Color("SecondaryTextColor"))
								
								NameField(name: $name, error: nameError)
									.padding(.bottom, 20)
							}
							
							if !hasAccount {
								Text("Soy Adınız")
									.font(Font.custom("Avenir Next", size: 12))
									.foregroundColor(Color("SecondaryTextColor"))
								
								LastNameField(lastName: $lastName, error: lastNameError)
									.padding(.bottom, 20)
							}
							
							Text("E-mail")
								.font(Font.custom("Avenir Next", size: 12))
								.foregroundColor(Color("SecondaryTextColor"))
							
							EmailField(email: $email, error: emailError)
								.padding(.bottom, 20)
							
							Text("Şifreniz")
								.font(Font.custom("Avenir Next", size: 12))
								.foregroundColor(Color("SecondaryTextColor"))
							
							PasswordField(password: $password, error: passwordError)
							
							if !hasAccount {
								Text("Şifreniz Tekrar")
									.font(Font.custom("Avenir Next", size: 12))
									.foregroundColor(Color("SecondaryTextColor"))
								
								ConfirmPassword(confirmPassword:$confirmPassword, error: confirmPasswordError)
							}
							
							Text("—————— Veya ——————")
								.font(.title)
								.fontWeight(.medium)
								.foregroundColor(Color.red)
								.multilineTextAlignment(.center)
								.lineLimit(10)
								.padding(.top, 10)
							
							Button(action: handleAppleSignIn) {
								HStack {
									Image(systemName: "apple.logo")
										.resizable()
										.aspectRatio(contentMode: .fit)
										.frame(height: 20)
									Text("Apple ile Giriş Yap")
										.font(.headline)
								}
								.foregroundColor(.white)
								.frame(maxWidth: .infinity)
								.frame(height: 50)
								.background(Color.black)
								.cornerRadius(10)
							}
							.disabled(isAppleSignInProcessing)
							
							
							Button(action: {
								googleLogin()
							}) {
								HStack(alignment: .center) {
									Spacer()
									Image(systemName: "g.circle.fill")
									Text("Google ile Giriş Yap")
										.foregroundColor(.black)
										.bold()
									
									Spacer()
								}
								.frame(maxWidth: .infinity)
								.foregroundColor(.white)
								.padding([.top, .bottom, .trailing], 15.0)
								.font(.system(size: 19, weight: .semibold))
								.background(Color.red)
								.cornerRadius(8)
							}
							
							if hasAccount {
								Button(action: {
								}, label: {
									Text(forgotPassword ? "Back to login":"")
										.font(Font.custom("Avenir Next", size: 16).weight(.semibold))
										.foregroundColor(Color("PrimaryButtonTextColor"))
								}).padding(.vertical, 16)
							}
							
							Button(action: {
								withAnimation(.easeInOut) {
									hasAccount.toggle()
									
									nameError = false
									emailError = false
									passwordError = false
								}
							}, label: {
								Text(hasAccount ? "Hesap Oluştur" : "Zaten Bir Hesabım Var")
									.font(Font.custom("Avenir Next", size: 16).weight(.bold))
									.frame(maxWidth: .infinity)
									.foregroundColor(Color("PrimaryButtonTextColor"))
							}).padding(.top, 50)
								.padding(.bottom, 50)
						}
						.padding(.all, 20)
						.background(Color("BackgroundColor"))
					}
				}
				.background(Color("BackgroundColor"))
				.offset(x: 0, y: showFields ? 0 : UIScreen.main.bounds.height)
				
				.contentShape(Rectangle()) // Tüm alanı tıklanabilir yapar
				.onTapGesture {
					UIApplication.shared.endEditing()
				}
				
				VStack {
					Spacer()
					Button(action: {
						if !showFields {
							withAnimation(.easeInOut) {
								showFields = true
							}
						} else {
							// Login or Signup
							submitForm()
						}
					}, label: {
						Text(showFields ? (forgotPassword ? "Send reset email" : (hasAccount ? "Giriş Yap" : "Kayıt Ol")) : "Hesabına Giriş Yap")
							.font(Font.custom("Avenir Next", size: 16).weight(.bold))
							.padding(.bottom, 20)
							.padding(.vertical, 20)
							.frame(maxWidth: .infinity)
							.foregroundColor(showFields ? Color.white : Color("PrimaryButtonTextColor"))
							.background(showFields ? Color("PrimaryButtonColor") : Color("PrimaryColorFlipped"))
					}).background(Color("BackgroundColor"))
				}
				.edgesIgnoringSafeArea(.vertical)
			}
			
			.alert(alertMessage, isPresented: $showAlert) {
				Button("OK", role: .cancel) { }
			}
			.fullScreenCover(isPresented: $navigateToTabBar) {
				ContentView()
			}
		}
	}
	
	func handleAppleSignInCompletion(){
		DispatchQueue.main.async {
			self.navigateToTabBar = true
		}

	}
	
	private func handleAppleSignIn() {
		guard !isAppleSignInProcessing else { return }
		print("Apple Sign In başlatılıyor...")
		isAppleSignInProcessing = true
		
		let provider = ASAuthorizationAppleIDProvider()
		let request = provider.createRequest()
		request.requestedScopes = [.fullName, .email]
		
		signInDelegate.completion = { result in
			isAppleSignInProcessing = false
			
			switch result {
			   case .success(_):
				handleAppleSignInCompletion()
			   case .failure(let error):
				   print("Apple Sign In Hatası: \(error.localizedDescription)")
			   }
		}
		
		let controller = ASAuthorizationController(authorizationRequests: [request])
		controller.delegate = signInDelegate
		controller.presentationContextProvider = signInDelegate
		
		print("Authorization controller başlatılıyor...")
		controller.performRequests()
	}
	

	private func showAlert(message: String) {
		alertMessage = message
		showAlert = true
	}
	
	private func login() {
		if email.isEmpty || password.isEmpty {
			showAlert(message: "Lütfen tüm alanları doldurun.")
			print("burda")
			
			return
		}
		
		let body: [String: String] = ["email": email, "password": password]
		sendRequestToAPI(body: body, endpoint: "https://falsal.com/api/login") { success in
			if success {
				navigateToTabBar = true
			} else {
				showAlert(message: "Giriş başarısız")
			}
		}
	}
	
	private func register() {
		if password != confirmPassword {
			showAlert(message: "Şifreler uyuşmuyor. Lütfen tekrar kontrol edin.")
			return
		}
		
		let body: [String: String] = [
			"email": email,
			"password": password,
			"confirmPassword": confirmPassword,
			"name": name,
			"lastName": lastName
		]
		sendRequestToAPI(body: body, endpoint: "https://falsal.com/api/register") { success in
			if success {
				navigateToTabBar = true
			} else {
				showAlert(message: "Kayıt Başarısız.")
			}
		}
	}
	
	
	func submitForm() {
		if hasAccount { // If 'Login' form shown
			emailError = !isEmailValid(email)
			passwordError = password == "" // and check if email/password combo is correct
			
			if emailError || passwordError {
				return
			}
			login()
			
		} else { // If 'Register' form shown
			nameError = name == ""
			emailError = !isEmailValid(email)
			passwordError = password == "" // and check password combo is correct
			
			if nameError || emailError || passwordError {
				return
			}
			register()
			
			
		}
	}
	
	private func sendRequestToAPI(body: [String: Any], endpoint: String, completion: @escaping (Bool) -> Void) {
		print(body, endpoint)
		guard let url = URL(string: endpoint) else { return }
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = try? JSONSerialization.data(withJSONObject: body)
		
		URLSession.shared.dataTask(with: request) { data, _, error in
			if let _ = error {
				DispatchQueue.main.async {
					completion(false)
				}
				return
			}
			
			guard let data = data,
				  let response = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
				  let token = response["token"] as? String else {
				DispatchQueue.main.async {
					completion(false)
				}
				return
			}
			
			DispatchQueue.main.async {
				appState.login(token: token)
				Keychain.save(key: "authToken", value: token)
				completion(true)
			}
		}.resume()
	}
	
	func showMessage(title: String, message: String, isError: Bool) {
		
		self.messageTitle = title
		self.messageContent = message
		self.isErrorMessage = isError
		self.showMessage = true
	}
	
	// Validates an email is formatted correctly
	func isEmailValid(_ email: String) -> Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		
		let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
		return emailPred.evaluate(with: email)
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
						self.navigateToTabBar = true
					} else {
						self.alertMessage = "Bir şeyler ters gitmiş gibi görünüyor."
					}
				}
			} catch {
			}
		}.resume()
		
	}
	
}

class SignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding, ObservableObject {

	var completion: ((Result<ASAuthorization, Error>) -> Void)?

	override init() {
		super.init()
		print("SignInDelegate başlatıldı")
	}
	


	func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		print("Presentation anchor istendi")
		guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
			  let window = windowScene.windows.first else {
			if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
				return windowScene.windows.first ?? UIWindow()
			}
			return UIWindow()
		}
		return window
	}
	
	func authorizationController(controller: ASAuthorizationController,
								 didCompleteWithAuthorization authorization: ASAuthorization) {
		print("Authorization tamamlandı")
		if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
			let userId = credential.user
			print("User ID: \(userId)")
			
			// API isteği için parametreler
			let parameters: [String: Any] = [
				"apple_id": userId,
				"email": credential.email ?? "user_\(userId)@apple.signin",
				"name": credential.fullName?.givenName ?? "User",
				"surname": credential.fullName?.familyName ?? String(userId.prefix(5))
			]
			
			// API isteği gönder
			guard let url = URL(string: "https://falsal.com/api/connect/apple") else {
				print("Geçersiz URL")
				return
			}
			
			var request = URLRequest(url: url)
			request.httpMethod = "POST"
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			
			do {
				request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
				
				URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
					if let error = error {
						print("Network error: \(error.localizedDescription)")
						DispatchQueue.main.async {
							self?.completion?(.failure(error))
						}
						return
					}
					
					guard let data = data else {
						print("Data alınamadı")
						return
					}
					
					do {
						let decoder = JSONDecoder()
						let response = try decoder.decode(LoginResponse.self, from: data)
						
						if response.success {
							print("Login başarılı")
							if let token = response.data.token {
								DispatchQueue.main.async {
									Keychain.save(key: "authToken", value: token)
									AppState().login(token: token)
									self?.completion?(.success(authorization))
								}
							}
						} else {
							print("Login başarısız: \(response.message)")
							DispatchQueue.main.async {
								self?.completion?(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: response.message])))
							}
						}
					} catch {
						print("JSON decode hatası: \(error.localizedDescription)")
						print("Raw response: \(String(data: data, encoding: .utf8) ?? "none")")
						DispatchQueue.main.async {
							self?.completion?(.failure(error))
						}
					}
				}.resume()
				
			} catch {
				print("JSON encode hatası: \(error.localizedDescription)")
				completion?(.failure(error))
			}
		}
	}
	
	func authorizationController(controller: ASAuthorizationController,
								 didCompleteWithError error: Error) {
		print("Authorization hatası: \(error.localizedDescription)")
		completion?(.failure(error))
	}
}

// Login response modeli
struct LoginResponse: Codable {
	let success: Bool
	let message: String
	let data: LoginData
}

struct LoginData: Codable {
	let token: String?
	// Diğer dönecek veriler varsa ekleyin
}

// Temporary User Struct for logging in
struct User {
	var name: String
	var email: String
}


extension UIApplication {
	func endEditing() {
		sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}
