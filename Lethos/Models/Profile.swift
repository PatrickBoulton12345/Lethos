import Foundation

enum BodyType: String, Codable, CaseIterable, Identifiable {
    case skinny
    case average
    case skinnyFat = "skinny_fat"
    case overweight
    case obese
    case muscular
    case muscularButOutOfShape = "muscular_but_out_of_shape"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .skinny: return "Skinny"
        case .average: return "Average"
        case .skinnyFat: return "Skinny Fat"
        case .muscular: return "Muscular"
        case .overweight: return "Overweight"
        case .obese: return "Obese"
        case .muscularButOutOfShape: return "Muscular but Out of Shape"
        }
    }

    var description: String {
        switch self {
        case .skinny: return "I'm naturally thin and find it hard to gain weight"
        case .average: return "I'm a pretty normal size, nothing extreme"
        case .skinnyFat: return "I look slim in clothes but soft underneath"
        case .muscular: return "I'm already well-built and train regularly"
        case .overweight: return "I'm carrying extra weight I'd like to lose"
        case .obese: return "I have a lot of weight to lose"
        case .muscularButOutOfShape: return "I used to train but I've let it slip"
        }
    }
}

enum Gender: String, Codable, CaseIterable, Identifiable {
    case male = "M"
    case female = "F"
    case preferNotToSay = "PNTS"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .preferNotToSay: return "Prefer not to say"
        }
    }
}

enum DietaryRequirement: String, Codable, CaseIterable, Identifiable {
    case noRestrictions = "no_restrictions"
    case vegan
    case vegetarian
    case peanutAllergy = "peanut_allergy"
    case lactoseIntolerance = "lactose_intolerance"
    case glutenFree = "gluten_free"
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .noRestrictions: return "No restrictions"
        case .vegan: return "Vegan"
        case .vegetarian: return "Vegetarian"
        case .peanutAllergy: return "Peanut allergy"
        case .lactoseIntolerance: return "Lactose intolerance"
        case .glutenFree: return "Gluten free"
        case .other: return "Other"
        }
    }
}

struct UserProfile: Codable, Identifiable {
    var id: UUID
    var email: String?
    var heightCm: Int?
    var weightKg: Double?
    var age: Int?
    var gender: String?
    var currentBodyType: String?
    var goalPhysiqueType: String?
    var trainingDaysPerWeek: Int
    var equipmentAccess: String
    var dietaryRequirements: [String]
    var isPro: Bool
    var createdAt: Date?
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case heightCm = "height_cm"
        case weightKg = "weight_kg"
        case age
        case gender
        case currentBodyType = "current_body_type"
        case goalPhysiqueType = "goal_physique_type"
        case trainingDaysPerWeek = "training_days_per_week"
        case equipmentAccess = "equipment_access"
        case dietaryRequirements = "dietary_requirements"
        case isPro = "is_pro"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    static var empty: UserProfile {
        UserProfile(
            id: UUID(),
            trainingDaysPerWeek: 3,
            equipmentAccess: "full_gym",
            dietaryRequirements: [],
            isPro: false
        )
    }
}
