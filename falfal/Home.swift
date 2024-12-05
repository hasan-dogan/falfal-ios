import SwiftUI

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
	@Binding var isLocked: Bool
	
	@EnvironmentObject var appState: AppState // AppState erişimi
	
	var adManager =  AdManager()
	
	
	var body: some View {
		NavigationView {
			VStack {
				// Progress Bar, fal durumu kontrolünden bağımsız olarak gösteriliyor
				if pendingStatus {
					VStack(spacing: 8) {
							   Text("Falınıza özenle bakıyoruz ama bunun için biraz beklemeniz gerekecek.")
								   .font(.subheadline)
								   .fontWeight(.medium)
								   .foregroundColor(.gray)
								   .multilineTextAlignment(.center)
								   .foregroundColor(.white)
								   .padding(.horizontal)
							   
							   HStack {
								   // Custom Progress Bar with Gradient and Animation
								   ZStack(alignment: .leading) {
									   RoundedRectangle(cornerRadius: 10)
										   .fill(Color.gray.opacity(0.3))
										   .frame(height: 20)
									   
									   RoundedRectangle(cornerRadius: 10)
										   .fill(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing))
										   .frame(width: CGFloat(pendingProgress) * 200, height: 20)
										   .animation(.easeInOut(duration: 0.5), value: pendingProgress)
								   }
								   .frame(height: 20)
								   .padding(.trailing, 8)
								   
								   // "Reklam İzle" Button
								   Button(action: {
									   showAdToReduceTime()
								   }) {
									   HStack(spacing: 4) {
										   Image(systemName: "play.rectangle.fill")
											   .foregroundColor(.blue)
										   Text("Reklam İzle")
											   .font(.system(size: 14, weight: .bold))
											   .foregroundColor(.blue)
									   }
									   .padding(.horizontal, 12)
									   .padding(.vertical, 6)
									   .background(Color(.systemGray6))
									   .cornerRadius(8)
								   }
								   .disabled(isAdButtonDisabled) // Butonu pasif yap
								   .opacity(isAdButtonDisabled ? 0.5 : 1) // Buton pasif olduğunda opaklık değeri azaltılır
								   .foregroundColor(isAdButtonDisabled ? .gray : .blue) // Butonun rengini değiştirme
							   }
							   .onAppear {
								   adManager.loadInterstitialAd()
							   }
							   .padding(.horizontal)
							   
							   Text("Falın daha hızlı bitmesi için reklam izleyebilirsiniz.")
								   .font(.footnote)
								   .foregroundColor(.gray)
								   .padding(.horizontal)
						   }
						   .padding(.top)
						   .overlay(
								   // Üst border normal
								   RoundedRectangle(cornerRadius: 15)
									   .stroke(
										   LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing),
										   lineWidth: 1
									   )
									   .padding(.top, 12) // Alt kenarın üstten biraz uzaklaşması için
									   .shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 0) // Glow efekti
						   )
						   .onChange(of: pendingProgress) { _ in
						   }
					   }
				
				// Fal durumu kontrolü
				if fortunes.isEmpty {
					ScrollView(showsIndicators: false) {
						VStack(spacing: 16) {
							Text("Fal Bakmanın Eğlencesi: Kaderin Anahtarı Sizin Ellerinizde")
								.font(.title2)
								.fontWeight(.bold)
								.multilineTextAlignment(.center)
								.padding()
							
							Text("Fal bakmak, hayatınıza eğlenceli bir dokunuş katmanın harika bir yoludur. Bu mistik deneyim, günlük rutininizin dışına çıkmanızı sağlar ve bazen size ilham verici ipuçları sunabilir. Ancak, unutmayın ki kaderiniz yalnızca sizin ellerinizdedir. Fal bakmanın büyüsüne kapılmak keyiflidir, ancak gerçek başarılar ve mutluluk, aldığınız kararlarda ve attığınız adımlarda yatar. Hayatınıza yön veren sizsiniz ve geleceğinizi şekillendirme gücü tamamen size ait. Fal bakmayı bir eğlence olarak görüp tadını çıkarın, fakat asıl gücün ve kontrolün sizin elinizde olduğunu asla unutmayın. Geleceğinizi inşa etmek için kendi içsel gücünüzü ve kararlılığınızı kullanın. Ayrıca profilinizde eksik olan bilgilerin doldurulması falın doğruluğu açısından önemlidir. Profilinizi güncelleyerek falınızı daha doğru bir şekilde alabilirsiniz.")
								.font(.body)
								.foregroundColor(.gray)
								.multilineTextAlignment(.center)
								.padding(15)
						}
					}
					.padding()
				} else {
					// Eğer fal varsa bunları göster
					if isLoading {
						ProgressView("Yükleniyor...")
					} else if let errorMessage = errorMessage {
						Text(errorMessage)
							.foregroundColor(.red)
							.padding()
					} else {
						ScrollView (showsIndicators: false){
							VStack(spacing: 16) {
								ForEach(fortunes, id: \.id) { fortune in
									NavigationLink(
										destination: navigateToDetail(fortune: fortune)
									) {
										VStack {
											HStack {
											}
											.foregroundStyle(.primary)
											HStack(spacing: 16) {
												Image("tarot")
													.renderingMode(.original)
													.resizable()
													.aspectRatio(contentMode: .fill)
													.frame(width: 109)
													.clipped()
													.mask { RoundedRectangle(cornerRadius: 26, style: .continuous) }
												VStack(spacing: 2) {
													Text(fortune.question)
														.frame(maxWidth: .infinity, alignment: .center)
														.clipped()
														.font(.system(.callout, weight: .semibold))
														.foregroundStyle(LinearGradient(
															colors: [.blue, .purple],
															startPoint: .leading,
															endPoint: .trailing
														))
													Text(fortune.message.prefix(100) + "...")
														.frame(maxWidth: .infinity, alignment: .leading)
														.clipped()
														.font(.system(.footnote, weight: .regular))
														.foregroundStyle(.white)
												}
											}
											HStack {
												Text(fortune.date)
													.foregroundStyle(LinearGradient(
														colors: [.blue, .purple],
														startPoint: .leading,
														endPoint: .trailing
													))
													.font(.system(.footnote, weight: .semibold))
													.padding(5)
													.padding(.horizontal, 2)
													.background {
														RoundedRectangle(cornerRadius: 14, style: .continuous)
															.fill(.green.opacity(0.06))
													}
											}
											.frame(maxWidth: .infinity, alignment: .leading)
											
										}
										.padding(19)
										.frame(alignment: .top)
										.clipped()
										.foregroundStyle(.primary.opacity(0.5))
										.background {
											RoundedRectangle(cornerRadius: 4, style: .circular)
												.stroke(.blue, lineWidth: 1)
												.background(RoundedRectangle(cornerRadius: 4, style: .circular).fill(Color(.secondarySystemBackground)))
												.shadow(color: .blue.opacity(0.5), radius: 11, x: 0, y: 4)
										}
										.foregroundStyle(Color(.secondarySystemBackground))
										.mask { RoundedRectangle(cornerRadius: 20, style: .continuous) }
										
									}
								}
							}
						}
						.padding(.horizontal, 16)
					}
				}
			}
			.onAppear {
				fetchDashboardData()
			}
		}
		.background(Color.black)
		.edgesIgnoringSafeArea(.all)
		.preferredColorScheme(.dark)
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
		} else if fortune.type.lowercased() == "coffee" {
			// CoffeeDetailView(id: fortune.id)
		} else {
			Text("Bu tür için bir detay sayfası bulunamadı.")
		}
	}
	
	func fetchDashboardData() {
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
	
	func handlePendingProcess(_ pendingProcess: PendingProcess) {
		if let serverResponseTime = parseDate(from: pendingProcess.serverResponseTime) {
			self.serverTime = serverResponseTime
		}
		print(pendingProcess)
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
			calculateProgress()
		} else {
			self.pendingStatus = false
			self.isLocked = false
		}
	}
	
	func calculateProgress() {
		guard let serverTime = serverTime, let createAt = createAt, let endDate = endDate else { return }
		let totalDuration = endDate.timeIntervalSince(createAt)
		let elapsedDuration = serverTime.timeIntervalSince(createAt)
	
		
		if totalDuration - elapsedDuration <= 120 {
			isAdButtonDisabled = true
		} else {
			isAdButtonDisabled = false
		}
		// 2. Eğer shortLimit = 2 ise
		if shortLimit == 2 {

			isAdButtonDisabled = true
		}
		
		if elapsedDuration < 0 {
			self.pendingProgress = 0.0
		} else if elapsedDuration >= totalDuration {
			self.pendingProgress = 1.0
			self.pendingStatus = false // İşlem tamamlanınca gizle
			self.isLocked = false
		} else {
			self.pendingProgress = Float(elapsedDuration / totalDuration)
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				self.calculateProgress() // Her saniye yeniden hesapla
			}
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
			
			if let jsonString = String(data: jsonData, encoding: .utf8) {
				  print("Gönderilen Veri (JSON): \(jsonString)")
			  }
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
			guard let httpResponse = response as? HTTPURLResponse else {
				print("HTTP yanıtı geçersiz.")
				return
			}
			
			print("HTTP Durum Kodu: \(httpResponse.statusCode)")
			print("HTTP Header'ları: \(httpResponse.allHeaderFields)")
			
			if let data = data {
				print("Ham Yanıt Verisi: \(String(data: data, encoding: .utf8) ?? "Veri okunamadı")")
				do {
					let json = try JSONSerialization.jsonObject(with: data, options: [])
					print("JSON Yanıtı: \(json)")
				} catch {
					print("Gelen yanıt JSON formatında değil: \(error.localizedDescription)")
				}
			} else {
				print("Yanıt verisi alınamadı.")
			}
		}
		task.resume()
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
		let question: String
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
				Text(fortune.question)
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
			.navigationTitle("Detay")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
	
	
	
}


