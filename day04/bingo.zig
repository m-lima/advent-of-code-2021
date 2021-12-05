const Card = @import("loader.zig").Card;

pub const Bingo = struct { card: Card, round: u8 };

pub fn bingo_round(card: Card, order: []u8) u8 {
    var round: u8 = 255;

    var i: u3 = 0;
    while (i < 5) {
        var max_row: u8 = 0;
        var max_col: u8 = 0;
        var j: u3 = 0;
        while (j < 5) {
            const curr_row = order[card[i][j]];
            const curr_col = order[card[j][i]];

            if (curr_row > max_row) {
                max_row = curr_row;
            }
            if (curr_col > max_col) {
                max_col = curr_col;
            }

            j += 1;
        }

        if (max_row < round) {
            round = max_row;
        }
        if (max_col < round) {
            round = max_col;
        }

        i += 1;
    }
    return round;
}

pub fn sum_unmarked(bingo: Bingo, order: []u8) usize {
    var sum: usize = 0;

    for (bingo.card) |row| {
        for (row) |cell| {
            if (order[cell] > bingo.round) {
                sum += cell;
            }
        }
    }

    return sum;
}
