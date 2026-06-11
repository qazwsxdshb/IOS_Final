//
//  FinalTests.swift
//  FinalTests
//
//  Created by 何益森 on 2026/6/6.
//

import Testing
@testable import Final

struct FinalTests {

    @Test func cluePurchaseStoresChargedCostAndStableText() async throws {
        let gameVM = GameViewModel()
        gameVM.startNewGame()
        gameVM.hiddenNumbers = [1, 2, 3]
        gameVM.hiddenColors = ["yellow", "green", "blue"]

        var coins = 3_000
        #expect(gameVM.beginClueDraw(category: .number, playerCoins: &coins))
        #expect(coins == 2_900)

        let option = try #require(gameVM.pendingClues.first)
        gameVM.selectClue(option)

        let storedClue = try #require(gameVM.purchasedClues.first)
        #expect(storedClue.cost == 100)
        #expect(storedClue.clueId == option.clue.id)
        #expect(storedClue.clueText == option.text)
        #expect(gameVM.nextClueCost(for: .number) == 200)
    }

    @Test func randomClueUsesFixedCostAndExcludesChosenClueById() async throws {
        let gameVM = GameViewModel()
        gameVM.startNewGame()
        gameVM.hiddenNumbers = [7, 7, 0]
        gameVM.hiddenColors = ["blue", "blue", "yellow"]

        var coins = 3_000
        #expect(gameVM.beginRandomClueDraw(playerCoins: &coins))
        #expect(coins == 2_700)

        let chosen = try #require(gameVM.pendingClues.first)
        gameVM.selectClue(chosen)

        let storedClue = try #require(gameVM.purchasedClues.first)
        #expect(storedClue.cost == 300)
        #expect(storedClue.clueId == chosen.clue.id)

        #expect(gameVM.beginRandomClueDraw(playerCoins: &coins))
        #expect(!gameVM.pendingClues.contains { $0.clue.id == chosen.clue.id })
    }
    @Test func cluePickerShowsTemplateInsteadOfGeneratedAnswer() async throws {
        let sumClue = try #require(CluePool.numberClues.first { $0.id == "sum" })
        #expect(sumClue.selectionPreview == "【總和】：三個數字加起來的總和是 [總和]。")
        #expect(!sumClue.selectionPreview.contains("6"))

        let generated = sumClue.generate([1, 2, 3], ["yellow", "green", "blue"])
        #expect(generated == "三個數字加起來的總和是 6。")
    }

}
