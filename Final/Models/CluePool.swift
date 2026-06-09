import Foundation

// MARK: - Clue Definition
struct ClueDefinition: Identifiable {
    let id: String
    let name: String
    let category: ClueCategory
    let generate: ([Int], [String]) -> String
}

// MARK: - Clue Pool
enum CluePool {

    // MARK: A Zone — Number Clues
    static let numberClues: [ClueDefinition] = [

        ClueDefinition(id: "sum", name: "總和", category: .number) { nums, _ in
            "三個數字加起來的總和是 \(nums.reduce(0, +))。"
        },
        ClueDefinition(id: "odd_positions", name: "奇判定", category: .number) { nums, _ in
            let positions = nums.enumerated().compactMap { $0.element % 2 != 0 ? "第\($0.offset + 1)位" : nil }
            return positions.isEmpty ? "沒有奇數位置。" : "奇數的位置：\(positions.joined(separator: "、"))。"
        },
        ClueDefinition(id: "even_positions", name: "偶判定", category: .number) { nums, _ in
            let positions = nums.enumerated().compactMap { $0.element % 2 == 0 ? "第\($0.offset + 1)位" : nil }
            return positions.isEmpty ? "沒有偶數位置。" : "偶數的位置：\(positions.joined(separator: "、"))。"
        },
        ClueDefinition(id: "compare_ab", name: "大小關係A", category: .number) { nums, _ in
            let rel = nums[0] > nums[1] ? "大於" : nums[0] < nums[1] ? "小於" : "等於"
            return "第一個數字\(rel)第二個數字。"
        },
        ClueDefinition(id: "compare_bc", name: "大小關係B", category: .number) { nums, _ in
            let rel = nums[1] > nums[2] ? "大於" : nums[1] < nums[2] ? "小於" : "等於"
            return "第二個數字\(rel)第三個數字。"
        },
        ClueDefinition(id: "compare_ac", name: "大小關係C", category: .number) { nums, _ in
            let rel = nums[0] > nums[2] ? "大於" : nums[0] < nums[2] ? "小於" : "等於"
            return "第一個數字\(rel)第三個數字。"
        },
        ClueDefinition(id: "range", name: "極差觀測", category: .number) { nums, _ in
            "最大值減最小值的差為 \(nums.max()! - nums.min()!)。"
        },
        ClueDefinition(id: "zero_product", name: "零的領域", category: .number) { nums, _ in
            let hasZero = nums.contains(0)
            return "三個數字相乘的積\(hasZero ? "是" : "不是") 0。"
        },
        ClueDefinition(id: "prime_count", name: "質數獵人", category: .number) { nums, _ in
            let primes = [2, 3, 5, 7]
            let count = nums.filter { primes.contains($0) }.count
            return "三個數字中，質數（2, 3, 5, 7）的數量為 \(count) 個。"
        },
        ClueDefinition(id: "big_count", name: "大判定", category: .number) { nums, _ in
            "密碼中大於或等於 5 的數字有 \(nums.filter { $0 >= 5 }.count) 個。"
        },
        ClueDefinition(id: "small_count", name: "小判定", category: .number) { nums, _ in
            "密碼中小於 5 的數字有 \(nums.filter { $0 < 5 }.count) 個。"
        },
        ClueDefinition(id: "ascending", name: "連續風暴", category: .number) { nums, _ in
            let isAsc = nums[0] < nums[1] && nums[1] < nums[2]
            return "三個數字\(isAsc ? "是" : "不是")從小到大排列。"
        },
        ClueDefinition(id: "duplicates", name: "相同複製", category: .number) { nums, _ in
            let hasDup = Set(nums).count < nums.count
            return "三個數字中\(hasDup ? "有" : "沒有")重複數字。"
        },
        ClueDefinition(id: "odd_even_total", name: "全體奇偶", category: .number) { nums, _ in
            let odd = nums.filter { $0 % 2 != 0 }.count
            let even = nums.filter { $0 % 2 == 0 }.count
            return "奇數 \(odd) 個、偶數 \(even) 個。"
        },
        ClueDefinition(id: "multiple_ab", name: "倍數密碼A", category: .number) { nums, _ in
            let s = nums[0] + nums[1]
            return "前兩位總和 \(s)：\(s % 3 == 0 ? "可以" : "不能")被 3 整除，\(s % 2 == 0 ? "可以" : "不能")被 2 整除。"
        },
        ClueDefinition(id: "multiple_bc", name: "倍數密碼B", category: .number) { nums, _ in
            let s = nums[1] + nums[2]
            return "後兩位總和 \(s)：\(s % 3 == 0 ? "可以" : "不能")被 3 整除，\(s % 2 == 0 ? "可以" : "不能")被 2 整除。"
        },
        ClueDefinition(id: "max_position", name: "極值位置A", category: .number) { nums, _ in
            let maxVal = nums.max()!
            let positions = nums.enumerated().compactMap { $0.element == maxVal ? "第\($0.offset + 1)位" : nil }
            return "最大值出現在：\(positions.joined(separator: "、"))。"
        },
        ClueDefinition(id: "min_position", name: "極值位置B", category: .number) { nums, _ in
            let minVal = nums.min()!
            let positions = nums.enumerated().compactMap { $0.element == minVal ? "第\($0.offset + 1)位" : nil }
            return "最小值出現在：\(positions.joined(separator: "、"))。"
        },
        ClueDefinition(id: "max_info", name: "極值資訊A", category: .number) { nums, _ in
            let m = nums.max()!
            return "最大值 \(m)：\(m % 3 == 0 ? "可以" : "不能")被 3 整除，\(m % 2 == 0 ? "可以" : "不能")被 2 整除。"
        },
        ClueDefinition(id: "min_info", name: "極值資訊B", category: .number) { nums, _ in
            "最小值是 \(nums.min()!)。"
        },
        ClueDefinition(id: "diff_ab", name: "差計算A", category: .number) { nums, _ in
            "第一個與第二個數字的絕對差為 \(abs(nums[0] - nums[1]))。"
        },
        ClueDefinition(id: "diff_bc", name: "差計算B", category: .number) { nums, _ in
            "第二個與第三個數字的絕對差為 \(abs(nums[1] - nums[2]))。"
        },
        ClueDefinition(id: "diff_ac", name: "差計算C", category: .number) { nums, _ in
            "第一個與第三個數字的絕對差為 \(abs(nums[0] - nums[2]))。"
        },
        ClueDefinition(id: "max_diff", name: "最大差", category: .number) { nums, _ in
            let diffs = [abs(nums[0]-nums[1]), abs(nums[1]-nums[2]), abs(nums[0]-nums[2])]
            return "所有絕對差的最大值為 \(diffs.max()!)。"
        },
        ClueDefinition(id: "min_diff", name: "最小差", category: .number) { nums, _ in
            let diffs = [abs(nums[0]-nums[1]), abs(nums[1]-nums[2]), abs(nums[0]-nums[2])]
            return "所有絕對差的最小值為 \(diffs.min()!)。"
        },
        ClueDefinition(id: "diff_sum", name: "差之和", category: .number) { nums, _ in
            let s = abs(nums[0]-nums[1]) + abs(nums[1]-nums[2]) + abs(nums[0]-nums[2])
            return "所有絕對差的總和為 \(s)。"
        },
        ClueDefinition(id: "random_digit", name: "隨機機會", category: .number) { nums, _ in
            let idx = Int.random(in: 0..<3)
            return "密碼包含數字 \(nums[idx])（位置不提示）。"
        },
        ClueDefinition(id: "random_diff", name: "隨機差", category: .number) { nums, _ in
            let pairs = [(0,1),(1,2),(0,2)]
            let p = pairs.randomElement()!
            return "第\(p.0+1)個與第\(p.1+1)個數字的差為 \(abs(nums[p.0]-nums[p.1]))。"
        },
        ClueDefinition(id: "random_sum2", name: "隨機計數器2A", category: .number) { nums, _ in
            let pairs = [(0,1),(1,2),(0,2)]
            let p = pairs.randomElement()!
            return "兩個數字的和為 \(nums[p.0] + nums[p.1])（位置不提示）。"
        },
    ]
    + (0...9).map { digit in
        ClueDefinition(id: "lucky_\(digit)", name: "幸運號碼\(digit)", category: .number) { nums, _ in
            let positions = nums.enumerated().compactMap { $0.element == digit ? "第\($0.offset + 1)位" : nil }
            if positions.isEmpty {
                return "密碼中沒有數字 \(digit)。"
            } else {
                return "數字 \(digit) 出現在：\(positions.joined(separator: "、"))。"
            }
        }
    }

