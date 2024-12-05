import Foundation

enum RelationShipEnum: String, Codable, CaseIterable {
    case married, single, engaged, widowed

    var label: String {
        switch self {
        case .married: return "Evli"
        case .single: return "Bekar"
        case .engaged: return "Nişanlı"
        case .widowed: return "Dul"
        }
    }
}

enum GenderEnum: String, Codable, CaseIterable {
    case male, female, preferNotToSay

    var label: String {
        switch self {
        case .male: return "Erkek"
        case .female: return "Kadın"
        case .preferNotToSay: return "Belirtmek İstemiyorum"
        }
    }
}

enum HasChildrenEnum: String, Codable, CaseIterable {
    case yes, no

    var label: String {
        switch self {
        case .yes: return "Evet"
        case .no: return "Hayır"
        }
    }
}

enum JobStatusEnum: String, Codable, CaseIterable {
    case fullTime, partTime, unemployed

    var label: String {
        switch self {
        case .fullTime: return "Tam Zamanlı"
        case .partTime: return "Yarı Zamanlı"
        case .unemployed: return "Çalışmıyor"
        }
    }
}

enum EducationLevelEnum: String, Codable, CaseIterable {
    case primarySchool, secondarySchool, highSchool, vocationalSchool, university, doctoral

    var label: String {
        switch self {
        case .primarySchool: return "İlköğretim"
        case .secondarySchool: return "Orta Öğretim"
        case .highSchool: return "Lise"
        case .vocationalSchool: return "Meslek Yüksek Okulu"
        case .university: return "Üniversite"
        case .doctoral: return "Yüksek Lisans ve Doktora"
        }
    }
}

struct ResponseData<T: Decodable>: Decodable {
    let data: T
    let message: String?
    let status: Int
    let success: Bool
    
    enum CodingKeys: String, CodingKey {
        case data, message, status, success
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode data dynamically
        data = try container.decode(T.self, forKey: .data)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        status = try container.decode(Int.self, forKey: .status)
        
        // Handle success as either a string or a bool
        if let successString = try? container.decode(String.self, forKey: .success) {
            success = successString.lowercased() == "true"
        } else {
            success = try container.decode(Bool.self, forKey: .success)
        }
    }
}



struct Profile: Codable {
    var id: Int?
    var email: String
    var name: String
    var lastName: String
    var birthDate: String?
    var relationShip: RelationShipEnum?
    var gender: GenderEnum?
    var hasChildren: HasChildrenEnum?
    var jobStatus: JobStatusEnum?
    var educationLevel: EducationLevelEnum?
    
    // Optional: If your backend uses different key names
    enum CodingKeys: String, CodingKey {
        case id, email, name, lastName, birthDate,
             relationShip = "relationShip",
             gender,
             hasChildren = "hasChildren",
             jobStatus = "jobStatus",
             educationLevel = "educationLevel"
    }
}



    


