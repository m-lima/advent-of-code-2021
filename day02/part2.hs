main = do
        contents <- readFile "input.txt"
        print
          .(\(x, y, _) -> x * y)
          .last
          .scanl1 (\(x1, y1, z1) (x2, y2, z2) -> (x1 + x2, x2 * z1 + y1, z1 + z2))
          .map coord
          .map direction
          .map words
          .lines
          $contents

data Direction = Fwd Int | Vert Int deriving (Eq, Show)

direction :: [String] -> Direction
direction ["forward", a] = Fwd $ read a
direction ["up", a] = Vert $ negate $ read a
direction ["down", a] = Vert $ read a

coord :: Direction -> (Int, Int, Int)
coord (Fwd a) = (a, 0, 0)
coord (Vert a) = (0, 0, a)
