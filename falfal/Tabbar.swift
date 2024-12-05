import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var appState: AppState // Oturum bilgilerini AppState'ten alıyoruz
    var adManager: AdManager
    @State private var isLocked = false // Home sekmesindeki kontrol değişkeni
    @State private var showAlert: Bool = false // Uyarı mesajını göstermek için
    @State private var navigateToAuth: Bool = false // Giriş ekranına yönlendirme kontrolü

    var body: some View {
        TabView {
            // Anasayfa sekmesi
            HomeView(isLocked: $isLocked, adManager: adManager)
                .tabItem {
                    Label("Anasayfa", systemImage: "house.fill")
                }
                .onChange(of: isLocked) { newValue in
                    if newValue {
                        showAlert = true
                    }
                }

            // Fallar sekmesi
            Group {
				FortuneView(adManager: adManager)
            }
            .tabItem {
                Label("Fallar", systemImage: "star.fill")
            }
			.disabled(isLocked)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Falınız Devam Ediyor"),
                    message: Text("Falınız halen devam etmekte. Lütfen bitmesini bekleyin."),
                    dismissButton: .default(Text("Tamam"))
                )
            }

            // Profil/Giriş sekmesi
            Group {
                if appState.isAuthenticated {
                    ProfileView()
                } else {
                    AuthView()
                }
            }
            .tabItem {
                Label(appState.isAuthenticated ? "Profil" : "Giriş", systemImage: "person.fill")
            }
        }
        .environmentObject(appState)
    }
}
