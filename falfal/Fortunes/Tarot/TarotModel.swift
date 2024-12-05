    struct Card: Identifiable, Codable, Equatable {
        var id: Int
        var name: String
        var front: String // Kartın ön yüzü
        var revert: String // Kartın ters yüzü
        var enFront: String // İngilizce ön yüz
        var enRevert: String // İngilizce ters yüz
        var image: String // Kartın görseli
        var isReverted: Bool = false // Kartın ters/düz durumu (başlangıçta düz)

        
        enum CodingKeys: String, CodingKey {
            case id, name, image, revert, enFront , enRevert, front
        }
		static func == (lhs: Card, rhs: Card) -> Bool {
				return lhs.id == rhs.id &&
					   lhs.name == rhs.name &&
					   lhs.image == rhs.image &&
					   lhs.isReverted == rhs.isReverted
			}
		
		
    }

    




