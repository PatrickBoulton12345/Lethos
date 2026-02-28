import Foundation
import UIKit

@MainActor
final class OpenAIService: ObservableObject {
    static let shared = OpenAIService()

    private let apiKey = Config.openAIAPIKey
    private let baseURL = Config.openAIBaseURL
    private let model = Config.openAIModel

    private init() {}

    // MARK: - Feature 1: Current Body Analysis (can run before payment)

    func analyseCurrentBody(imageData: Data) async throws -> BodyAnalysisResponse {
        let base64 = imageData.base64EncodedString()

        let systemPrompt = """
        You are a fitness AI that analyses a user's current physique from a photo. Determine their current build category from this list: skinny, average, skinny_fat, overweight, obese, muscular_but_out_of_shape. Also estimate their body fat percentage range and overall body composition. Return ONLY a JSON response with: build_category (string), confidence_percentage (integer 0-100), estimated_body_fat (range_low, range_high), notes (string — brief observation). If the image is unclear or not a body photo, return: {"error": "Unable to analyse", "confidence_percentage": 0}. Return ONLY JSON.
        """

        let userContent: [[String: Any]] = [
            [
                "type": "image_url",
                "image_url": [
                    "url": "data:image/jpeg;base64,\(base64)",
                    "detail": "low"
                ]
            ],
            [
                "type": "text",
                "text": "Analyse this photo of the user to determine their current body type."
            ]
        ]

        let data = try await sendChatRequest(
            systemPrompt: systemPrompt,
            userContent: userContent,
            maxTokens: 500
        )
        return try JSONDecoder().decode(BodyAnalysisResponse.self, from: data)
    }

    // MARK: - Feature 2: Goal Physique Analysis (PRO only)

    func analyseGoalPhysique(
        imageData: Data,
        bodyType: String,
        height: Int,
        weight: Double,
        age: Int,
        gender: String
    ) async throws -> PhysiqueAnalysisResponse {
        let base64 = imageData.base64EncodedString()

        let systemPrompt = """
        You are a fitness AI that analyses physique reference images. Your job is to break down what you see into actionable training and nutrition data. Be specific, realistic, and honest. You will receive: 1. A reference image of the user's desired physique 2. The user's current body type 3. The user's basic stats (height, weight, age, gender). Analyse the reference image and return ONLY a JSON response with these fields: physique_summary (string — 1-2 sentences), estimated_body_fat_percentage (range_low, range_high), build_type (lean/toned/athletic/muscular/heavyweight), muscle_emphasis (primary array, secondary array, proportionality), definition_level (overall, visible_abs, vascularity, muscle_separation), frame (shoulder_width, v_taper, waist, limb_thickness), training_recommendation (style, priority_muscles array, training_split_suggestion, sessions_per_week), nutrition_recommendation (strategy, target_body_fat_percentage range, calorie_approach, protein_priority), realistic_timeline (from_current_body_type, estimated_months_minimum, estimated_months_maximum, phases array with phase_name/duration_weeks/focus, achievability, notes), percentage_difference_from_current (integer — estimated percentage difference between user's current state and this goal physique). Rules: Never assume the person in the image is the user. Be honest about achievability and PED use. Factor in the user's current body type for timelines. If the image is unclear, return an error JSON. Keep estimates conservative. Return ONLY JSON.
        """

        let userContent: [[String: Any]] = [
            [
                "type": "image_url",
                "image_url": [
                    "url": "data:image/jpeg;base64,\(base64)",
                    "detail": "high"
                ]
            ],
            [
                "type": "text",
                "text": "Analyse this physique image. User's current body type: \(bodyType). User stats: \(height)cm, \(weight)kg, age \(age), \(gender)"
            ]
        ]

        let data = try await sendChatRequest(
            systemPrompt: systemPrompt,
            userContent: userContent,
            maxTokens: 2000
        )
        return try JSONDecoder().decode(PhysiqueAnalysisResponse.self, from: data)
    }

    // MARK: - Feature 3: Workout Plan Generator (PRO only)

