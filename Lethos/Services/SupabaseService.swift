import Foundation

@MainActor
final class SupabaseService: ObservableObject {
    static let shared = SupabaseService()

    @Published var currentUser: UserProfile?
    @Published var isAuthenticated = false

    private let baseURL: String
    private let anonKey: String
    private var accessToken: String?

    private init() {
        self.baseURL = Config.supabaseURL
        self.anonKey = Config.supabaseAnonKey
    }

    // MARK: - Auth

    func signUp(email: String, password: String) async throws {
        let url = URL(string: "\(baseURL)/auth/v1/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")

        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 300 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw SupabaseError.authFailed(errorBody)
        }

        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        self.accessToken = authResponse.accessToken
        self.isAuthenticated = true

        // Create profile
        var profile = UserProfile.empty
        profile.id = UUID(uuidString: authResponse.user.id) ?? UUID()
        profile.email = email
        try await upsertProfile(profile)
        self.currentUser = profile
    }

    func signIn(email: String, password: String) async throws {
        let url = URL(string: "\(baseURL)/auth/v1/token?grant_type=password")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")

        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 300 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw SupabaseError.authFailed(errorBody)
        }

        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        self.accessToken = authResponse.accessToken
        self.isAuthenticated = true

        // Fetch profile
        let userId = authResponse.user.id
        self.currentUser = try await fetchProfile(userId: userId)
    }

    func signOut() {
        accessToken = nil
        currentUser = nil
        isAuthenticated = false
    }

    // MARK: - Profiles

    func fetchProfile(userId: String) async throws -> UserProfile? {
        let url = URL(string: "\(baseURL)/rest/v1/profiles?id=eq.\(userId)&select=*")!
        let data = try await authenticatedGet(url: url)
        let profiles = try jsonDecoder.decode([UserProfile].self, from: data)
        return profiles.first
    }

    func upsertProfile(_ profile: UserProfile) async throws {
        let url = URL(string: "\(baseURL)/rest/v1/profiles")!
        var request = authenticatedRequest(url: url, method: "POST")
        request.setValue("resolution=merge-duplicates", forHTTPHeaderField: "Prefer")
        request.httpBody = try jsonEncoder.encode(profile)
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 300 else {
            throw SupabaseError.requestFailed
        }
    }

    func updateProfile(_ profile: UserProfile) async throws {
        let url = URL(string: "\(baseURL)/rest/v1/profiles?id=eq.\(profile.id.uuidString)")!
        var request = authenticatedRequest(url: url, method: "PATCH")
        request.httpBody = try jsonEncoder.encode(profile)
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 300 else {
            throw SupabaseError.requestFailed
        }
        self.currentUser = profile
    }

    // MARK: - Physique Analyses

    func savePhysiqueAnalysis(_ analysis: StoredPhysiqueAnalysis) async throws {
        let url = URL(string: "\(baseURL)/rest/v1/physique_analyses")!
        var request = authenticatedRequest(url: url, method: "POST")
        request.httpBody = try jsonEncoder.encode(analysis)
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 300 else {
            throw SupabaseError.requestFailed
        }
    }

    func fetchLatestPhysiqueAnalysis(userId: UUID) async throws -> StoredPhysiqueAnalysis? {
        let url = URL(string: "\(baseURL)/rest/v1/physique_analyses?user_id=eq.\(userId.uuidString)&order=created_at.desc&limit=1")!
        let data = try await authenticatedGet(url: url)
        let results = try jsonDecoder.decode([StoredPhysiqueAnalysis].self, from: data)
        return results.first
    }

    // MARK: - Workout Plans

    func saveWorkoutPlan(_ plan: StoredWorkoutPlan) async throws {
        let url = URL(string: "\(baseURL)/rest/v1/workout_plans")!
        var request = authenticatedRequest(url: url, method: "POST")
        request.httpBody = try jsonEncoder.encode(plan)
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 300 else {
            throw SupabaseError.requestFailed
        }
    }

    func fetchActiveWorkoutPlan(userId: UUID) async throws -> StoredWorkoutPlan? {
        let url = URL(string: "\(baseURL)/rest/v1/workout_plans?user_id=eq.\(userId.uuidString)&is_active=eq.true&order=created_at.desc&limit=1")!
        let data = try await authenticatedGet(url: url)
        let results = try jsonDecoder.decode([StoredWorkoutPlan].self, from: data)
        return results.first
    }

    // MARK: - Weekly Check-ins

    func saveCheckin(_ checkin: WeeklyCheckin) async throws {
        let url = URL(string: "\(baseURL)/rest/v1/weekly_checkins")!
        var request = authenticatedRequest(url: url, method: "POST")
        request.httpBody = try jsonEncoder.encode(checkin)
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 300 else {
            throw SupabaseError.requestFailed
        }
    }

    func fetchCheckins(userId: UUID) async throws -> [WeeklyCheckin] {
        let url = URL(string: "\(baseURL)/rest/v1/weekly_checkins?user_id=eq.\(userId.uuidString)&order=week_number.desc")!
        let data = try await authenticatedGet(url: url)
        return try jsonDecoder.decode([WeeklyCheckin].self, from: data)
    }

    // MARK: - Workout Completions

    func saveCompletion(_ completion: WorkoutCompletion) async throws {
        let url = URL(string: "\(baseURL)/rest/v1/workout_completions")!
        var request = authenticatedRequest(url: url, method: "POST")
        request.httpBody = try jsonEncoder.encode(completion)
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 300 else {
            throw SupabaseError.requestFailed
        }
    }

    func fetchCompletionsThisWeek(userId: UUID) async throws -> [WorkoutCompletion] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let formatter = ISO8601DateFormatter()
        let startString = formatter.string(from: startOfWeek)

        let url = URL(string: "\(baseURL)/rest/v1/workout_completions?user_id=eq.\(userId.uuidString)&completed_at=gte.\(startString)")!
        let data = try await authenticatedGet(url: url)
        return try jsonDecoder.decode([WorkoutCompletion].self, from: data)
    }

    // MARK: - Storage

    func uploadImage(bucket: String = Config.supabaseStorageBucket, path: String, imageData: Data) async throws -> String {
        let url = URL(string: "\(baseURL)/storage/v1/object/\(bucket)/\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 300 else {
            throw SupabaseError.uploadFailed
        }

        return "\(baseURL)/storage/v1/object/public/\(bucket)/\(path)"
    }

    // MARK: - Helpers

    private var jsonEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    private var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private func authenticatedRequest(url: URL, method: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    private func authenticatedGet(url: URL) async throws -> Data {
        let request = authenticatedRequest(url: url, method: "GET")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 300 else {
            throw SupabaseError.requestFailed
        }
        return data
    }
}

// MARK: - Auth Response

private struct AuthResponse: Codable {
    let accessToken: String
    let user: AuthUser

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case user
    }
}

private struct AuthUser: Codable {
    let id: String
}

// MARK: - Errors

enum SupabaseError: LocalizedError {
    case authFailed(String)
    case requestFailed
    case uploadFailed

    var errorDescription: String? {
        switch self {
        case .authFailed(let msg): return "Authentication failed: \(msg)"
        case .requestFailed: return "Request failed. Please try again."
        case .uploadFailed: return "Image upload failed. Please try again."
        }
    }
}
