import SwiftUI

func saveToken(_ token: String) {
    UserDefaults.standard.set(token, forKey: "userToken")
}

func getToken() -> String? {
    return UserDefaults.standard.string(forKey: "userToken")
}
