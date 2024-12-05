//
//  ContentView.swift
//  falfal
//
//  Created by hasan doğan on 27.11.2024.
//

import SwiftUI
import GoogleMobileAds

struct ContentView: View {
    var adManager = AdManager()
    @State private var selectedTab = 0  // TabView için seçili sekme
    @StateObject var appState = AppState() // Uygulama durumu
    init() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    var body: some View {
		RootNavigationView(adManager: adManager)
            .environmentObject(appState) // AppState'i paylaş
    }
}


#Preview {
    ContentView()
}