    func generateWorkoutPlan(
        physiqueAnalysis: PhysiqueAnalysisResponse,
        height: Int,
        weight: Double,
        age: Int,
        gender: String,
        dietaryRequirements: [String]
    ) async throws -> WorkoutPlanResponse {
        let systemPrompt = """
        You are a fitness AI that generates workout plans for ABSOLUTE BEGINNERS. These users have never set foot in a gym. They don't know what a rep is. They are likely nervous and overwhelmed. Your job is to create a precise, detailed, hand-holding workout plan that tells them EXACTLY what to do. Keep it SIMPLE — do NOT overcomplicate it. For each exercise tell them: what muscles it trains, why they need to do it (one simple sentence), how to do it, and what weight to start with. Every exercise must include step-by-step instructions, common mistakes, starting weight suggestions (with health disclaimer), and a YouTube search term for form demos. Return ONLY a JSON response with: health_disclaimer (string), plan_overview (plan_name, training_split, sessions_per_week, plan_duration_weeks, current_phase, rationale), weekly_schedule (array of day objects — each training day has: day number, day_label, session_name, estimated_duration_minutes, session_goal, warmup exercises, main exercises array, cooldown stretches. Each exercise has: order, exercise_name, equipment_needed, why_this_exercise (1 simple sentence), muscles_targeted (primary/secondary), how_to_do_it (setup string, movement_steps array, common_mistakes array), sets, reps, rest_seconds, starting_weight_guide (male_beginner, female_beginner, disclaimer), video_search_term. Rest days have: is_rest_day true, description, activities array), weekly_structure_summary. Rules: Assume they know NOTHING. Max 5-6 exercises per session. Sessions 40-50 minutes max. Compound movements only. Never prescribe barbell squats/deadlifts/bench or pull-ups for beginners — use dumbbell and machine alternatives. Always include warmup and cooldown. Return ONLY JSON.
        """

        let priorityMuscles = physiqueAnalysis.trainingRecommendation?.priorityMuscles ?? []
        let analysisJSON: String
        if let jsonData = try? JSONEncoder().encode(physiqueAnalysis),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            analysisJSON = jsonString
        } else {
            analysisJSON = "{}"
        }

        let userMessage = """
        Generate a beginner workout plan. Physique Analysis: \(analysisJSON). User Stats: \(height)cm, \(weight)kg, age \(age), \(gender). Experience level: never_trained. Available training days: 3. Equipment: full_gym. Session time limit: 45 minutes. Dietary requirements: \(dietaryRequirements.joined(separator: ", ")). Priority muscles: \(priorityMuscles.joined(separator: ", ")). This user has NEVER trained before. Keep it simple.
        """

        let userContent: [[String: Any]] = [
            ["type": "text", "text": userMessage]
        ]

        let data = try await sendChatRequest(
            systemPrompt: systemPrompt,
            userContent: userContent,
            maxTokens: 16000
        )

