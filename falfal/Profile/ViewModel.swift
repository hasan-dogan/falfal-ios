import Combine
import SwiftUI

class ProfileViewModel: ObservableObject {
    
    
    
    @Published var profile: Profile

    init(profile: Profile = Profile(id: nil, email: "", name: "", lastName: "", birthDate: nil, relationShip: nil, gender: nil, hasChildren: nil, jobStatus: nil, educationLevel: nil)) {
         self.profile = profile
     }
    
    @Published var isLoading = false
    @State private var errorMessage: String?

    func fetchProfile() {
        guard let url = URL(string: "https://falsal.com/api/profile") else {
            print("API URL yanlış")
            return
        }
        guard let token = Keychain.get(key: "authToken") else {
            print("Auth token bulunamadı")
            self.errorMessage = "Oturum açmanız gerekiyor."
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        isLoading = true
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let data = data {
                    do {
                        let responseData = try JSONDecoder().decode(ResponseData<Profile>.self, from: data)
                        self.profile = responseData.data
                    } catch {
                        print("Decoding error: \(error)")
                        // Optionally, you can print the raw JSON to debug
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print("Raw JSON: \(jsonString)")
                        }
                    }
                } else {
                    print("Error fetching profile: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }.resume()
    }

    func updateProfile() {
        guard let url = URL(string: "https://falsal.com/api/profile/update") else {
            print("API URL yanlış")
            return
        }
        
        guard let token = Keychain.get(key: "authToken") else {
            print("Auth token bulunamadı")
            self.errorMessage = "Oturum açmanız gerekiyor."
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try JSONEncoder().encode(profile)
        } catch {
            print("Encoding error: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let data = data {
                    print("Profile updated: \(String(data: data, encoding: .utf8) ?? "")")
                } else {
                    print("Error updating profile: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }.resume()
    }
}

