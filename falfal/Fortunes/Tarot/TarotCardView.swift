import SwiftUI

// Tarot Kartlarını temsil eden model
struct TarotCardData: Decodable {
    let id: Int
    let image: String
}

struct TarotCardView: View {
    let cardId: Int
    let isReversed: Bool
    @State private var cardImageName: String? = nil

    var body: some View {
        VStack {
            if let cardImageName = cardImageName {
                // Kart görselini ekleme
                Image(cardImageName) // JSON'dan alınan görsel adı
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .rotationEffect(.degrees(isReversed ? 180 : 0))
                    .frame(width: 70, height: 100)
            } else {
                ProgressView() // Görsel adı yüklenirken bir gösterge
            }
        }
        .onAppear {
            loadCardImage()
        }
    }

    // JSON'dan görsel adını yükleme işlevi
    func loadCardImage() {
        guard let path = Bundle.main.path(forResource: "tarot2", ofType: "json") else {
            print("JSON dosyası bulunamadı.")
            return
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let tarotCards = try JSONDecoder().decode([TarotCardData].self, from: data)

            // `cardId`'ye göre ilgili kartı bul
            if let card = tarotCards.first(where: { $0.id == cardId }) {
                self.cardImageName = card.image // Görsel adını ayarla
            } else {
                print("Kart ID bulunamadı: \(cardId)")
            }
        } catch {
            print("JSON ayrıştırma hatası: \(error.localizedDescription)")
        }
    }
}
