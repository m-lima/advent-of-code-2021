main = do
        contents <- readFile "input.txt"
        print
          .(\(x, y) -> x * y)
          .foldl1 (\(x1, y1) (x2, y2) -> (x1 + x2, y1 + y2))
          .map coord
          .map direction
          .map words
          .lines $ contents

data Direction = Fwd Int | Vert Int deriving (Eq, Show)

direction :: [String] -> Direction
direction ["forward", a] = Fwd $ read a
direction ["up", a] = Vert $ negate $ read a
direction ["down", a] = Vert $ read a

coord :: Direction -> (Int, Int)
coord (Fwd a) = (a, 0)
coord (Vert a) = (0, a)
