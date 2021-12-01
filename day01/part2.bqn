ToNumber ← 10⊸×⊸+˜´(-⟜'0'⊢)¨∘⌽
Load ← ToNumber¨•FLines

_onto_ ← {𝕩𝔾˜𝕨𝔽𝕩}
Indices ← ⍉↕⟜(↕≠)
Window ← Indices _onto_ ⊏

•Show +´ <˝ 2 Window +˝ 3 Window Load "./input.txt"
