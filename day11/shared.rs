type Grid = [[u8; 10]; 10];

#[derive(Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
enum Dir {
    N,
    NE,
    E,
    SE,
    S,
    SW,
    W,
    NW,
}
impl Dir {
    const LIST: [Self; 8] = [
        Self::N,
        Self::NE,
        Self::E,
        Self::SE,
        Self::S,
        Self::SW,
        Self::W,
        Self::NW,
    ];
    fn iter() -> impl Iterator<Item = Self> {
        Self::LIST.iter().copied()
    }
}

#[derive(Clone, Copy)]
struct Coord(usize, usize);
impl Coord {
    fn get(self, grid: &Grid) -> u8 {
        grid[self.0][self.1]
    }
    fn get_mut(self, grid: &mut Grid) -> &mut u8 {
        &mut grid[self.0][self.1]
    }
    fn neighbor(self, dir: Dir) -> Option<Self> {
        match dir {
            Dir::N if self.0 > 0 => Some(Coord(self.0 - 1, self.1)),
            Dir::NE if self.0 > 0 && self.1 < 9 => Some(Coord(self.0 - 1, self.1 + 1)),
            Dir::E if self.1 < 9 => Some(Coord(self.0, self.1 + 1)),
            Dir::SE if self.0 < 9 && self.1 < 9 => Some(Coord(self.0 + 1, self.1 + 1)),
            Dir::S if self.0 < 9 => Some(Coord(self.0 + 1, self.1)),
            Dir::SW if self.0 < 9 && self.1 > 0 => Some(Coord(self.0 + 1, self.1 - 1)),
            Dir::W if self.1 > 0 => Some(Coord(self.0, self.1 - 1)),
            Dir::NW if self.0 > 0 && self.1 > 0 => Some(Coord(self.0 - 1, self.1 - 1)),
            _ => None,
        }
    }
    fn iter() -> impl Iterator<Item = Self> {
        (0..100).map(|i| Coord(i / 10, i % 10))
    }
}

fn flash(grid: &mut Grid, coord: Coord) -> usize {
    let mut count = 1;
    grid[coord.0][coord.1] = 0;
    for n in Dir::iter().filter_map(|d| coord.neighbor(d)) {
        if n.get(grid) > 0 {
            *n.get_mut(grid) += 1;
            if n.get(grid) > 9 {
                count += flash(grid, n);
            }
        }
    }
    count
}

pub fn flashes(grid: &mut Grid) -> usize {
    let mut count = 0;
    for c in Coord::iter() {
        if c.get(grid) > 9 {
            count += flash(grid, c);
        }
    }
    count
}

pub fn inc(grid: &mut Grid) {
    Coord::iter().for_each(|c| *c.get_mut(grid) += 1);
}

pub fn load() -> Grid {
    use std::io::Read;

    let mut input = [[0_u8; 10]; 10];
    let mut buffer = [0_u8; 128];
    let bytes = std::fs::File::open("input.txt")
        .unwrap()
        .read(&mut buffer)
        .unwrap();

    let mut coord = Coord(0, 0);
    for c in &buffer[..bytes] {
        if *c == b'\n' {
            coord = Coord(coord.0 + 1, 0);
            continue;
        }
        *coord.get_mut(&mut input) = *c - b'0';
        coord.1 += 1;
    }
    input
}
