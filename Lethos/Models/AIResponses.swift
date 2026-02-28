import Foundation

// MARK: - Flexible Decoding Helpers

/// Decodes a value that GPT may return as either a String or a number.
struct FlexibleString: Codable {
    let value: String

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            value = str
        } else if let int = try? container.decode(Int.self) {
            value = String(int)
        } else if let dbl = try? container.decode(Double.self) {
            value = String(dbl)
        } else {
            value = ""
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

/// Decodes a value that GPT may return as either an Int or a string number.
struct FlexibleInt: Codable {
    let value: Int?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let int = try? container.decode(Int.self) {
            value = int
        } else if let str = try? container.decode(String.self) {
            value = Int(str)
        } else if let dbl = try? container.decode(Double.self) {
            value = Int(dbl)
        } else {
            value = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

// MARK: - Body Analysis (onboarding photo, cheap call)

struct BodyAnalysisResponse: Codable {
    let buildCategory: String?
    let confidencePercentage: Int
    let estimatedBodyFat: BodyFatRange?
    let notes: String?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case buildCategory = "build_category"
        case confidencePercentage = "confidence_percentage"
        case estimatedBodyFat = "estimated_body_fat"
        case notes
        case error
    }
}

struct BodyFatRange: Codable {
    let rangeLow: Double
    let rangeHigh: Double

    enum CodingKeys: String, CodingKey {
        case rangeLow = "range_low"
        case rangeHigh = "range_high"
    }
}

// MARK: - Goal Physique Analysis (PRO only)

struct PhysiqueAnalysisResponse: Codable {
    let physiqueSummary: String?
    let estimatedBodyFatPercentage: BodyFatRange?
    let buildType: String?
    let muscleEmphasis: MuscleEmphasis?
    let definitionLevel: DefinitionLevel?
    let frame: FrameAnalysis?
    let trainingRecommendation: TrainingRecommendation?
    let nutritionRecommendation: NutritionRecommendation?
    let realisticTimeline: RealisticTimeline?
    let percentageDifferenceFromCurrent: Int?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case physiqueSummary = "physique_summary"
        case estimatedBodyFatPercentage = "estimated_body_fat_percentage"
        case buildType = "build_type"
        case muscleEmphasis = "muscle_emphasis"
        case definitionLevel = "definition_level"
        case frame
        case trainingRecommendation = "training_recommendation"
        case nutritionRecommendation = "nutrition_recommendation"
        case realisticTimeline = "realistic_timeline"
        case percentageDifferenceFromCurrent = "percentage_difference_from_current"
        case error
    }
}

struct MuscleEmphasis: Codable {
    let primary: [String]?
    let secondary: [String]?
    let proportionality: String?
}

struct DefinitionLevel: Codable {
    let overall: String?
    let visibleAbs: String?
    let vascularity: String?
    let muscleSeparation: String?

    enum CodingKeys: String, CodingKey {
        case overall
        case visibleAbs = "visible_abs"
        case vascularity
        case muscleSeparation = "muscle_separation"
    }
}

struct FrameAnalysis: Codable {
    let shoulderWidth: String?
    let vTaper: String?
    let waist: String?
    let limbThickness: String?

    enum CodingKeys: String, CodingKey {
        case shoulderWidth = "shoulder_width"
        case vTaper = "v_taper"
        case waist
        case limbThickness = "limb_thickness"
    }
}

struct TrainingRecommendation: Codable {
    let style: String?
    let priorityMuscles: [String]?
    let trainingSplitSuggestion: String?
    let sessionsPerWeek: Int?

    enum CodingKeys: String, CodingKey {
        case style
        case priorityMuscles = "priority_muscles"
        case trainingSplitSuggestion = "training_split_suggestion"
        case sessionsPerWeek = "sessions_per_week"
    }
}

struct NutritionRecommendation: Codable {
    let strategy: String?
    let targetBodyFatPercentage: BodyFatRange?
    let calorieApproach: String?
    let proteinPriority: String?

    enum CodingKeys: String, CodingKey {
        case strategy
        case targetBodyFatPercentage = "target_body_fat_percentage"
        case calorieApproach = "calorie_approach"
        case proteinPriority = "protein_priority"
    }
}

struct RealisticTimeline: Codable {
    let fromCurrentBodyType: String?
    let estimatedMonthsMinimum: Int?
    let estimatedMonthsMaximum: Int?
    let phases: [TimelinePhase]?
    let achievability: String?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case fromCurrentBodyType = "from_current_body_type"
        case estimatedMonthsMinimum = "estimated_months_minimum"
        case estimatedMonthsMaximum = "estimated_months_maximum"
        case phases
        case achievability
        case notes
    }
}

struct TimelinePhase: Codable {
    let phaseName: String?
    let durationWeeks: Int?
    let focus: String?

    enum CodingKeys: String, CodingKey {
        case phaseName = "phase_name"
        case durationWeeks = "duration_weeks"
        case focus
    }
}

// MARK: - Workout Plan (PRO only)

struct WorkoutPlanResponse: Codable {
    let healthDisclaimer: String?
    let planOverview: PlanOverview?
    let weeklySchedule: [ScheduleDay]?
    let weeklyStructureSummary: String?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case healthDisclaimer = "health_disclaimer"
        case planOverview = "plan_overview"
        case weeklySchedule = "weekly_schedule"
        case weeklyStructureSummary = "weekly_structure_summary"
        case error
    }
}

