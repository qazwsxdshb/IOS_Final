import Foundation

// MARK: - Request Types
struct AIAnalysisRequest {
    let hiddenNumbers: [Int]
    let hiddenColors: [String]
    let guessList: [GuessEntry]
    let cluesPurchased: [ClueEntry]
    let result: GameResult
    let totalSpent: Int
}

struct AIHintRequest {
    let hiddenNumbers: [Int]
    let hiddenColors: [String]
    let cluesSoFar: [ClueEntry]
    let guessesSoFar: [GuessEntry]
    let question: String
}

// MARK: - Response Types
struct GameAnalysis: Codable {
    var strategyScore: Int
    var keyDecisions: [String]
    var improvements: [String]
    var summary: String
}

// MARK: - AIService
final class AIService {

    private var apiKey: String {
        UserDefaults.standard.string(forKey: "ai_api_key") ?? ""
    }
    private var providerRaw: String {
        UserDefaults.standard.string(forKey: "ai_provider") ?? "openai"
    }
    private var model: String {
        let m = UserDefaults.standard.string(forKey: "ai_model") ?? ""
        return m.isEmpty ? (AIProvider(rawValue: providerRaw)?.defaultModel ?? "gpt-4o") : m
    }
    private var provider: AIProvider {
        AIProvider(rawValue: providerRaw) ?? .openai
    }

    // MARK: - Public
    func fetchGameAnalysis(_ req: AIAnalysisRequest) async throws -> GameAnalysis {
        let prompt = buildAnalysisPrompt(req)
        let raw = try await callAI(system: analysisSystemPrompt, user: prompt)
        return try parseAnalysis(raw)
    }

    func fetchHint(_ req: AIHintRequest) async throws -> String {
        let prompt = buildHintPrompt(req)
        return try await callAI(system: hintSystemPrompt, user: prompt)
    }

    // MARK: - Unified API Call
    private func callAI(system: String, user: String) async throws -> String {
        switch provider {
        case .anthropic:
            return try await callAnthropic(system: system, user: user)
        case .openai, .gemini, .groq:
            return try await callOpenAIFormat(system: system, user: user)
        }
    }

    // MARK: - OpenAI-compatible (OpenAI / Gemini / Groq)
    private func callOpenAIFormat(system: String, user: String) async throws -> String {
        guard let url = URL(string: provider.baseURL) else { throw AIError.parseError }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "model": model,
            "max_tokens": 1024,
            "messages": [
                ["role": "system", "content": system],
                ["role": "user",   "content": user]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw AIError.httpError((response as? HTTPURLResponse)?.statusCode ?? 0)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let text = message["content"] as? String else {
            throw AIError.parseError
        }
        return text
    }

    // MARK: - Anthropic
    private func callAnthropic(system: String, user: String) async throws -> String {
        guard let url = URL(string: provider.baseURL) else { throw AIError.parseError }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey,             forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01",       forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": model,
            "max_tokens": 1024,
            "system": system,
            "messages": [["role": "user", "content": user]]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw AIError.httpError((response as? HTTPURLResponse)?.statusCode ?? 0)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = (json["content"] as? [[String: Any]])?.first,
              let text = content["text"] as? String else {
            throw AIError.parseError
        }
        return text
    }

    // MARK: - Prompts
    private var analysisSystemPrompt: String {
        """
        你是「數字冒險王」遊戲的 AI 教練。
        玩家已完成一局猜數字遊戲，請根據提供的資料，以繁體中文輸出嚴格的 JSON。
        不要輸出任何 JSON 以外的內容，不加 markdown 包圍符號。
        JSON 格式如下：
        {
          "strategyScore": <1到10的整數>,
          "keyDecisions": ["決策1", "決策2", "決策3"],
          "improvements": ["建議1", "建議2", "建議3"],
          "summary": "一段 50 字以內的整體評語"
        }
        """
    }

    private var hintSystemPrompt: String {
        """
        你是「數字冒險王」遊戲的智慧提示助手。
        玩家正在進行猜數字遊戲，可能會問你邏輯推理問題。
        重要規則：
        1. 絕對不能直接說出任何一位數字或顏色的答案。
        2. 只能提供推理方向、邏輯思路、或建議接下來應該優先購買哪類線索。
        3. 用親切、鼓勵的繁體中文回答，100 字以內。
        """
    }

    private func buildAnalysisPrompt(_ req: AIAnalysisRequest) -> String {
        let guessDesc = req.guessList.enumerated().map { i, g in
            "第\(i+1)次猜[\(g.numbers.map(String.init).joined())]，花費\(g.cost)元，\(g.isCorrect ? "猜對" : "猜錯")"
        }.joined(separator: "\n")

        let clueDesc = req.cluesPurchased.map { c in
            "[\(c.clueType.rawValue)] \(c.clueText)（\(c.cost)元）"
        }.joined(separator: "\n")

        return """
        遊戲結果：\(req.result.rawValue)
        隱藏答案：數字 \(req.hiddenNumbers.map(String.init).joined(separator: "-"))，顏色 \(req.hiddenColors.joined(separator: "-"))
        總花費：\(req.totalSpent) 元

        猜測記錄：
        \(guessDesc.isEmpty ? "（無）" : guessDesc)

        購買線索：
        \(clueDesc.isEmpty ? "（無）" : clueDesc)
        """
    }

    private func buildHintPrompt(_ req: AIHintRequest) -> String {
        let clueDesc = req.cluesSoFar.map { "- \($0.clueText)" }.joined(separator: "\n")
        let guessDesc = req.guessesSoFar.map { "- 猜 \($0.numbers.map(String.init).joined())" }.joined(separator: "\n")

        return """
        玩家目前擁有的線索：
        \(clueDesc.isEmpty ? "（尚無線索）" : clueDesc)

        玩家已猜過：
        \(guessDesc.isEmpty ? "（尚未猜過）" : guessDesc)

        玩家的問題：\(req.question)
        """
    }

    private func parseAnalysis(_ json: String) throws -> GameAnalysis {
        let clean = json.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
        guard let data = clean.data(using: .utf8) else { throw AIError.parseError }
        return try JSONDecoder().decode(GameAnalysis.self, from: data)
    }
}

// MARK: - Errors
enum AIError: LocalizedError {
    case httpError(Int)
    case parseError
    case noAPIKey

    var errorDescription: String? {
        switch self {
        case .httpError(let code): return "API 請求失敗（HTTP \(code)）"
        case .parseError:          return "AI 回傳格式錯誤"
        case .noAPIKey:            return "未設定 API Key"
        }
    }
}
