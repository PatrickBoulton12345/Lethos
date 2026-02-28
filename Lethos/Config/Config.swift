import Foundation

// ⚠️ MOVE ALL KEYS TO A BACKEND BEFORE RELEASE ⚠️
// These are hardcoded for development only.

enum Config {
    // MARK: - OpenAI
    static let openAIAPIKey = "YOUR_OPENAI_API_KEY_HERE"
    static let openAIBaseURL = "https://api.openai.com/v1"
    static let openAIModel = "gpt-4.1"

    // MARK: - Supabase
    static let supabaseURL = "https://mlggtiwpzslvnvqrfybb.supabase.co"
    static let supabaseAnonKey = "sb_publishable_P0w6ntHGMN0Ey8v_AKunWQ_gzMuOKxj"
    static let supabaseStorageBucket = "user-images"
}
