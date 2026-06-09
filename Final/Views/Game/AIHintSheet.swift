import SwiftUI

struct AIHintSheet: View {
    @Bindable var gameVM: GameViewModel
    let aiService: AIService

    @Binding var question: String
    @Binding var answer: String
    @Binding var isLoading: Bool

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 4)
            }
            .padding(.top, 12)
            .padding(.bottom, 16)

            HStack {
                Label("AI 智慧提示", systemImage: "sparkle")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.4))
                        .font(.title3)
                }
            }
            .padding(.horizontal, 20)

            ScrollView {
                VStack(spacing: 16) {
                    // AI reply area
                    if isLoading {
                        HStack(spacing: 12) {
                            ProgressView()
                                .tint(.purple)
                            Text("AI 思考中…")
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(Color.purple.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    } else if !answer.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("AI 的推理建議", systemImage: "brain.head.profile")
                                .font(.caption.bold())
                                .foregroundColor(.purple.opacity(0.8))
                            Text(answer)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(Color.purple.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Clues context summary
                    if !gameVM.purchasedClues.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("已有線索（AI 可參考）")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.45))
                            ForEach(Array(gameVM.purchasedClues.suffix(3).enumerated()), id: \.offset) { _, c in
                                Text("• \(c.clueText)")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.65))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(20)
            }

            Divider().background(Color.white.opacity(0.1))

            // Input bar
            HStack(spacing: 12) {
                TextField("問 AI 推理方向…", text: $question, axis: .vertical)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .tint(.purple)
                    .focused($isFieldFocused)
                    .lineLimit(1...4)
                    .padding(12)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Button {
                    sendQuestion()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(question.trimmingCharacters(in: .whitespaces).isEmpty
                                         ? .purple.opacity(0.3) : .purple)
                }
                .disabled(question.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(red: 0.05, green: 0.10, blue: 0.28))
        .presentationBackground(Color(red: 0.05, green: 0.10, blue: 0.28))
        .onAppear { isFieldFocused = true }
    }

    private func sendQuestion() {
        let q = question.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return }
        isLoading = true
        answer = ""

        Task {
            do {
                let req = AIHintRequest(
                    hiddenNumbers: gameVM.hiddenNumbers,
                    hiddenColors: gameVM.hiddenColors,
                    cluesSoFar: gameVM.purchasedClues,
                    guessesSoFar: gameVM.guessList,
                    question: q
                )
                answer = try await aiService.fetchHint(req)
            } catch {
                answer = "AI 暫時無法回應，請稍後再試。"
            }
            isLoading = false
        }
    }
}
