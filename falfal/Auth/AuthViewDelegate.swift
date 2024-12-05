import SwiftUI
import AuthenticationServices

class AuthViewDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            if let identityToken = appleIDCredential.identityToken,
               let tokenString = String(data: identityToken, encoding: .utf8) {
                print("Apple ID Token: \(tokenString)")
                
                // Token'ı API'ye gönderin
                sendAppleTokenToAPI(token: tokenString)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple Giriş Hatası: \(error.localizedDescription)")
    }
    
	func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
			return windowScene.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
		}
		return ASPresentationAnchor()
	}
    
    private func sendAppleTokenToAPI(token: String) {
        // API isteği yapma kodu buraya gelecek
    }
}
