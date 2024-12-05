import SwiftUI

struct TarotQuestionView: View {
	@State private var question = ""
	@State private var navigateToCardSelection = false
	@State var adManager: AdManager // Use ObservedObject for AdManager
	@EnvironmentObject var appState: AppState // AppState erişimi

	var body: some View {
		// Kullanıcı giriş yapmamışsa AuthView'e yönlendir
		if !appState.isAuthenticated {
			return AnyView(AuthView()) // Burada AuthView'e yönlendiriyoruz
		}else{
			return AnyView(
			NavigationStack {
				ZStack {
					// Arka plan gradient
					LinearGradient(
						gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.black]),
						startPoint: .top,
						endPoint: .bottom
					)
					.ignoresSafeArea()
					
					VStack(spacing: 30) {
						// Başlık
						Text("Tarot Sorunuzu Girin")
							.font(.largeTitle)
							.fontWeight(.bold)
							.foregroundColor(.white)
							.multilineTextAlignment(.center)
							.padding(.top, 20)
						
						// Açıklama
						Text("Hayatınızla ilgili bir soruya cevap bulmak için bir soru yazın ve kartları seçin.")
							.font(.body)
							.foregroundColor(.white.opacity(0.8))
							.multilineTextAlignment(.center)
							.padding(.horizontal, 40)
						
						// Soru Girişi
						VStack(alignment: .leading, spacing: 10) {
							Text("Sorunuzu buraya yazın:")
								.font(.headline)
								.foregroundColor(.white)
							
							TextField("Örneğin: 'Kariyerimde ilerleyecek miyim?'", text: $question)
								.padding()
								.background(Color.white.opacity(0.1))
								.cornerRadius(12)
								.foregroundColor(.white)
								.font(.body)
								.overlay(
									RoundedRectangle(cornerRadius: 12)
										.stroke(Color.white.opacity(0.5), lineWidth: 1)
								)
								.padding(.horizontal)
								.onChange(of: question) { newValue in
									// Metni 100 karakterle sınırla
									if newValue.count > 100 {
										question = String(newValue.prefix(100))
									}
								}
							
							// Karakter sayacı
							Text("\(question.count)/100 karakter")
								.font(.caption)
								.foregroundColor(question.count < 8 || question.count > 100 ? .red : .green)
								.padding(.horizontal)
						}
						
						// Tamam Butonu
						Button(action: {
							navigateToCardSelection = true
						}) {
							Text("Tamam")
								.font(.headline)
								.foregroundColor(.white)
								.padding()
								.frame(maxWidth: .infinity)
								.background(
									LinearGradient(gradient: Gradient(colors: [Color.pink, Color.blue]), startPoint: .leading, endPoint: .trailing)
								)
								.cornerRadius(20)
								.shadow(color: Color.pink.opacity(0.5), radius: 10, x: 0, y: 4)
						}
						.padding(.horizontal, 40)
						.disabled(question.count < 8 || question.count > 100) // Minimum ve maksimum karakter kontrolü
						
						Spacer()
					}
				}
				.navigationDestination(isPresented: $navigateToCardSelection) {
					TarotCardSelectionView(adManager: adManager, question: question)
						  }
			}
			)
		}
	}
}


