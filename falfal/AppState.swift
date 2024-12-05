import SwiftUI
class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false

    init() {
        // Token kontrolüyle başlat
        if let token = UserDefaults.standard.string(forKey: "userToken"), !token.isEmpty {
            isAuthenticated = true
        } else {
            isAuthenticated = false
        }
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: "userToken")
        isAuthenticated = false
    }

    func login(token: String) {
        UserDefaults.standard.set(token, forKey: "userToken")
        isAuthenticated = true
    }
}
