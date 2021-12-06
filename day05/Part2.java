import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import java.util.stream.Stream;

public class Part2 {
  private enum Direction {
    VERTICAL,
    HORIZONTAL,
    UPWARDS,
    DOWNWARDS,
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
    private Line(List<Coord> list) {
      super(list.get(0), list.get(1));
    }

    public Direction getDirection() {
      if (getStart().getX() == getEnd().getX()) {
        return Direction.VERTICAL;
      } else if (getStart().getY() == getEnd().getY()) {
        return Direction.HORIZONTAL;
      } else {
        return getStart().getY() < getEnd().getY() ? Direction.DOWNWARDS : Direction.UPWARDS;
      }
    }

    public static Line parse(String line) {
      return new Line(Arrays.stream(line.split(" -> ")).map(Coord::parse).sorted().toList());
    }

    public Coord getStart() {
      return getOne();
    }

    public Coord getEnd() {
      return getTwo();
    }

    public Stream<Coord> toPoints() {
      return switch (getDirection()) {
        case VERTICAL -> IntStream.rangeClosed(getStart().getY(), getEnd().getY()).boxed().map(y -> new Coord(getStart().getX(), y));
        case HORIZONTAL -> IntStream.rangeClosed(getStart().getX(), getEnd().getX()).boxed().map(x -> new Coord(x, getStart().getY()));
        case DOWNWARDS -> IntStream.rangeClosed(getStart().getX(), getEnd().getX()).boxed().map(x -> new Coord(x, getStart().getY() + (x - getStart().getX())));
        case UPWARDS -> IntStream.rangeClosed(getStart().getX(), getEnd().getX()).boxed().map(x -> new Coord(x, getStart().getY() - (x - getStart().getX())));
      };
    }
  }

  private static final class Coord extends Pair<Integer> implements Comparable<Coord> {
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

    @Override
    public int compareTo(Coord other) {
      if (getX() == other.getX()) {
        return getTwo().compareTo(other.getTwo());
      } else {
        return getOne().compareTo(other.getOne());
      }
    }
  }

  private static Map<Coord, Long> load(String file) throws IOException {
    try (Stream<String> stream = Files.lines(Paths.get(file))) {
      return stream
        .map(Line::parse)
        .flatMap(l -> l.toPoints())
        .collect(Collectors.groupingBy(Function.identity(), Collectors.counting()));
    }
  }

  public static void main(String[] args) throws IOException {
    var points = load("input.txt");
    var count = points.entrySet().stream().filter(e -> e.getValue() > 1).count();

    System.out.println(count);
  }
}
