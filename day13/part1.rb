require 'set'

Point = Struct.new(:x, :y)
Fold = Struct.new(:vert, :pos) do
  def apply(point)
    if vert && point.x < pos
      Point.new(pos * 2 - point.x, point.y)
    elsif !vert && point.y < pos
      Point.new(point.x, pos * 2 - point.y)
    else
      point
    end
  end
end

file = File.open("input.txt")
iter = file.readlines.map(&:chomp)

fold = iter
  .drop_while { |c| !c.empty? }
  .drop(1)
  .map { |l| l.split(' ').last().split('=') }
  .map { |axis, pos| Fold.new(axis == 'x', pos.to_i) }
  .first()

points = iter
  .take_while { |c| !c.empty? }
  .map { |l| l.split(',').map { |n| n.to_i } }
  .map { |x, y| Point.new(x, y) }
  .map { |p| fold.apply(p) }
  .to_set

puts points.length()
