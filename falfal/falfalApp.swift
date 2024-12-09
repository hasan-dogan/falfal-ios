import SwiftUI
import GoogleMobileAds

@main
struct falfalApp: App {
	// AppDelegate bağlantısını yapıyoruz
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	@State private var showSplash = true // Splash ekranı kontrolü

	var body: some Scene {
		WindowGroup {
			ZStack {
				if showSplash {
					SplashView()
				} else {
					ContentView() // ContentView burada yer alıyor
				}
			}
			.onAppear {
				// Splash ekranını 3 saniye sonra kapat
				DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
					withAnimation {
						showSplash = false
					}
				}
			}
		}
	}
}

struct SplashView: View {
	var body: some View {
		ZStack {
			VStack {
				Image("falsal") // Logonuzun adı
					.resizable()
					.edgesIgnoringSafeArea(.all)
			}
		}
	}
}