    // MARK: B Zone — Color Clues
    static let colorClues: [ClueDefinition] = [
        ClueDefinition(id: "blue_radar", name: "藍色雷達", category: .color) { _, colors in
            let positions = colors.enumerated().compactMap { $0.element == "blue" ? "第\($0.offset + 1)位" : nil }
            return positions.isEmpty ? "沒有藍色方塊。" : "藍色方塊位於：\(positions.joined(separator: "、"))。"
        },
        ClueDefinition(id: "green_radar", name: "綠色雷達", category: .color) { _, colors in
            let positions = colors.enumerated().compactMap { $0.element == "green" ? "第\($0.offset + 1)位" : nil }
            return positions.isEmpty ? "沒有綠色方塊。" : "綠色方塊位於：\(positions.joined(separator: "、"))。"
        },
        ClueDefinition(id: "yellow_radar", name: "黃色雷達", category: .color) { _, colors in
            let positions = colors.enumerated().compactMap { $0.element == "yellow" ? "第\($0.offset + 1)位" : nil }
            return positions.isEmpty ? "沒有黃色方塊。" : "黃色方塊位於：\(positions.joined(separator: "、"))。"
        },
        ClueDefinition(id: "reveal_first", name: "首位開榜", category: .color) { _, colors in
            "第一個方塊的顏色是：\(colorName(colors[0]))。"
        },
        ClueDefinition(id: "reveal_mid", name: "中位開榜", category: .color) { _, colors in
            "第二個方塊的顏色是：\(colorName(colors[1]))。"
        },
        ClueDefinition(id: "reveal_last", name: "末位開榜", category: .color) { _, colors in
            "第三個方塊的顏色是：\(colorName(colors[2]))。"
        },
        ClueDefinition(id: "yellow_sum", name: "黃色計數器", category: .color) { nums, colors in
            let sum = zip(nums, colors).filter { $0.1 == "yellow" }.reduce(0) { $0 + $1.0 }
            return "黃色方塊上的數字總和為 \(sum)。"
        },
        ClueDefinition(id: "green_sum", name: "綠色計數器", category: .color) { nums, colors in
            let sum = zip(nums, colors).filter { $0.1 == "green" }.reduce(0) { $0 + $1.0 }
            return "綠色方塊上的數字總和為 \(sum)。"
        },
        ClueDefinition(id: "blue_sum", name: "藍色計數器", category: .color) { nums, colors in
            let sum = zip(nums, colors).filter { $0.1 == "blue" }.reduce(0) { $0 + $1.0 }
            return "藍色方塊上的數字總和為 \(sum)。"
        },
        ClueDefinition(id: "random_color_sum", name: "隨機計數器", category: .color) { nums, colors in
            let c = ["yellow","green","blue"].randomElement()!
            let sum = zip(nums, colors).filter { $0.1 == c }.reduce(0) { $0 + $1.0 }
            return "某種顏色方塊上的數字總和為 \(sum)（顏色不提示）。"
        },
        ClueDefinition(id: "random_two_color_sum", name: "隨機計數器2B", category: .color) { nums, colors in
            let picked = ["yellow","green","blue"].shuffled().prefix(2)
            let sum = zip(nums, colors).filter { picked.contains($0.1) }.reduce(0) { $0 + $1.0 }
            return "兩種顏色方塊上的數字總和為 \(sum)（顏色不提示）。"
        },
        ClueDefinition(id: "blue_yellow_sum", name: "藍黃配", category: .color) { nums, colors in
            let sum = zip(nums, colors).filter { $0.1 == "blue" || $0.1 == "yellow" }.reduce(0) { $0 + $1.0 }
            return "藍色 + 黃色方塊的數字總和為 \(sum)。"
        },
        ClueDefinition(id: "yellow_green_sum", name: "黃綠配", category: .color) { nums, colors in
            let sum = zip(nums, colors).filter { $0.1 == "yellow" || $0.1 == "green" }.reduce(0) { $0 + $1.0 }
            return "黃色 + 綠色方塊的數字總和為 \(sum)。"
        },
        ClueDefinition(id: "blue_green_sum", name: "藍綠配", category: .color) { nums, colors in
            let sum = zip(nums, colors).filter { $0.1 == "blue" || $0.1 == "green" }.reduce(0) { $0 + $1.0 }
            return "藍色 + 綠色方塊的數字總和為 \(sum)。"
        },
        ClueDefinition(id: "color_diversity", name: "色彩多樣性", category: .color) { _, colors in
            "場上共出現了 \(Set(colors).count) 種顏色。"
        },
        ClueDefinition(id: "symmetry_scan", name: "對稱掃描", category: .color) { _, colors in
            "第一個與第三個方塊顏色\(colors[0] == colors[2] ? "相同" : "不同")。"
        },
        ClueDefinition(id: "neighbor_check", name: "鄰居檢查", category: .color) { _, colors in
            "前兩個方塊（第一與第二個）顏色\(colors[0] == colors[1] ? "相同" : "不同")。"
        },
        ClueDefinition(id: "tail_check", name: "尾端檢查", category: .color) { _, colors in
            "後兩個方塊（第二與第三個）顏色\(colors[1] == colors[2] ? "相同" : "不同")。"
        },
        ClueDefinition(id: "missing_color", name: "色彩絕緣體", category: .color) { _, colors in
            for c in ["yellow","green","blue"] {
                if !colors.contains(c) { return "\(colorName(c))在這一局完全沒有出現。" }
            }
            return "三種顏色都有出現。"
        },
        ClueDefinition(id: "left_zone_a", name: "左側安全區A", category: .color) { _, colors in
            let front = Array(colors.prefix(2))
            return "前兩個方塊：\(front.contains("yellow") ? "有" : "沒有")包含黃色，\(front.contains("green") ? "有" : "沒有")包含綠色。"
        },
        ClueDefinition(id: "left_zone_b", name: "左側安全區B", category: .color) { _, colors in
            let front = Array(colors.prefix(2))
            return "前兩個方塊：\(front.contains("green") ? "有" : "沒有")包含綠色，\(front.contains("blue") ? "有" : "沒有")包含藍色。"
        },
        ClueDefinition(id: "left_zone_c", name: "左側安全區C", category: .color) { _, colors in
            let front = Array(colors.prefix(2))
            return "前兩個方塊：\(front.contains("blue") ? "有" : "沒有")包含藍色，\(front.contains("yellow") ? "有" : "沒有")包含黃色。"
        },
        ClueDefinition(id: "right_zone_a", name: "右側安全區A", category: .color) { _, colors in
            let back = Array(colors.suffix(2))
            return "後兩個方塊：\(back.contains("yellow") ? "有" : "沒有")包含黃色，\(back.contains("green") ? "有" : "沒有")包含綠色。"
        },
        ClueDefinition(id: "right_zone_b", name: "右側安全區B", category: .color) { _, colors in
            let back = Array(colors.suffix(2))
            return "後兩個方塊：\(back.contains("green") ? "有" : "沒有")包含綠色，\(back.contains("blue") ? "有" : "沒有")包含藍色。"
        },
        ClueDefinition(id: "right_zone_c", name: "右側安全區C", category: .color) { _, colors in
            let back = Array(colors.suffix(2))
            return "後兩個方塊：\(back.contains("blue") ? "有" : "沒有")包含藍色，\(back.contains("green") ? "有" : "沒有")包含綠色。"
        },
    ]

    // MARK: Helper
    static func colorName(_ code: String) -> String {
        switch code {
        case "yellow": return "黃色"
        case "green":  return "綠色"
        case "blue":   return "藍色"
        default:       return code
        }
    }

    /// Draw `count` random clues from the given pool, excluding already-used IDs
    static func drawClues(from pool: [ClueDefinition], count: Int, excluding used: Set<String>) -> [ClueDefinition] {
        let available = pool.filter { !used.contains($0.id) }
        return Array(available.shuffled().prefix(count))
    }
}
