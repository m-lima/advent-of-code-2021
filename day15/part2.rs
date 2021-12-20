fn load() -> Vec<u8> {
    let file = std::fs::read("input.txt").unwrap();
    let block = file
        .split(|c| *c == b'\n')
        .flat_map(|l| {
            (0..5)
                .into_iter()
                .flat_map(move |a| l.into_iter().map(move |c| (c + a - b'1') % 9 + 1))
        })
        .collect::<Vec<_>>();
    (0..5)
        .into_iter()
        .flat_map(|a| block.iter().map(move |c| (c + a - 1) % 9 + 1))
        .collect::<Vec<_>>()
}

fn neighbors(index: usize, len: usize, max: usize) -> ([usize; 4], usize) {
    let mut neighbors = [0; 4];
    let mut length;

    match index % len {
        i if i == 0 => {
            neighbors[0] = index + 1;
            length = 1;
        }
        i if i == len - 1 => {
            neighbors[0] = index - 1;
            length = 1;
        }
        _ => {
            neighbors[0] = index - 1;
            neighbors[1] = index + 1;
            length = 2;
        }
    }

    if index >= len {
        neighbors[length] = index - len;
        length += 1;
    }

    if index < max - len {
        neighbors[length] = index + len;
        length += 1;
    }

    (neighbors, length)
}

fn next(unvisited: &mut Vec<(usize, usize)>) -> Option<(usize, usize)> {
    let mut min = usize::MAX;
    let mut index = None;
    for (i, u) in unvisited.iter().enumerate() {
        if u.0 < min {
            min = u.0;
            index = Some(i);
        }
    }
    index.map(|i| unvisited.swap_remove(i))
}

fn visit(mut unvisited: Vec<(usize, usize)>, risks: Vec<u8>, len: usize) -> usize {
    let mut visited = Vec::with_capacity(risks.len());

    while let Some((risk, index)) = next(&mut unvisited) {
        visited.push((risk, index));

        let neighbors = neighbors(index, len, risks.len());
        for neighbor in neighbors.0.iter().take(neighbors.1).copied() {
            if let Some(n) = unvisited.iter_mut().find(|t| t.1 == neighbor) {
                (*n).0 = n.0.min(usize::from(risks[n.1]) + risk);
            }
        }
    }

    visited
        .iter()
        .position(|(_, i)| *i == risks.len() - 1)
        .map(|i| visited[i].0)
        .unwrap()
}

fn main() {
    let risks = load();

    let len = f64::from(risks.len() as u32).sqrt() as usize;

    let unvisited = (0..risks.len())
        .map(|i| (if i == 0 { 0 } else { usize::MAX }, i))
        .collect::<Vec<_>>();

    println!("{}", visit(unvisited, risks, len));
}