        do {
            return try JSONDecoder().decode(WorkoutPlanResponse.self, from: data)
        } catch {
            print("[Lethos] Workout decode error: \(error)")
            if let raw = String(data: data, encoding: .utf8) {
                print("[Lethos] Raw workout JSON: \(raw)")
            }
            throw error
        }
    }

    // MARK: - Feature 4: Weekly Check-in Coach (PRO only)

    func weeklyCheckIn(
        currentPhotoData: Data?,
        previousPhotoData: Data?,
        goalAnalysis: PhysiqueAnalysisResponse,
        planOverview: PlanOverview?,
        weight: Double,
        lastWeight: Double?,
        startWeight: Double?,
        sessionsCompleted: Int,
        sessionsPlanned: Int,
        energyLevel: Int,
        userNotes: String,
        weekNumber: Int
    ) async throws -> CheckInResponse {
        let systemPrompt = """
        You are a supportive fitness coach conducting a weekly check-in for an absolute beginner. You will receive: 1. The user's progress photo from THIS week 2. The user's progress photo from LAST week (if available) 3. The user's goal physique analysis 4. Their current workout plan 5. Their check-in data (weight, sessions completed, how they feel). Your job is to: Compare this week's photo to last week's photo and note specific visible changes or achievements. Be encouraging but honest. Calculate an estimated percentage progress toward their goal physique. Estimate remaining time to reach their goal. Suggest any plan adjustments if needed. Return ONLY a JSON response with: overall_assessment (excellent/good/okay/needs_attention), headline (one encouraging sentence referencing something specific), visible_changes (string — specific observations comparing this week to last week), wins (array of strings), areas_to_improve (array of strings), progress_percentage_toward_goal (integer), estimated_weeks_remaining (integer), weight_trend (losing/stable/gaining), training_compliance (sessions_completed vs sessions_planned), plan_adjustments (array of change objects or empty if no changes needed), motivation_message (personalised, references something specific from their data). Rules: Be ENCOURAGING. These are beginners — celebrate small wins. Never say they're failing. Compare photos carefully and note even subtle changes. If no photo from last week, compare to their starting body type description. Return ONLY JSON.
        """

        let goalJSON: String
        if let jsonData = try? JSONEncoder().encode(goalAnalysis),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            goalJSON = jsonString
        } else {
            goalJSON = "{}"
        }

        let planJSON: String
        if let plan = planOverview, let jsonData = try? JSONEncoder().encode(plan),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            planJSON = jsonString
        } else {
            planJSON = "{}"
        }

        var userContent: [[String: Any]] = []

        if let currentPhoto = currentPhotoData {
            userContent.append([
                "type": "image_url",
                "image_url": [
                    "url": "data:image/jpeg;base64,\(currentPhoto.base64EncodedString())",
                    "detail": "high"
                ]
            ])
        }

        if let previousPhoto = previousPhotoData {
            userContent.append([
                "type": "image_url",
                "image_url": [
                    "url": "data:image/jpeg;base64,\(previousPhoto.base64EncodedString())",
                    "detail": "high"
                ]
            ])
        }

        let textMessage = """
        Weekly check-in. Goal physique analysis: \(goalJSON). Current plan: \(planJSON). This week's weight: \(weight)kg. Last week's weight: \(lastWeight.map { "\($0)" } ?? "N/A")kg. Starting weight: \(startWeight.map { "\($0)" } ?? "N/A")kg. Sessions completed this week: \(sessionsCompleted)/\(sessionsPlanned). Energy level (1-10): \(energyLevel). How they feel: \(userNotes). Week number: \(weekNumber).
        """

        userContent.append(["type": "text", "text": textMessage])

        let data = try await sendChatRequest(
            systemPrompt: systemPrompt,
            userContent: userContent,
            maxTokens: 2000
        )
        return try JSONDecoder().decode(CheckInResponse.self, from: data)
    }

    // MARK: - Core API Call

    private func sendChatRequest(
        systemPrompt: String,
        userContent: [[String: Any]],
        maxTokens: Int
    ) async throws -> Data {
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 120

        let body: [String: Any] = [
            "model": model,
            "response_format": ["type": "json_object"],
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userContent]
            ],
            "max_tokens": maxTokens,
            "temperature": 0.3
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("[Lethos OpenAI] HTTP \(statusCode): \(errorBody)")
            throw OpenAIError.apiFailed(errorBody)
        }

        // Extract the content from OpenAI's response wrapper
        let wrapper = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let choices = wrapper?["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String,
              let contentData = content.data(using: .utf8) else {
            throw OpenAIError.parseFailed
        }

        return contentData
    }
}

enum OpenAIError: LocalizedError {
    case apiFailed(String)
    case parseFailed
    case notPro

    var errorDescription: String? {
        switch self {
        case .apiFailed(let msg): return "AI analysis failed: \(msg)"
        case .parseFailed: return "Failed to read AI response. Please try again."
        case .notPro: return "Upgrade to PRO to unlock AI features."
        }
    }
}

// MARK: - Image Compression Helper

extension UIImage {
    func compressedJPEGData(maxSizeKB: Int = 500) -> Data? {
        var compression: CGFloat = 0.8
        var data = self.jpegData(compressionQuality: compression)
        while let d = data, d.count > maxSizeKB * 1024, compression > 0.1 {
            compression -= 0.1
            data = self.jpegData(compressionQuality: compression)
        }
        return data
    }
}
