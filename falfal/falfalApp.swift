import SwiftUI
import GoogleMobileAds


@main
struct falfalApp: App {

    
    // AppDelegate bağlantısını yapıyoruz
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()  // ContentView burada yer alıyor
      
        }
    }
}
