import SwiftUI

struct TarotDetailView: View {
	let tarotId: Int
	@State private var tarotData: TarotData?
	@State private var errorMessage: String?
	@State private var selectedCardImage: String? // Seçilen kartın büyük görüntüsü için
	
	var body: some View {
		NavigationView {
			ZStack {
				LinearGradient(
					colors: [.black, .purple.opacity(0.8)],
					startPoint: .topLeading,
					endPoint: .bottomTrailing
				).ignoresSafeArea()
				
				if let tarotData = tarotData {
					ScrollView(showsIndicators: false) {
						VStack(alignment: .leading, spacing: 16) {
							// Başlık
							Text("Tarot")
								.font(.system(size: 32, weight: .bold))
								.foregroundStyle(LinearGradient(
									colors: [.blue, .purple],
									startPoint: .leading,
									endPoint: .trailing
								))
								.frame(maxWidth: .infinity, alignment: .center)
							
							// Sorunuz
							Text("Soru: \(tarotData.question)")
								.font(.system(size: 24, weight: .bold))
								.foregroundStyle(LinearGradient(
									colors: [.blue, .purple],
									startPoint: .leading,
									endPoint: .trailing
								))
								.multilineTextAlignment(.center)
							
							// Kartlar (Yarım Hilal Düzeni)
							GeometryReader { geometry in
								let radius = geometry.size.width / 2.0
								let cardCount = tarotData.selectedCards.count
								let angleOffset = Double(90 / (cardCount - 1))
								
								ZStack {
									ForEach(Array(tarotData.selectedCards.enumerated()), id: \.1.key) { index, card in
										let angle = angleOffset * Double(index) - 133.5
										TarotCardView(cardId: card.key, isReversed: !card.value)
											.frame(width: 70, height: 100)
											.rotationEffect(.degrees(angle + 90))
											.offset(
												x: radius * cos(angle * .pi / 180),
												y: radius * sin(angle * .pi / 180)
											)
											.onTapGesture {
												showCardDetail(cardId: card.key)
											}
									}
								}
								.frame(width: geometry.size.width, height: radius)
							}
							.padding(.top, 150)
							
							// Falınızın Açıklaması
							VStack(alignment: .leading, spacing: 8) {
								Text("Falınızın açıklaması")
									.font(.system(size: 24, weight: .bold))
									.foregroundStyle(LinearGradient(
										colors: [.blue, .purple],
										startPoint: .leading,
										endPoint: .trailing
									))
									.multilineTextAlignment(.center)
								Divider()
									.background(Color.black.opacity(0.9))
									.frame(height: 4) // Kalınlaştırmak için yükseklik eklenir

								Text(tarotData.message)
									.font(.system(size: 16))
									.foregroundColor(.white)
									.multilineTextAlignment(.leading)
									.lineSpacing(6)
									.padding(.horizontal)
									.padding(.vertical, 8) // Üst ve alt boşluk eklenerek üst kısım daha iyi görünür
									.background(Color.white.opacity(0.1).cornerRadius(8))
								
							}
						}
						.padding(20)
					}
				} else {
					// Yükleniyor ekranı
					ProgressView("Yükleniyor...")
						.foregroundColor(.white)
						.padding()
				}
				
				if let selectedCardImage = selectedCardImage {
					ZStack {
						Color.black.opacity(0.8)
							.ignoresSafeArea()
							.onTapGesture {
								self.selectedCardImage = nil
							}
						
						Image(selectedCardImage)
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 300, height: 400)
							.onTapGesture {
								self.selectedCardImage = nil
							}
					}
				}
			}
			.onAppear {
				fetchTarotDetail(id: tarotId)
			}
			.navigationTitle("Detay")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
	
	
	func showCardDetail(cardId: Int) {
		guard let path = Bundle.main.path(forResource: "tarot2", ofType: "json") else {
			print("JSON dosyası bulunamadı.")
			return
		}
		
		do {
			let data = try Data(contentsOf: URL(fileURLWithPath: path))
			let tarotCards = try JSONDecoder().decode([TarotCardData].self, from: data)
			
			if let card = tarotCards.first(where: { $0.id == cardId }) {
				self.selectedCardImage = card.image
			} else {
				print("Kart ID bulunamadı: \(cardId)")
			}
		} catch {
			print("JSON ayrıştırma hatası: \(error.localizedDescription)")
		}
	}
	
	
	
	func fetchTarotDetail(id: Int) {
		guard let token = Keychain.get(key: "authToken") else {
			print("Token alınamadı!")
			return
		}
		
		guard let url = URL(string: "https://falsal.com/api/tarots/\(id)") else {
			print("Geçersiz URL")
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				DispatchQueue.main.async {
					self.errorMessage = "Hata: \(error.localizedDescription)"
				}
				return
			}
			
			guard let data = data else {
				DispatchQueue.main.async {
					self.errorMessage = "Hata: Veri alınamadı."
				}
				return
			}
			
			do {
				let decodedResponse = try JSONDecoder().decode(TarotDetail.self, from: data)
				DispatchQueue.main.async {
					self.tarotData = decodedResponse.data
				}
			} catch {
				DispatchQueue.main.async {
					self.errorMessage = "JSON Çözümleme Hatası: \(error.localizedDescription)"
				}
			}
		}.resume()
		
		
	}
	
	
	// Modeller
	struct TarotDetail: Decodable {
		var success: Bool
		var status: Int
		var message: String
		var data: TarotData
	}
	
	struct TarotData: Decodable {
		var id: Int
		var question: String
		var message: String
		var selectedCards: [TarotCard]
	}
	
	struct TarotCard: Decodable {
		var key: Int
		var value: Bool
	}
}




#Preview {
	TarotDetailView(tarotId: 12)
}

