mod shared;

fn main() {
    let mut grid = shared::load();
    let mut i = 0_usize;
    loop {
        i += 1;
        shared::inc(&mut grid);
        if shared::flashes(&mut grid) == 100 {
            println!("{}", i);
            return;
        }
    }
}
