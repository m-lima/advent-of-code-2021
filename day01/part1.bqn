ToNumber ← { +´×˝(𝕩-'0')≍⌽10⋆¨↕≠𝕩 }
Load ← ToNumber¨•FLines
Pairs ← 1↓˘»⊸≍˜
Increases ← <˝
Sum ← +´

•Show Sum Increases Pairs Load "./input.txt"
