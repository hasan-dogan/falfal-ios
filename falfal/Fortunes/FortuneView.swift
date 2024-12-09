import SwiftUI
struct FortuneView: View {
    @State var adManager: AdManager // Use ObservedObject for AdManager
    @EnvironmentObject var appState: AppState // AppState erişimi
    
    var body: some View {
        return AnyView(
            NavigationStack {
                ScrollView (showsIndicators: false){
                    VStack(spacing: 20) {
                        // Tarot Kartı
                        FortuneCardView(
                            title: "Tarot",
                            info: "Tarot, kartlar aracılığıyla hayatına dair ipuçları ve rehberlik sunan eğlenceli bir keşif yoludur.",
                            redirectView: AnyView(TarotQuestionView(adManager: adManager)) // Pass adManager here as AnyView
                        )
                        
                        FortuneCardView(
                            title: "Kahve Falı",
                            info: "Kahve falı, kahve telvesi üzerindeki sembollerin yorumlanmasıyla geleceğe dair ipuçları veren bir fal çeşididir.",
							redirectView: AnyView(CoffeeUploadView(adManager: adManager)) // Pass adManager here as AnyView
						)
						
						FortuneCardView(
							title: "Bulut Falı",
							info: "Çok Yakında",
							redirectView: AnyView(TarotQuestionView(adManager: adManager)) // Pass adManager here as AnyView
						).disabled(true)
							.opacity(0.5)
						
						FortuneCardView(
							title: "Katina Falı",
							info: "Çok Yakında",
							redirectView: AnyView(TarotQuestionView(adManager: adManager)) // Pass adManager here as AnyView
						).disabled(true)
							.opacity(0.5)
						
						FortuneCardView(
							title: "Bakla Falı",
							info: "Çok Yakında",
							redirectView: AnyView(TarotQuestionView(adManager: adManager)) // Pass adManager here as AnyView
						).disabled(true)
							.opacity(0.5)
						
						FortuneCardView(
							title: "Melek Falı",
							info: "Çok Yakında",
							redirectView: AnyView(TarotQuestionView(adManager: adManager)) // Pass adManager here as AnyView
						).disabled(true)
							.opacity(0.5)
                        
                        FortuneCardView(
                            title: "El Falı",
                            info: "Çok Yakında",
                            redirectView: AnyView(TarotQuestionView(adManager: adManager)) // Pass adManager here as AnyView
                        ).disabled(true)
							.opacity(0.5)
                        
                        FortuneCardView(
                            title: "Su Falı",
                            info: "Çok Yakında",
                            redirectView: AnyView(TarotQuestionView(adManager: adManager)) // Pass adManager here as AnyView
                        ).disabled(true)
							.opacity(0.5)
                    }
                    .padding()
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        )
    }
}
