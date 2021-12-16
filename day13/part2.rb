require 'set'

Point = Struct.new(:x, :y)
Fold = Struct.new(:vert, :pos)

file = File.open("input.txt")
iter = file.readlines.map(&:chomp)
points = iter
  .take_while { |c| !c.empty? }
  .map { |l| l.split(',').map { |n| n.to_i } }
  .map { |x, y| Point.new(x, y) }
  .to_set

for fold in iter
  .drop_while { |c| !c.empty? }
  .drop(1)
  .map { |l| l.split(' ').last().split('=') }
  .map { |axis, pos| Fold.new(axis == 'x', pos.to_i) }
  points = Set.new(
    if fold.vert
      points
        .map { |p| p.x < fold.pos ? p : Point.new(fold.pos * 2 - p.x, p.y) }
    else
      points
        .map { |p| p.y < fold.pos ? p : Point.new(p.x, fold.pos * 2 - p.y) }
    end
  )
end

x, y = points
  .reduce([0, 0]) { |a, c|
    if c.x > a[0]
      a[0] = c.x
    end
    if c.y > a[1]
      a[1] = c.y
    end
    a
  }

for y in (0..y)
  for x in (0..x)
    if points.include?(Point.new(x, y))
      putc '#'
    else
      putc ' '
    end
  end
  puts
end
