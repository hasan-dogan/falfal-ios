import SwiftUI
import Combine
import Foundation

struct HomeView: View {
	
	@State private var fortunes: [Fortune] = []
	@State private var isLoading = false
	@State private var errorMessage: String?
	@State private var pendingProgress: Float = 0.0
	@State private var pendingStatus: Bool = false
	@State private var lastUpdateDate: Date = Date() // Zaman kontrolü için
	@State private var isAdButtonDisabled: Bool = false
	@State private var createAt: Date?
	@State private var endDate: Date?
	@State private var serverTime: Date?
	@State private var type: String?
	@State private var id: Int?
	@State private var shortLimit: Int?
	@State private var totalTime: Int?
	@Binding var isLocked: Bool
	@State private var cancellables = Set<AnyCancellable>()
	@State private var progressTimer: AnyCancellable?

	@EnvironmentObject var appState: AppState // AppState erişimi
	
	var adManager =  AdManager()
	
	
	// HomeView
	var body: some View {
		NavigationView {
			ZStack {
				// Better background gradient
				LinearGradient(
					gradient: Gradient(colors: [
						Color(.systemBlue).opacity(0.8),
						Color(.systemGreen).opacity(0.8),
						Color(.systemPurple).opacity(0.8)
					]),
					startPoint: .bottom,
					endPoint: .top
				)
				.ignoresSafeArea()
				
				// Content
				VStack(spacing: 0) {
					if pendingStatus {
						VStack(spacing: 12) {
							Text("Falınıza özenle bakıyoruz ama bunun için biraz beklemeniz gerekecek.")
								.font(.system(size: 15))
								.foregroundColor(Color(.systemCyan))
								.multilineTextAlignment(.center)
								.padding(.horizontal)
							
							HStack(spacing: 12) {
								// Progress bar
								ZStack(alignment: .leading) {
									Capsule()
										.fill(Color(.systemGray4))
										.frame(height: 6)
									
									Capsule()
										.fill(LinearGradient(
											gradient: Gradient(colors: [.blue, .purple]),
											startPoint: .leading,
											endPoint: .trailing
										))
										.frame(width: CGFloat(pendingProgress) * 200, height: 6)
								}
								
								// Ad button
								Button(action: { showAdToReduceTime() }) {
									HStack(spacing: 6) {
										Image(systemName: "play.rectangle.fill")
											.foregroundColor(.blue)
										Text("Reklam İzle")
											.font(.system(size: 14, weight: .medium))
									}
									.padding(.horizontal, 12)
									.padding(.vertical, 8)
									.background(Color(.systemBackground).opacity(0.2))
									.cornerRadius(20)
								}
								.disabled(isAdButtonDisabled)
								.opacity(isAdButtonDisabled ? 0.5 : 1)
							}
							.padding(.horizontal)
							
							Text(formatRemainingTime())
								.font(.system(size: 13))
								.foregroundColor(Color(.systemGray2))
							
							Text("Falın daha hızlı bitmesi için reklam izleyebilirsiniz.")
								.font(.system(size: 13))
								.foregroundColor(Color(.systemCyan))
								.padding(.bottom, 8)
						}
						.padding(.vertical, 16)
						.background(
							RoundedRectangle(cornerRadius: 20)
								.fill(Color(.systemBackground).opacity(0.8))
								.overlay(
									RoundedRectangle(cornerRadius: 20)
										.stroke(.white.opacity(0.8), lineWidth: 0.5)
								)
						)
						.padding(.horizontal)
						.padding(.top, 16)
					}
					
					if fortunes.isEmpty {
						ScrollView(showsIndicators: false) {
							VStack(spacing: 20) {
								Text("Fal Bakmanın Eğlencesi: Kaderin Anahtarı Sizin Ellerinizde")
									.font(.system(size: 22, weight: .bold))
									.multilineTextAlignment(.center)
									.foregroundColor(.white)
									.padding(.top, 30)
								
								Text("Fal bakmak, hayatınıza eğlenceli bir dokunuş katmanın harika bir yoludur. Bu mistik deneyim, günlük rutininizin dışına çıkmanızı sağlar ve bazen size ilham verici ipuçları sunabilir. Ancak, unutmayın ki kaderiniz yalnızca sizin ellerinizdedir. Fal bakmanın büyüsüne kapılmak keyiflidir, ancak gerçek başarılar ve mutluluk, aldığınız kararlarda ve attığınız adımlarda yatar. Hayatınıza yön veren sizsiniz ve geleceğinizi şekillendirme gücü tamamen size ait. Fal bakmayı bir eğlence olarak görüp tadını çıkarın, fakat asıl gücün ve kontrolün sizin elinizde olduğunu asla unutmayın. Geleceğinizi inşa etmek için kendi içsel gücünüzü ve kararlılığınızı kullanın. Ayrıca profilinizde eksik olan bilgilerin doldurulması falın doğruluğu açısından önemlidir. Profilinizi güncelleyerek falınızı daha doğru bir şekilde alabilirsiniz.")
									.font(.system(size: 16))
									.foregroundColor(.white)
									.multilineTextAlignment(.center)
									.padding(.horizontal)
									.padding(.bottom, 20)
							}
							.padding()
							.background(
								RoundedRectangle(cornerRadius: 20)
									.fill(Color(.systemBackground).opacity(0.1))
									.overlay(
										RoundedRectangle(cornerRadius: 20)
											.stroke(.white.opacity(0.1), lineWidth: 0.5)
									)
							)
							.padding()
						}
					} else {
						if isLoading {
							ProgressView()
								.scaleEffect(1.2)
								.tint(.white)
						} else if let errorMessage = errorMessage {
							Text(errorMessage)
								.foregroundColor(.red)
								.padding()
						} else {
							ScrollView(showsIndicators: false) {
								LazyVStack(spacing: 16) {
									ForEach(fortunes, id: \.id) { fortune in
										FortuneCardView(
											title: fortune.type == "Kahve Falı" ? "Kahve Falı" : fortune.question ?? "",
											info: fortune.message,
											redirectView: navigateToDetail(fortune: fortune)
										)
									}
								}
								.padding(.vertical, 16)
							}
						}
					}
				}
			}
			.navigationTitle("Fallarım")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .principal) {
					Text("Fallarım")
						.font(.system(size: 18, weight: .semibold))
						.foregroundColor(.white)
				}
				

			}
			.onAppear {
				fetchDashboardData()
			}
		}
	}
		

	
	
	
	// Kalan süreyi formatlamak için yardımcı bir fonksiyon
 func formatRemainingTime() -> String {
	 guard let totalTime = totalTime, totalTime > 0 else {
		 return "Kalan süre: 0 dakika"
	 }
	 
	 let minutes = totalTime / 60
	 let seconds = totalTime % 60
	 
	 if minutes > 0 {
		 return "Kalan süre: \(minutes) dakika \(seconds) saniye"
	 } else {
		 return "Kalan süre: \(seconds) saniye"
	 }
 }
	
	
	func checkLogin(){
		if Keychain.get(key: "authToken") == nil{
			appState.isAuthenticated = false
			pendingStatus = false
			fortunes = []
		}else{
			appState.isAuthenticated = true
			
		}
	}
	
	
	
	/// Dinamik olarak falın detay sayfasına yönlendirme
	@ViewBuilder
	private func navigateToDetail(fortune: Fortune) -> some View {
		if fortune.type.lowercased() == "tarot" {
			TarotDetailView(tarotId: fortune.id)
		} else if fortune.type.lowercased() == "kahve falı" {
			 CoffeeDetailView(coffeeId: fortune.id)
		} else {
			
			Text("Bu tür için bir detay sayfası bulunamadı.")
		}
	}
	
	func fetchDashboardData() {
		adManager.loadInterstitialAdForHome()
		checkLogin()
		guard let token = Keychain.get(key: "authToken") else {
			print("Auth token bulunamadı")
			return
		}
		
		isLoading = true
		guard let url = URL(string: "https://falsal.com/api/dashboard") else {
			print("API URL yanlış")
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		
		request.cachePolicy = .reloadIgnoringLocalCacheData
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				DispatchQueue.main.async {
					self.isLoading = false
					self.errorMessage = "Bağlantı hatası: \(error.localizedDescription)"
				}
				print("Hata oluştu: \(error.localizedDescription)")
				return
			}
			
			guard let data = data else {
				DispatchQueue.main.async {
					self.isLoading = false
					self.errorMessage = "Sunucudan veri alınamadı."
				}
				print("Gelen veri boş!")
				return
			}
			
			do {
				let decoder = JSONDecoder()
				let jsonResponse = try decoder.decode(DashboardResponse.self, from: data)
				DispatchQueue.main.async {
					self.fortunes = jsonResponse.data.fortunes
					self.handlePendingProcess(jsonResponse.data.pendingProcess)
					self.isLoading = false
				}
			} catch {
				DispatchQueue.main.async {
					self.isLoading = false
					self.errorMessage = "Veri çözümlemesi başarısız: \(error.localizedDescription)"
				}
				print("JSON çözümleme hatası: \(error.localizedDescription)")
			}
		}.resume()
	}
	
	
	func startProgressTracking() {
		// Önce mevcut timer'ı iptal et
		progressTimer?.cancel()
		
		guard let _ = serverTime,
			  let _ = createAt,
			  let _ = endDate else { return }
		
		// Yeni timer'ı başlat
		progressTimer = Timer.publish(every: 1.0, on: .main, in: .common)
			.autoconnect()
			.sink { currentTime in
				guard let currentEndDate = self.endDate,
					  let currentCreateAt = self.createAt else { return }
				
				let totalDuration = currentEndDate.timeIntervalSince(currentCreateAt)
				let elapsedDuration = currentTime.timeIntervalSince(currentCreateAt)
				
				// Kalan süreyi hesapla
				self.totalTime = Int(totalDuration - elapsedDuration)
				
				// Reklam butonu durumunu güncelle
				self.isAdButtonDisabled = totalDuration - elapsedDuration <= 120 || self.shortLimit == 2
				
				// Progress durumunu güncelle
				if elapsedDuration < 0 {
					self.pendingProgress = 0.0
				} else if elapsedDuration >= totalDuration {
					self.pendingProgress = 1.0
					self.pendingStatus = false
					self.isLocked = false
					// Timer'ı durdur
					self.progressTimer?.cancel()
				} else {
					self.pendingProgress = Float(elapsedDuration / totalDuration)
				}
			}
	}

	
	func handlePendingProcess(_ pendingProcess: PendingProcess) {
		if let serverResponseTime = parseDate(from: pendingProcess.serverResponseTime) {
			self.serverTime = serverResponseTime
		}
		if pendingProcess.status,
		   let startDate = parseDate(from: pendingProcess.createAt),
		   let finishDate = parseDate(from: pendingProcess.endDate) {
			self.pendingStatus = true
			self.isLocked = true
			self.createAt = startDate
			self.endDate = finishDate
			self.type = pendingProcess.type
			self.id = pendingProcess.id
			self.shortLimit = pendingProcess.shortLimit
			startProgressTracking()
		} else {
			self.pendingStatus = false
			self.isLocked = false
		}
	}
	
	
	func parseDate(from dateString: String?) -> Date? {
		guard let dateString = dateString else { return nil } // Eğer dateString nil ise direkt nil döner
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Gelen tarih formatı
		return dateFormatter.date(from: dateString) // Tarihi döner
	}
	
	func showAdToReduceTime() {
		// Reklam izleme mantığını buraya ekleyin
		adManager.displayInterstitialAdForHome()
		
		
		if adManager.adIsLoading {
			guard let id = self.id else {
				print("ID değeri nil, işlem gerçekleştirilemiyor.")
				return
			}
			guard let type = self.type else {
				print("Type değeri nil, işlem gerçekleştirilemiyor.")
				return
			}

			sendAdWatchedRequest(type: type, id: id)
			
		}
		
		print("Reklam izleme başlatıldı.")
	}
	
	// Yeni method: API isteği gönderme
	func sendAdWatchedRequest(type: String, id: Int) {
		
		guard let token = Keychain.get(key: "authToken") else {
			print("Auth token bulunamadı")
			return
		}
		
		guard let url = URL(string: "https://falsal.com/api/ad-short") else {
			print("Geçersiz URL")
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		
		let body: [String: Any] = [
			"type": type,
			"id": id
		]
		
		do {
			let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
			request.httpBody = jsonData
			
			updateTimeAfterAd()
			
		} catch {
			print("JSON verisi oluşturulamadı: \(error.localizedDescription)")
			return
		}
		
		
		
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				print("İstek sırasında bir hata oluştu: \(error.localizedDescription)")
				return
			}
			
			// Yanıtı kontrol et
			guard response is HTTPURLResponse else {
				print("HTTP yanıtı geçersiz.")
				return
			}
			
		}
		task.resume()
	}
	
	
	// Reklam izlendikten sonra çağrılacak fonksiyon
	func updateTimeAfterAd() {
		// Önce mevcut timer'ı durdur
		progressTimer?.cancel()
		
		// endDate'i güncelle (5 dakika azalt)
		if let currentEndDate = endDate {
			endDate = currentEndDate.addingTimeInterval(-300) // 5 dakika = 300 saniye
		}
		
		// Progress tracking'i yeniden başlat
		startProgressTracking()
	}
	

	
	// Custom Progress Bar
	struct CustomProgressBar: View {
		var progress: Float
		
		var body: some View {
			GeometryReader { geometry in
				ZStack(alignment: .leading) {
					RoundedRectangle(cornerRadius: 20)
						.frame(height: 20)
						.foregroundColor(Color(.systemGray5))
					RoundedRectangle(cornerRadius: 30)
						.frame(width: geometry.size.width * CGFloat(progress), height: 20)
						.foregroundStyle(LinearGradient(
							colors: [.blue, .purple],
							startPoint: .leading,
							endPoint: .trailing
						))            }
			}
		}
	}
	
	
	
	struct Fortune: Identifiable, Decodable {
		let id: Int
		let date: String
		let type: String
		let page: String
		let question: String? // Opsiyonel hale getiriyoruz
		let message: String
	}
	
	struct PendingProcess: Decodable {
		var status: Bool
		var createAt: String?
		var endDate: String?
		var serverResponseTime: String
		var type: String?
		var id: Int?
		var shortLimit: Int?
		
		enum CodingKeys: String, CodingKey {
			case status
			case createAt = "createAt" // JSON'daki anahtar adı
			case endDate = "endDate"
			case serverResponseTime = "serverResponseTime"
			case type = "type"
			case id
			case shortLimit
		}
	}
	
	struct DataWrapper: Decodable {
		var fortunes: [Fortune]
		var pendingProcess: PendingProcess
	}
	
	struct DashboardResponse: Decodable {
		var message: String
		var success: Bool
		var status: Int
		var data: DataWrapper
	}
	
	struct DetailView: View {
		var fortune: Fortune
		
		var body: some View {
			VStack(alignment: .leading, spacing: 16) {
				// Eğer fortune.question varsa, onu göster, yoksa "Kahve Falı" yaz
				Text(fortune.question ?? "Kahve Falı")
					.font(.largeTitle)
					.padding(.bottom, 8)
				
				Text("Tarih: \(fortune.date)")
					.font(.subheadline)
					.foregroundColor(.secondary)
				
				Text("Tür: \(fortune.type)")
					.font(.subheadline)
					.foregroundColor(.secondary)
				
				Text(fortune.message)
					.font(.body)
					.padding(.top, 16)
				
				Spacer()
			}
			.padding()
		}
	}
	
	
	
}