struct PlanOverview: Codable {
    let planName: String?
    let trainingSplit: String?
    let sessionsPerWeek: Int?
    let planDurationWeeks: Int?
    let currentPhase: String?
    let rationale: String?

    enum CodingKeys: String, CodingKey {
        case planName = "plan_name"
        case trainingSplit = "training_split"
        case sessionsPerWeek = "sessions_per_week"
        case planDurationWeeks = "plan_duration_weeks"
        case currentPhase = "current_phase"
        case rationale
    }
}

struct ScheduleDay: Codable, Identifiable {
    var id: Int { day ?? 0 }
    let day: Int?
    let dayLabel: String?
    let sessionName: String?
    let isRestDay: Bool?
    let estimatedDurationMinutes: Int?
    let sessionGoal: String?
    let description: String?
    let activities: [String]?
    let warmup: [WarmupExercise]?
    let exercises: [WorkoutExercise]?
    let cooldown: [WarmupExercise]?

    enum CodingKeys: String, CodingKey {
        case day = "day_number"
        case dayLabel = "day_label"
        case sessionName = "session_name"
        case isRestDay = "is_rest_day"
        case estimatedDurationMinutes = "estimated_duration_minutes"
        case sessionGoal = "session_goal"
        case description
        case activities
        case warmup = "warmup_exercises"
        case exercises = "main_exercises"
        case cooldown = "cooldown_stretches"
    }
}

struct WarmupExercise: Codable, Identifiable {
    var id: String { exerciseName ?? UUID().uuidString }
    let exerciseName: String?
    let durationSeconds: Int?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case exerciseName = "exercise_name"
        case durationSeconds = "duration_seconds"
        case notes
    }
}

struct WorkoutExercise: Codable, Identifiable {
    var id: Int { order ?? 0 }
    let order: Int?
    let exerciseName: String?
    let equipmentNeeded: String?
    let whyThisExercise: String?
    let musclesTargeted: MusclesTargeted?
    let howToDoIt: HowToDoIt?
    let _sets: FlexibleInt?
    let _reps: FlexibleString?
    let _restSeconds: FlexibleInt?
    let startingWeightGuide: StartingWeightGuide?
    let videoSearchTerm: String?

    var sets: Int? { _sets?.value }
    var reps: String? { _reps?.value }
    var restSeconds: Int? { _restSeconds?.value }

    enum CodingKeys: String, CodingKey {
        case order
        case exerciseName = "exercise_name"
        case equipmentNeeded = "equipment_needed"
        case whyThisExercise = "why_this_exercise"
        case musclesTargeted = "muscles_targeted"
        case howToDoIt = "how_to_do_it"
        case _sets = "sets"
        case _reps = "reps"
        case _restSeconds = "rest_seconds"
        case startingWeightGuide = "starting_weight_guide"
        case videoSearchTerm = "video_search_term"
    }
}

struct MusclesTargeted: Codable {
    let primary: [String]?
    let secondary: [String]?

    enum CodingKeys: String, CodingKey {
        case primary, secondary
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        primary = Self.decodeStringOrArray(from: container, key: .primary)
        secondary = Self.decodeStringOrArray(from: container, key: .secondary)
    }

    private static func decodeStringOrArray(
        from container: KeyedDecodingContainer<CodingKeys>,
        key: CodingKeys
    ) -> [String]? {
        if let array = try? container.decode([String].self, forKey: key) {
            return array
        } else if let string = try? container.decode(String.self, forKey: key) {
            return [string]
        }
        return nil
    }
}

struct HowToDoIt: Codable {
    let setup: String?
    let movementSteps: [String]?
    let commonMistakes: [String]?

    enum CodingKeys: String, CodingKey {
        case setup
        case movementSteps = "movement_steps"
        case commonMistakes = "common_mistakes"
    }
}

struct StartingWeightGuide: Codable {
    let maleBeginner: String?
    let femaleBeginner: String?
    let disclaimer: String?

    enum CodingKeys: String, CodingKey {
        case maleBeginner = "male_beginner"
        case femaleBeginner = "female_beginner"
        case disclaimer
    }
}

// MARK: - Weekly Check-in Coach (PRO only)

struct CheckInResponse: Codable {
    let overallAssessment: String?
    let headline: String?
    let visibleChanges: String?
    let wins: [String]?
    let areasToImprove: [String]?
    let progressPercentageTowardGoal: Int?
    let estimatedWeeksRemaining: Int?
    let weightTrend: String?
    let trainingCompliance: TrainingCompliance?
    let planAdjustments: [PlanAdjustment]?
    let motivationMessage: String?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case overallAssessment = "overall_assessment"
        case headline
        case visibleChanges = "visible_changes"
        case wins
        case areasToImprove = "areas_to_improve"
        case progressPercentageTowardGoal = "progress_percentage_toward_goal"
        case estimatedWeeksRemaining = "estimated_weeks_remaining"
        case weightTrend = "weight_trend"
        case trainingCompliance = "training_compliance"
        case planAdjustments = "plan_adjustments"
        case motivationMessage = "motivation_message"
        case error
    }
}

struct TrainingCompliance: Codable {
    let sessionsCompleted: Int?
    let sessionsPlanned: Int?

    enum CodingKeys: String, CodingKey {
        case sessionsCompleted = "sessions_completed"
        case sessionsPlanned = "sessions_planned"
    }
}

struct PlanAdjustment: Codable {
    let type: String?
    let detail: String?
    let reason: String?
}
