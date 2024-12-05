import SwiftUI

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
				// Gradient Background
				LinearGradient(
					gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.4)]),
					startPoint: .topLeading,
					endPoint: .bottomTrailing
				)
				.edgesIgnoringSafeArea(.all)
				
				VStack(spacing: 20) {
					// Title with Shadow and Gradient
					Text("Tarot Kartlarınızı Seçin")
						  .font(.system(size: 28, weight: .bold))
						  .foregroundStyle(
							  LinearGradient(
								  colors: [Color.pink, Color.purple],
								  startPoint: .leading,
								  endPoint: .trailing
							  )
						  )
						  .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
						  .padding(.bottom, 10)  // Metni yukarıya kaydırır
					
					// Circular Card Layout
					GeometryReader { geometry in
						ZStack {
							ForEach(cardData) { card in
								cardView(card: card, geometry: geometry)
							}
						}
					}
					.frame(height: 350)
					
					// Selected Cards Display
					selectedCardsView()
					
					// Submit Button with Stylish Design
					submitButton()
				}
				.padding()
				
				// Message Overlay
				if showMessage {
					messageOverlayView()
						.zIndex(1)
				}
			}
			.navigationBarHidden(true)
			.onAppear {
				loadCardData()
				 adManager.loadInterstitialAd()

			}
			.navigationDestination(isPresented: $navigateToCardSelection) {
				HomeView(isLocked: $isLocked, adManager: adManager)
			}
		}
	}
	
	private func cardView(card: Card, geometry: GeometryProxy) -> some View {
		let totalCards = CGFloat(cardData.count)
		let angle = 2 * .pi / totalCards * CGFloat(cardData.firstIndex(where: { $0.id == card.id }) ?? 0)

		// Radius'u ayarlayın, bu dairesel düzenin boyutunu belirler
		let radius: CGFloat = min(geometry.size.width, geometry.size.height) * 0.40  // %35'lik bir oranla ayarlıyoruz

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
				x: (geometry.size.width / 2) - 50 + radius * cos(angle),  // X-offset'i biraz sola kaydırıyoruz
				y: (geometry.size.height / 2) - 50 + radius * sin(angle) // Y-offset değişmeden kalacak
			)
			.onTapGesture {
				withAnimation {
					toggleCardState(card)
				}
			}
			.animation(.spring(), value: selectedCards)
	}

	
	private func selectedCardsView() -> some View {
		HStack(spacing: -20) {
			ForEach(selectedCards) { card in
				Image(card.image)
					.resizable()
					.scaledToFit()
					.frame(width: 50, height: 100)
					.rotationEffect(.degrees(card.isReverted ? 180 : 0))
					.shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
					.transition(.asymmetric(insertion: .scale, removal: .slide))
			}
		}
		.padding(.top, 50)  // Kartları biraz daha aşağıya kaydırır
		.animation(.spring(), value: selectedCards)
	}
	
	// Submit Button
	private func submitButton() -> some View {
		Button(action: {
			processTarotSelection()
			navigateToCardSelection = true
		}) {
			Text("Gönder")
				.font(.headline)
				.foregroundColor(.white)
				.padding()
				.frame(maxWidth: .infinity)
				.background(
					LinearGradient(
						gradient: Gradient(colors: [Color.purple, Color.blue]),
						startPoint: .leading,
						endPoint: .trailing
					)
				)
				.cornerRadius(30)
				.shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 5)
		}
		.disabled(selectedCards.isEmpty)
		.opacity(selectedCards.isEmpty ? 0.6 : 1)
	}
	
	// Message Overlay View
	private func messageOverlayView() -> some View {
		VStack {
			Text(messageTitle)
				.font(.headline)
				.foregroundColor(isErrorMessage ? .red : .green)
			Text(messageContent)
				.font(.body)
				.padding(.top, 8)
			ProgressView()
				.padding(.top, 16)
		}
		.frame(width: 280, height: 200)
		.background(
			RoundedRectangle(cornerRadius: 20)
				.fill(Color.white)
				.shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 5)
		)
		.transition(.scale)
		.onAppear {
			DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
				withAnimation {
					showMessage = false
				}
			}
		}
	}
	
	func toggleCardState(_ card: Card) {
		// Check if the card is already selected
		guard !selectedCards.contains(where: { $0.id == card.id }) else {
			return
		}

		// Limit card selection to 7
		guard selectedCards.count < 7 else {
				print("Limit Exceeded: Showing message") // Debug print
				showMessage(
					title: "Sınır Aşıldı",
					message: "En fazla 7 kart seçebilirsiniz.",
					isError: true
				)
			
				return
			}

		// Find the index of the card in cardData
		guard let index = cardData.firstIndex(where: { $0.id == card.id }) else {
			return
		}

		// Randomly decide card orientation
		let isReverted = Bool.random()

		// Update the card in cardData
		cardData[index].isReverted = isReverted
		cardData[index].image = convertToImageName(from: cardData[index].name)

		// Add the card to selected cards
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

