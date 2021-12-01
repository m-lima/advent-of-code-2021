ToNumber ← { +´×˝(𝕩-'0')≍⌽10⋆¨↕≠𝕩 }
i ← ToNumber¨•file.Lines"./input.txt"

•Show +´1↓>˝i≍»i
