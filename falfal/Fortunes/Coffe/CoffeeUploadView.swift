import SwiftUI

struct CoffeeUploadView: View {
	var adManager: AdManager
	@EnvironmentObject var appState: AppState // AppState erişimi

	@State private var selectedImages: [UIImage] = []
	@State private var showingImagePicker = false
	@State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
	@State private var navigateToupload = false

	private let maxImages = 6
	private let minImages = 3
	
	var body: some View {
		if !appState.isAuthenticated {
			return AnyView(AuthView(user: .constant(nil), backgroundImage: Image("Falsal"))) // Burada AuthView'e yönlendiriyoruz
		} else {
			return AnyView(
				NavigationView {
					ZStack {
						// Sabit arka plan gradyanı
						LinearGradient(
							gradient: Gradient(colors: [
								Color(red: 0.6, green: 0.4, blue: 0.8), // Açık mor
								Color(red: 0.3, green: 0.5, blue: 0.9), // Koyu mavi
								Color(red: 0.3, green: 0.9, blue: 0.3)  // koyu yeşil
							]),
							startPoint: .topLeading,
							endPoint: .bottomTrailing
						)
						.ignoresSafeArea()
						
						// Ana içerik
						ScrollView(.vertical, showsIndicators: false) {
							VStack(spacing: 24) {
								// Başlık alanı
								VStack(spacing: 12) {
									Text("Kahve Falı Görsellerini Yükle")
										.font(.system(size: 28, weight: .bold, design: .rounded))
										.foregroundColor(.white)
										.multilineTextAlignment(.center)
										.padding(.horizontal)
									
									Text("En az \(minImages), en fazla \(maxImages) görsel yükleyebilirsiniz")
										.font(.system(size: 16, weight: .medium, design: .rounded))
										.foregroundColor(.white.opacity(0.9))
								}
								.padding(.top, 20)
								
								// Fotoğraf grid alanı
								LazyVGrid(
									columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3),
									spacing: 20
								) {
									// Yüklenen görseller
									ForEach(selectedImages.indices, id: \.self) { index in
										ZStack(alignment: .topTrailing) {
											Image(uiImage: selectedImages[index])
												.resizable()
												.aspectRatio(contentMode: .fill)
												.frame(width: 110, height: 110)
												.clipShape(RoundedRectangle(cornerRadius: 16))
												.shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
												.overlay(
													RoundedRectangle(cornerRadius: 16)
														.stroke(Color.white.opacity(0.3), lineWidth: 1)
												)
											
											// Silme butonu
											Button(action: { selectedImages.remove(at: index) }) {
												Image(systemName: "xmark.circle.fill")
													.font(.system(size: 22))
													.foregroundColor(.white)
													.background(Circle().fill(Color.black.opacity(0.5)))
											}
											.padding(8)
										}
									}
									
									// Yeni görsel ekleme butonları
									if selectedImages.count < maxImages {
										ForEach(0..<(maxImages - selectedImages.count), id: \.self) { _ in
											Button(action: {
												showingImagePicker = true
												sourceType = .photoLibrary
											}) {
												VStack(spacing: 12) {
													Image(systemName: "plus.circle.fill")
														.font(.system(size: 32))
														.foregroundColor(.white)
													
													Text("Fotoğraf Ekle")
														.font(.system(size: 14, weight: .medium))
														.foregroundColor(.white)
												}
												.frame(width: 110, height: 110)
												.background(Color.white.opacity(0.2))
												.clipShape(RoundedRectangle(cornerRadius: 16))
												.overlay(
													RoundedRectangle(cornerRadius: 16)
														.stroke(Color.white.opacity(0.3), lineWidth: 1)
												)
											}
										}
									}
								}
								.padding(.horizontal, 16)
								
								// Kamera ve galeri butonları
								HStack(spacing: 16) {
									Button(action: {
										showingImagePicker = true
										sourceType = .camera
									}) {
										HStack {
											Image(systemName: "camera.fill")
												.font(.system(size: 18))
											Text("Kameradan Çek")
												.font(.system(size: 16, weight: .medium))
										}
										.frame(maxWidth: .infinity)
										.frame(height: 50)
										.background(Color.white.opacity(0.2))
										.foregroundColor(.white)
										.clipShape(RoundedRectangle(cornerRadius: 12))
										.overlay(
											RoundedRectangle(cornerRadius: 12)
												.stroke(Color.white.opacity(0.3), lineWidth: 1)
										)
									}
									
									Button(action: {
										showingImagePicker = true
										sourceType = .photoLibrary
									}) {
										HStack {
											Image(systemName: "photo.fill")
												.font(.system(size: 18))
											Text("Galeriden Seç")
												.font(.system(size: 16, weight: .medium))
										}
										.frame(maxWidth: .infinity)
										.frame(height: 50)
										.background(Color.white.opacity(0.2))
										.foregroundColor(.white)
										.clipShape(RoundedRectangle(cornerRadius: 12))
										.overlay(
											RoundedRectangle(cornerRadius: 12)
												.stroke(Color.white.opacity(0.3), lineWidth: 1)
										)
									}
								}
								.padding(.horizontal, 16)
								
								// Gönder butonu
								Button(action: uploadImages) {
									HStack {
										Text("Falımı Gönder")
											.font(.system(size: 18, weight: .semibold))
										
										Image(systemName: "arrow.right.circle.fill")
											.font(.system(size: 20))
									}
									.frame(maxWidth: .infinity)
									.frame(height: 56)
									.background(
										selectedImages.count >= minImages ?
										Color(red: 0.2, green: 0.8, blue: 0.4) : // Yeşil
										Color.gray.opacity(0.5)
									)
									.foregroundColor(.white)
									.clipShape(RoundedRectangle(cornerRadius: 16))
									.overlay(
										RoundedRectangle(cornerRadius: 16)
											.stroke(Color.white.opacity(0.3), lineWidth: 1)
									)
								}
								.disabled(selectedImages.count < minImages)
								.padding(.horizontal, 16)
								.padding(.top, 8)
							}
							.padding(.bottom, 32)
						}
					}
					.navigationTitle("Fal Fotoğrafları")
					.navigationBarTitleDisplayMode(.inline)
					.toolbarBackground(Color(red: 0.6, green: 0.4, blue: 0.8), for: .navigationBar)
					.toolbarBackground(.visible, for: .navigationBar)
					.toolbarColorScheme(.dark, for: .navigationBar)
					.sheet(isPresented: $showingImagePicker) {
						ImagePicker(sourceType: sourceType) { image in
							if let image = image, selectedImages.count < maxImages {
								selectedImages.append(image)
							}
						}
					}
					.navigationDestination(isPresented: $navigateToupload) {
						TabBarView(adManager: AdManager()).environmentObject(AppState())
					}
					.onAppear {
						adManager.loadInterstitialAdForCoffe()
					}
				}
			)
		}
	}
	
	private func uploadImages() {
		// Her bir görsel için ayrı array oluştur
		let base64Images = selectedImages.compactMap { image -> [String]? in
			guard let resizedImage = resizeImage(image, toWidth: 600, toHeight: 450),
				  let imageData = resizedImage.jpegData(compressionQuality: 0.5) else {
				return nil
			}
			// Her bir base64 stringini array içinde döndür
			return [imageData.base64EncodedString()]
		}
		
		// JSON formatını düzelt
		let jsonPayload: [String: Any] = [
			"images": [
				"images": base64Images  // base64Images artık [[String]] tipinde
			]
		]
		
		guard let url = URL(string: "https://falsal.com/api/coffee/process/start"),
			  let authToken = Keychain.get(key: "authToken") else {
			print("URL veya token hatası")
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
		request.setValue("chunked", forHTTPHeaderField: "Transfer-Encoding")
		
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: jsonPayload)
			
			URLSession.shared.dataTask(with: request) { data, response, error in
				if let error = error {
					print("Upload hatası: \(error.localizedDescription)")
					return
				}
				
				if let httpResponse = response as? HTTPURLResponse,
				   (200...299).contains(httpResponse.statusCode) {
					DispatchQueue.main.async {
						navigateToupload = true
						adManager.displayInterstitialAdForCoffe()
					}
				} else if let data = data,
						  let responseString = String(data: data, encoding: .utf8) {
					print("Sunucu yanıtı: \(responseString)")
				}
			}.resume()
			
		} catch {
			print("JSON hatası: \(error.localizedDescription)")
		}
	}

	// Görüntü yeniden boyutlandırma fonksiyonunu optimize et
	private func resizeImage(_ image: UIImage, toWidth width: CGFloat, toHeight height: CGFloat) -> UIImage? {
		let size = CGSize(width: width, height: height)
		
		UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
		image.draw(in: CGRect(origin: .zero, size: size))
		let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return resizedImage
	}
}
