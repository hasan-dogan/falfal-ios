import SwiftUI
import Combine

struct CoffeeDetailView: View {
	@State private var coffeeMessage: String = ""
	@State private var imageUrls: [String] = []
	@State private var selectedImage: UIImage? = nil
	@State private var showingImageViewer = false
	@State private var isLoading = true
	@State private var errorMessage: String? = nil
	@State private var currentImageIndex: Int = 0
	@Environment(\.dismiss) private var dismiss
	
	var coffeeId: Int
	
	var body: some View {
		ZStack {
			// Arka Plan
			LinearGradient(
				colors: [
					Color(red: 0.1, green: 0.1, blue: 0.2),
					Color(red: 0.3, green: 0.2, blue: 0.4)
				],
				startPoint: .topLeading,
				endPoint: .bottomTrailing
			)
			.ignoresSafeArea()
			
			if isLoading {
				LoadingView()
			} else if let error = errorMessage {
				ErrorView(message: error)
			} else {
				ScrollView(showsIndicators: false) {
					VStack(spacing: 25) {
						// Başlık
						Text("Kahve Falınız")
							.font(.system(size: 28, weight: .bold, design: .rounded))
							.foregroundStyle(
								LinearGradient(
									colors: [.white, .purple.opacity(0.8)],
									startPoint: .leading,
									endPoint: .trailing
								)
							)
							.padding(.top, 20)
						
						// Görsel Galerisi
						if !imageUrls.isEmpty {
							ImageCarouselView(
								imageUrls: imageUrls,
								selectedImage: $selectedImage,
								currentIndex: $currentImageIndex,
								showingImageViewer: $showingImageViewer
							)
							.frame(height: 250)
						}
						
						// Fal Mesajı
						MessageView(message: coffeeMessage)
					}
					.padding(.bottom, 30)
				}
				.overlay(
					// Büyük görüntüleyici
					ImageViewerOverlay(
						isVisible: showingImageViewer,
						image: selectedImage,
						imageUrls: imageUrls,
						currentIndex: $currentImageIndex,
						onDismiss: { showingImageViewer = false }
					)
				)
			}
		}
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .principal) {
				Text("Fal Detayı")
					.font(.headline)
					.foregroundColor(.white)
			}
			ToolbarItem(placement: .navigationBarLeading) {
				Button(action: { dismiss() }) {
					Image(systemName: "chevron.left")
						.foregroundColor(.white)
				}
			}
		}
		.onAppear {
			loadCoffeeDetail()
		}
	}
	
	private func loadCoffeeDetail() {
		guard let url = URL(string: "https://falsal.com/api/coffee/\(coffeeId)") else {
			errorMessage = "Geçersiz URL"
			isLoading = false
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		
		if let authToken = Keychain.get(key: "authToken") {
			request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
		}
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			DispatchQueue.main.async {
				if let error = error {
					self.errorMessage = "Ağ hatası: \(error.localizedDescription)"
					self.isLoading = false
					return
				}
				
				guard let data = data else {
					self.errorMessage = "Veri alınamadı"
					self.isLoading = false
					return
				}
				
				// Debug için JSON'ı kontrol et
				if let jsonString = String(data: data, encoding: .utf8) {
					print("Gelen JSON:", jsonString)
				}
				
				do {
					let decoder = JSONDecoder()
					let response = try decoder.decode(CoffeeDetailResponse.self, from: data)
					
					// Başarılı decode
					print("Decode başarılı - Message:", response.message)
					print("Coffee ID:", response.data.id)
					print("Image Count:", response.data.images.images.count)
					
					self.coffeeMessage = response.data.message
					self.imageUrls = response.data.images.images.flatMap { $0 }
					self.isLoading = false
				} catch let decodingError as DecodingError {
					switch decodingError {
					case .typeMismatch(let type, let context):
						self.errorMessage = "Tip uyuşmazlığı: \(type) at \(context.codingPath)"
					case .valueNotFound(let type, let context):
						self.errorMessage = "Değer bulunamadı: \(type) at \(context.codingPath)"
					case .keyNotFound(let key, let context):
						self.errorMessage = "Anahtar bulunamadı: \(key) at \(context.codingPath)"
					case .dataCorrupted(let context):
						self.errorMessage = "Veri bozuk: \(context)"
					@unknown default:
						self.errorMessage = "Bilinmeyen decode hatası"
					}
					print("Decode hatası detayı:", decodingError)
					self.isLoading = false
				} catch {
					self.errorMessage = "Genel hata: \(error.localizedDescription)"
					print("Genel hata detayı:", error)
					self.isLoading = false
				}
			}
		}.resume()
	}
}

