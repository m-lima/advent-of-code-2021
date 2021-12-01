ToNumber ← 10⊸×⊸+˜´(-⟜'0'⊢)¨∘⌽
i ← ToNumber¨•file.Lines"./input.txt"

Window ← { 𝕩⊏˜𝕨(⍉↕⟜(↕≠))𝕩 }
•Show +´<˝2 Window +˝3 Window i
