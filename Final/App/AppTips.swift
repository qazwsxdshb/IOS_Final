import TipKit

// MARK: - 猜數字按鈕提示
struct GuessTip: Tip {
    var title: Text {
        Text("猜數字")
    }
    var message: Text? {
        Text("每次猜測需要花費金幣，費用會隨猜測次數倍增，最高 1500 元。")
    }
    var image: Image? {
        Image(systemName: "keyboard.fill")
    }
}

// MARK: - 數字線索提示
struct NumberClueTip: Tip {
    var title: Text {
        Text("數字線索")
    }
    var message: Text? {
        Text("購買後從 3 條線索中選 1 條，費用隨購買次數倍增，最高 750 元。")
    }
    var image: Image? {
        Image(systemName: "number.circle.fill")
    }
}

// MARK: - 顏色線索提示
struct ColorClueTip: Tip {
    var title: Text {
        Text("顏色線索")
    }
    var message: Text? {
        Text("每個數字背後都有顏色（黃/綠/藍），顏色線索幫你縮小範圍。")
    }
    var image: Image? {
        Image(systemName: "paintpalette.fill")
    }
}

// MARK: - 隨機線索提示
struct RandomClueTip: Tip {
    var title: Text {
        Text("隨機線索")
    }
    var message: Text? {
        Text("固定 300 元，從數字與顏色線索中隨機抽 2 條選 1 條，划算！")
    }
    var image: Image? {
        Image(systemName: "shuffle.circle.fill")
    }
}

// MARK: - AI 提示引導
struct AIHintTip: Tip {
    var title: Text {
        Text("AI 智慧提示")
    }
    var message: Text? {
        Text("不知道怎麼推理？問 AI 要方向，AI 不會直接說答案，但會給你邏輯建議。")
    }
    var image: Image? {
        Image(systemName: "sparkle")
    }
}

// MARK: - AI 設定提示
struct AISettingTip: Tip {
    var title: Text {
        Text("設定 AI 模型")
    }
    var message: Text? {
        Text("在這裡輸入你的 API Key，支援 OpenAI、Claude、Gemini、Groq。")
    }
    var image: Image? {
        Image(systemName: "cpu.fill")
    }
}
