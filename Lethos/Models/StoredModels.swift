import Foundation

struct StoredPhysiqueAnalysis: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let goalImageUrl: String?
    let analysisJson: PhysiqueAnalysisResponse?
    let percentageDifference: Int?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case goalImageUrl = "goal_image_url"
        case analysisJson = "analysis_json"
        case percentageDifference = "percentage_difference"
        case createdAt = "created_at"
    }
}

struct StoredWorkoutPlan: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let physiqueAnalysisId: UUID?
    let planJson: WorkoutPlanResponse?
    let isActive: Bool
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case physiqueAnalysisId = "physique_analysis_id"
        case planJson = "plan_json"
        case isActive = "is_active"
        case createdAt = "created_at"
    }
}

struct WeeklyCheckin: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let weekNumber: Int
    let photoUrl: String?
    let weightKg: Double?
    let sessionsCompleted: Int?
    let sessionsPlanned: Int?
    let energyLevel: Int?
    let userNotes: String?
    let aiResponseJson: CheckInResponse?
    let progressPercentage: Int?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case weekNumber = "week_number"
        case photoUrl = "photo_url"
        case weightKg = "weight_kg"
        case sessionsCompleted = "sessions_completed"
        case sessionsPlanned = "sessions_planned"
        case energyLevel = "energy_level"
        case userNotes = "user_notes"
        case aiResponseJson = "ai_response_json"
        case progressPercentage = "progress_percentage"
        case createdAt = "created_at"
    }
}

struct WorkoutCompletion: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let workoutPlanId: UUID
    let dayNumber: Int
    let completedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case workoutPlanId = "workout_plan_id"
        case dayNumber = "day_number"
        case completedAt = "completed_at"
    }
}