// MARK: - Yardımcı Görünümler
struct LoadingView: View {
	var body: some View {
		VStack {
			ProgressView()
				.scaleEffect(1.5)
				.tint(.white)
			Text("Falınız Yükleniyor...")
				.font(.system(size: 16, weight: .medium))
				.foregroundColor(.white)
				.padding(.top, 10)
		}
	}
}

struct ErrorView: View {
	let message: String
	
	var body: some View {
		VStack(spacing: 15) {
			Image(systemName: "exclamationmark.triangle")
				.font(.system(size: 40))
				.foregroundColor(.red)
			
			Text("Bir Hata Oluştu")
				.font(.title2.bold())
				.foregroundColor(.white)
			
			Text(message)
				.font(.body)
				.foregroundColor(.white.opacity(0.8))
				.multilineTextAlignment(.center)
				.padding(.horizontal)
		}
		.padding()
		.background(Color.black.opacity(0.5))
		.cornerRadius(15)
	}
}

struct ImageCarouselView: View {
	let imageUrls: [String]
	@Binding var selectedImage: UIImage?
	@Binding var currentIndex: Int
	@Binding var showingImageViewer: Bool
	
	var body: some View {
		TabView(selection: $currentIndex) {
			ForEach(imageUrls.indices, id: \.self) { index in
				if let imageData = Data(base64Encoded: imageUrls[index]),
				   let uiImage = UIImage(data: imageData) {
					Image(uiImage: uiImage)
						.resizable()
						.aspectRatio(contentMode: .fill)
						.frame(maxWidth: .infinity)
						.clipShape(RoundedRectangle(cornerRadius: 20))
						.shadow(radius: 10)
						.padding(.horizontal)
						.tag(index)
						.onTapGesture {
							selectedImage = uiImage
							showingImageViewer = true
						}
				}
			}
		}
		.tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
	}
}

struct MessageView: View {
	let message: String
	
	var body: some View {
		VStack(alignment: .leading, spacing: 15) {
			Text("Falınızın Yorumu")
				.font(.title3.bold())
				.foregroundColor(.white)
			
			Text(message)
				.font(.system(size: 16))
				.foregroundColor(.white.opacity(0.9))
				.lineSpacing(8)
				.padding()
				.background(
					RoundedRectangle(cornerRadius: 15)
						.fill(Color.white.opacity(0.1))
				)
		}
		.padding(.horizontal)
	}
}

struct ImageViewerOverlay: View {
	let isVisible: Bool
	let image: UIImage?
	let imageUrls: [String]
	@Binding var currentIndex: Int
	let onDismiss: () -> Void
	
	var body: some View {
		Group {
			if isVisible, let image = image {
				ZStack {
					Color.black
						.opacity(0.9)
						.ignoresSafeArea()
						.onTapGesture(perform: onDismiss)
					
					TabView(selection: $currentIndex) {
						ForEach(imageUrls.indices, id: \.self) { index in
							if let imageData = Data(base64Encoded: imageUrls[index]),
							   let uiImage = UIImage(data: imageData) {
								Image(uiImage: uiImage)
									.resizable()
									.aspectRatio(contentMode: .fit)
									.tag(index)
							}
						}
					}
					.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
					
					VStack {
						HStack {
							Spacer()
							Button(action: onDismiss) {
								Image(systemName: "xmark.circle.fill")
									.font(.title)
									.foregroundColor(.white)
							}
							.padding()
						}
						Spacer()
					}
				}
			}
		}
	}
}

// Model yapılarını güncelleyelim
struct CoffeeDetailResponse: Codable {
	let success: Bool
	let status: Int
	let message: String
	let data: CoffeeData
}

struct CoffeeData: Codable {
	let id: Int
	let message: String
	let images: CoffeeImages
}

struct CoffeeImages: Codable {
	let images: [String]  // Tek bir string array'i olarak değiştirdik
	
	// Custom decoder ekleyelim
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		// İç içe array'i düz array'e çeviriyoruz
		if let nestedArray = try? container.decode([[String]].self, forKey: .images) {
			self.images = nestedArray.flatMap { $0 }
		} else {
			// Eğer düz array olarak gelirse direkt alalım
			self.images = try container.decode([String].self, forKey: .images)
		}
	}
}
