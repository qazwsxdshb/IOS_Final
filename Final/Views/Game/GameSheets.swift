import SwiftUI

// MARK: - Guess Input Sheet
struct GuessInputSheet: View {
    @Bindable var gameVM: GameViewModel
    var profile: PlayerProfile?
    var onResult: (GameViewModel.GuessResult) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            // Handle bar
            Capsule()
                .fill(Color.white.opacity(0.2))
                .frame(width: 40, height: 4)
                .padding(.top, 12)

            Text("輸入你的猜測")
                .font(.headline)
                .foregroundColor(.white)

            // 3 digit pickers
            HStack(spacing: 16) {
                ForEach(0..<3) { i in
                    VStack(spacing: 6) {
                        Text("第\(i+1)位")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))

                        Picker("", selection: $gameVM.guessInput[i]) {
                            ForEach(0...9, id: \.self) { n in
                                Text("\(n)")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .tag(n)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80, height: 100)
                        .clipped()
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }

            // Cost display
            Text("本次費用：\(gameVM.nextGuessCost) 元")
                .font(.subheadline)
                .foregroundColor(.orange)

            // Confirm button
            Button {
                guard var coins = profile?.coinBalance else { return }
                let result = gameVM.submitGuess(playerCoins: &coins)
                profile?.coinBalance = coins
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onResult(result)
                }
            } label: {
                Text("確認猜測")
                    .font(.system(size: 17, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(colors: [.yellow, .orange],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .background(Color(red: 0.05, green: 0.10, blue: 0.28))
        .presentationBackground(Color(red: 0.05, green: 0.10, blue: 0.28))
    }
}

// MARK: - Clue Picker Sheet (抽3選1 / 抽2選1)
struct CluePickerSheet: View {
    @Bindable var gameVM: GameViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.white.opacity(0.2))
                .frame(width: 40, height: 4)
                .padding(.top, 12)

            VStack(spacing: 4) {
                Text("選擇線索")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("從以下線索中選擇 1 條")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }

            VStack(spacing: 10) {
                ForEach(gameVM.pendingClues) { clue in
                    Button {
                        var dummy = 0   // cost already deducted when drawing
                        gameVM.selectClue(clue, playerCoins: &dummy)
                    } label: {
                        HStack(spacing: 12) {
                            ClueTypeBadge(category: clue.category)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(clue.name)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white.opacity(0.7))
                                Text(clue.generate(gameVM.hiddenNumbers, gameVM.hiddenColors))
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.09))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .background(Color(red: 0.05, green: 0.10, blue: 0.28))
        .presentationBackground(Color(red: 0.05, green: 0.10, blue: 0.28))
    }
}
