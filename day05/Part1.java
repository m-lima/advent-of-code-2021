import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.stream.IntStream;
import java.util.stream.Stream;

public class Part1 {
  private enum OrthoDirection {
    VERTICAL,
    HORIZONTAL
  }

  private static class Pair<T> {
    private final T one;
    private final T two;

    public Pair(T one, T two) {
      this.one = one;
      this.two = two;
    }

    public T getOne() {
      return this.one;
    }

    public T getTwo() {
      return this.two;
    }


    @Override
    public boolean equals(Object obj) {
      if (this == obj) {
        return true;
      }

      if (obj == null || getClass() != obj.getClass()) {
        return false;
      }

      return one.equals(((Pair<?>) obj).one) && two.equals(((Pair<?>) obj).two);
    }

    @Override
    public int hashCode() {
      return one.hashCode() ^ two.hashCode();
    }

    @Override
    public String toString() {
      return String.format("(%s, %s)", this.one, this.two);
    }
  }

  private static class Line extends Pair<Coord> {
    public Line(Coord start, Coord end) {
      super(start, end);
    }

    public Line(List<Coord> list) {
      this(list.get(0), list.get(1));
    }

    public static Line parse(String line) {
      return new Line(Arrays.stream(line.split(" -> ")).map(Coord::parse).toList());
    }

    public Optional<OrthoDirection> getOrthoDirection() {
      if (getStart().getX() == getEnd().getX()) {
        return Optional.of(OrthoDirection.VERTICAL);
      } else if (getStart().getY() == getEnd().getY()) {
        return Optional.of(OrthoDirection.HORIZONTAL);
      } else {
        return Optional.empty();
      }
    }

    public Coord getStart() {
      return getOne();
    }

    public Coord getEnd() {
      return getTwo();
    }

    public int maxX() {
      return Math.max(getStart().getX(), getEnd().getX());
    }

    public int minX() {
      return Math.min(getStart().getX(), getEnd().getX());
    }

    public int maxY() {
      return Math.max(getStart().getY(), getEnd().getY());
    }

    public int minY() {
      return Math.min(getStart().getY(), getEnd().getY());
    }
  }

  private static final class Orthogonal extends Line {
    private Orthogonal(Line line) {
      super(line.getOne(), line.getTwo());
    }

    public static Stream<Orthogonal> tryOrthogonal(Line line) {
      return line.getOrthoDirection().map(d -> new Orthogonal(line)).stream();
    }

    public OrthoDirection getDirection() {
      return getOrthoDirection().get();
    }

    public List<Coord> intersection(Orthogonal other) {
      var thisDirection = getDirection();
      var otherDirection = other.getDirection();

      if (thisDirection == otherDirection) {
        switch (thisDirection) {
          case VERTICAL:
            if (getStart().getX() == other.getStart().getX() && minY() <= other.maxY() && maxY() >= other.minY()) {
              return IntStream.rangeClosed(Math.max(minY(), other.minY()), Math.min(maxY(), other.maxY()))
                .boxed()
                .map(y -> new Coord(getStart().getX(), y))
                .toList();
            }
          case HORIZONTAL:
            if (getStart().getY() == other.getStart().getY() && minX() <= other.maxX() && maxX() >= other.minX()) {
              return IntStream.rangeClosed(Math.max(minX(), other.minX()), Math.min(maxX(), other.maxX()))
                .boxed()
                .map(x -> new Coord(x, getStart().getY()))
                .toList();
            }
        }
      } else {
        switch (thisDirection) {
          case VERTICAL -> {
            var intersection = new Coord(getStart().getX(), other.getStart().getY());
            if (intersection.getY() <= maxY() && intersection.getY() >= minY()
                && intersection.getX() <= other.maxX() && intersection.getX() >= other.minX()) {
              return List.of(intersection);
            }
          }
          case HORIZONTAL -> {
            var intersection = new Coord(other.getStart().getX(), getStart().getY());
            if (intersection.getX() <= maxX() && intersection.getX() >= minX()
                && intersection.getY() <= other.maxY() && intersection.getY() >= other.minY()) {
              return List.of(intersection);
            }
          }
        };
      }

      return List.of();
    }
  }

  private static final class Coord extends Pair<Integer>{
    public Coord(int x, int y) {
      super(x, y);
    }

    public Coord(List<Integer> list) {
      this(list.get(0), list.get(1));
    }

    public static Coord parse(String coords) {
      return new Coord(Arrays.stream(coords.split(",")).map(Integer::parseInt).toList());
    }

    public int getX() {
      return getOne();
    }

    public int getY() {
      return getTwo();
    }
  }

  private static List<Orthogonal> load(String file) throws IOException {
    try (Stream<String> stream = Files.lines(Paths.get(file))) {
      return stream
        .map(Line::parse)
        .flatMap(Orthogonal::tryOrthogonal)
        .toList();
    }
  }

  public static void main(String[] args) throws IOException {
    var lines = load("input.txt");
    var intersections = new HashSet<Coord>();

    for (int i = 0; i < lines.size() - 1; i++) {
      for (int j = i + 1; j < lines.size(); j++) {
        intersections.addAll(lines.get(i).intersection(lines.get(j)));
      }
    }

    System.out.println(intersections.size());
  }
}
