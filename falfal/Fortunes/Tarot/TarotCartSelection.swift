import SwiftUI

// MARK: - Helper Views
struct BackgroundView: View {
	var body: some View {
		LinearGradient(
			gradient: Gradient(colors: [
				Color.purple.opacity(0.7),
				Color.indigo.opacity(0.6),
				Color.blue.opacity(0.5)
			]),
			startPoint: .topLeading,
			endPoint: .bottomTrailing
		)
		.edgesIgnoringSafeArea(.all)
	}
}

struct TitleView: View {
	var body: some View {
		Text("Tarot Kartlarınızı Seçin")
			.font(.system(size: 32, weight: .bold))
			.foregroundStyle(
				LinearGradient(
					colors: [Color.white, Color.purple.opacity(0.8)],
					startPoint: .leading,
					endPoint: .trailing
				)
			)
			.shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
			.padding(.vertical, 20)
	}
}

// MARK: - Main View
struct TarotCardSelectionView: View {
	var adManager: AdManager
	let question: String
	
	@State private var selectedCards: [Card] = []
	@State private var cardData: [Card] = []
	@State private var isAnimating: Bool = false
	@State private var showMessage: Bool = false
	@State private var messageTitle: String = ""
	@State private var messageContent: String = ""
	@State private var isErrorMessage: Bool = false
	@State private var navigateToCardSelection = false
	@State private var isLocked: Bool = false
	
	var body: some View {
		NavigationStack {
			ZStack {
				BackgroundView()
				
				VStack(spacing: 20) {
					TitleView()
					
					// Cards Selection Area
					GeometryReader { geometry in
						ZStack {
							ForEach(cardData) { card in
								cardView(card: card, geometry: geometry)
							}
						}
					}
					.frame(height: 350)
					
					Spacer()
					
					// Selected Cards Display
					VStack(spacing: 15) {
						HStack {
							Text("\(selectedCards.count)/7")
								.font(.system(size: 16, weight: .semibold))
								.foregroundColor(selectedCards.count == 7 ? .green : .white)
								.padding(.horizontal, 12)
								.padding(.vertical, 6)
								.background(
									Capsule()
										.fill(Color.black.opacity(0.2))
										.overlay(
											Capsule()
												.stroke(selectedCards.count == 7 ? .green.opacity(0.3) : .white.opacity(0.2), lineWidth: 1)
										)
								)
						}
						
						ScrollView(.horizontal, showsIndicators: false) {
							HStack(spacing: -15) {
								ForEach(selectedCards) { card in
									Image(card.image)
										.resizable()
										.scaledToFit()
										.frame(width: 60, height: 100)
										.rotationEffect(.degrees(card.isReverted ? 180 : 0))
										.shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
										.transition(.scale)
								}
							}
							.padding(.horizontal)
						}
					}
					.padding(.vertical, 20)
					
					// Submit Button
					Button(action: {
						processTarotSelection()
						navigateToCardSelection = true
					}) {
						Text("Falıma Bak")
							.font(.system(size: 20, weight: .semibold))
							.foregroundColor(.white)
							.frame(maxWidth: .infinity)
							.frame(height: 56)
							.background(
								LinearGradient(
									colors: selectedCards.count == 7 ?
										[Color.purple.opacity(0.8), Color.blue.opacity(0.8)] :
										[Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
									startPoint: .leading,
									endPoint: .trailing
								)
							)
							.clipShape(RoundedRectangle(cornerRadius: 28))
							.overlay(
								RoundedRectangle(cornerRadius: 28)
									.stroke(Color.white.opacity(0.2), lineWidth: 1)
							)
							.shadow(color: Color.purple.opacity(0.3), radius: 10, x: 0, y: 5)
					}
					.disabled(selectedCards.count != 7)
					.padding(.horizontal, 20)
					.padding(.bottom, 30)
				}
				
				// Message Overlay
				if showMessage {
					Color.black.opacity(0.4)
						.edgesIgnoringSafeArea(.all)
						.overlay(
							VStack(spacing: 20) {
								Text(messageTitle)
									.font(.system(size: 20, weight: .bold))
									.foregroundColor(isErrorMessage ? .red : .white)
								
								Text(messageContent)
									.font(.system(size: 16))
									.foregroundColor(.white.opacity(0.9))
									.multilineTextAlignment(.center)
								
								Button(action: {
									withAnimation {
										showMessage = false
									}
								}) {
									Text("Tamam")
										.font(.system(size: 16, weight: .semibold))
										.foregroundColor(.white)
										.frame(width: 120, height: 44)
										.background(
											LinearGradient(
												colors: [.purple.opacity(0.8), .blue.opacity(0.8)],
												startPoint: .leading,
												endPoint: .trailing
											)
										)
										.clipShape(Capsule())
								}
							}
							.padding(30)
							.background(
								RoundedRectangle(cornerRadius: 25)
									.fill(.ultraThinMaterial)
									.overlay(
										RoundedRectangle(cornerRadius: 25)
											.stroke(Color.white.opacity(0.2), lineWidth: 1)
									)
							)
							.shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
						)
						.zIndex(1)
				}
			}
			.navigationBarHidden(true)
			.onAppear {
				loadCardData()
				adManager.loadInterstitialAd()
			}
			.navigationBarTitleDisplayMode(.inline)
			.navigationDestination(isPresented: $navigateToCardSelection) {
				TabBarView(adManager: AdManager()).environmentObject(AppState())
			}
		}
	}
	
	// MARK: - Card View
	private func cardView(card: Card, geometry: GeometryProxy) -> some View {
		let totalCards = CGFloat(cardData.count)
		let angle = 2 * .pi / totalCards * CGFloat(cardData.firstIndex(where: { $0.id == card.id }) ?? 0)
		let radius: CGFloat = min(geometry.size.width, geometry.size.height) * 0.40
		
		return Image(card.image)
			.resizable()
			.scaledToFit()
			.frame(width: 100, height: 150)
			.shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
			.rotationEffect(.degrees(card.isReverted ? 180 : 0))
			.overlay(
				selectedCards.contains(where: { $0.id == card.id }) ?
				Color.black.opacity(0.4) : Color.clear
			)
			.offset(
				x: (geometry.size.width / 2) - 50 + radius * cos(angle),
				y: (geometry.size.height / 2) - 50 + radius * sin(angle)
			)
			.onTapGesture {
				withAnimation {
					toggleCardState(card)
				}
			}
			.animation(.spring(), value: selectedCards)
	}
	
	// MARK: - Helper Functions
	func toggleCardState(_ card: Card) {
		guard !selectedCards.contains(where: { $0.id == card.id }) else { return }
		guard selectedCards.count < 7 else {
			showMessage(
				title: "Sınır Aşıldı",
				message: "En fazla 7 kart seçebilirsiniz.",
				isError: true
			)
			return
		}
		
		guard let index = cardData.firstIndex(where: { $0.id == card.id }) else { return }
		
		let isReverted = Bool.random()
		cardData[index].isReverted = isReverted
		cardData[index].image = convertToImageName(from: cardData[index].name)
		selectedCards.append(cardData[index])
	}

    // Kart bilgilerini JSON'dan yükler
    func loadCardData() {
        guard let url = Bundle.main.url(forResource: "tarot2", withExtension: "json") else { return }

        do {
            let data = try Data(contentsOf: url)
            var cards = try JSONDecoder().decode([Card].self, from: data)

            // Kartları karıştır ve ayarla
            cards.shuffle()
            self.cardData = cards.map { card in
                var updatedCard = card
                updatedCard.image = "card_back" // Arka yüz
                updatedCard.isReverted = false
                return updatedCard
            }
        } catch {
            print("Error loading tarot cards: \(error.localizedDescription)")
        }
    }

    // Backend'e veri gönderir ve reklam gösterir
    func processTarotSelection() {
        let selectedTarots = selectedCards.map { card in
            ["key": card.id, "value": card.isReverted]
        }

        let body: [String: Any] = [
            "question": question,
            "selectedTarotsCards": selectedTarots
        ]
        
        sendTarotDataToBackend(body) { success in
            DispatchQueue.main.async {
                if success {
                    // Sekmeyi 0 (Home sekmesi) olarak ayarla

                    // Interstitial reklamı göster
					adManager.displayInterstitialAd()

                } else {
                    showMessage(title: "Hata", message: "Veri gönderilemedi.", isError: true)
                }
            }
        }

    }

    // ViewController almak için
    func getRootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first,
              let rootVC = window.rootViewController else {
            return nil
        }
        return rootVC
    }

