mod shared;

fn main() {
    let mut grid = shared::load();
    let count = (0..100).fold(0, |a, _| {
        shared::inc(&mut grid);
        a + shared::flashes(&mut grid)
    });
    println!("{}", count);
}