    func sendTarotDataToBackend(_ body: [String: Any], completion: @escaping (Bool) -> Void) {
        // Backend API URL'yi buraya girin
        guard let url = URL(string: "https://falsal.com/api/tarot/process/start") else {
            print("Invalid URL")
            completion(false)
            return
        }
        
        // JSON verisini oluştur
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            // URLRequest oluştur
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Keychain'den Auth token'ı al
            if let authToken = Keychain.get(key: "authToken") {
                request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
            } else {
                print("Auth token not found in Keychain")
                completion(false)
                return
            }
            
            request.httpBody = jsonData

            // URLSession ile veri gönder
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // Hata kontrolü
                if let error = error {
                    print("Error sending data to backend: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                // Başarılı yanıt kontrolü
                if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    print("Data successfully sent to backend")
                    
                    completion(true)
                } else {
						Alert(
							title: Text("Falınız Devam Ediyor"),
							message: Text("Falınız halen devam etmekte. Lütfen bitmesini bekleyin."),
							dismissButton: .default(Text("Tamam"))
						)
                    showMessage(title: "Hata", message: "verileri sunucuya ulaştıramadık.", isError: true)
                    print("Failed to send data. Status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                    completion(false)
                }
            }
            
            // Gönderimi başlat
            task.resume()
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            completion(false)
        }
    }


    // Mesaj gösterimi
    func showMessage(title: String, message: String, isError: Bool) {
        DispatchQueue.main.async {
            self.messageTitle = title
            self.messageContent = message
            self.isErrorMessage = isError
            self.showMessage = true
        }
    }

    // Türkçe karakter dönüşümü
    func convertToImageName(from name: String) -> String {
        let turkishToEnglish: [Character: Character] = [
            "ç": "c", "Ç": "C",
            "ğ": "g", "Ğ": "G",
            "ı": "i", "İ": "I",
            "ö": "o", "Ö": "O",
            "ş": "s", "Ş": "S",
            "ü": "u", "Ü": "U"
        ]

        let withoutTurkish = name.map { turkishToEnglish[$0] ?? $0 }
        return String(withoutTurkish).replacingOccurrences(of: " ", with: "-").lowercased()
    }
}

