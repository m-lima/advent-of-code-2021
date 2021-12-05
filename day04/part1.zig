const std = @import("std");
const loader = @import("loader.zig");
const Card = loader.Card;

const alloc = std.heap.page_allocator;

fn extract_order(draws: []u8) !std.ArrayList(u8) {
    var order = try std.ArrayList(u8).initCapacity(alloc, draws.len);

    try order.appendSlice(draws);
    for (draws) |d, i| {
        order.items[d] = @intCast(u8, i);
    }

    return order;
}

fn first_bingo(card: Card, order: []u8) u8 {
    var bingo: u8 = 255;

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

        if (max_row < bingo) {
            bingo = max_row;
        }
        if (max_col < bingo) {
            bingo = max_col;
        }

        i += 1;
    }
    return bingo;
}

const Winner = struct { draw: u8, card: Card };
fn first_card(cards: []Card, order: []u8) !Winner {
    var bingo: u8 = 255;
    var index: ?usize = 0;

    for (cards) |card, i| {
        const curr = first_bingo(card, order);
        if (curr <= bingo) {
            bingo = curr;
            index = i;
        }
    }

    if (index) |i| {
        return Winner{ .draw = bingo, .card = cards[i] };
    } else {
        return error.NoCardsSupplied;
    }
}

fn sum_unmarked(winner: Winner, order: []u8) usize {
    var sum: usize = 0;

    for (winner.card) |row| {
        for (row) |cell| {
            if (order[cell] > winner.draw) {
                sum += cell;
            }
        }
    }

    return sum;
}

pub fn main() anyerror!void {
    const input = try loader.load(alloc, "input.txt");
    defer input.deinit();

    var draw_order = try extract_order(input.draws);
    defer draw_order.deinit();

    const winner = try first_card(input.cards, draw_order.items);
    const sum = sum_unmarked(winner, draw_order.items);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("{}\n", .{input.draws[winner.draw] * sum});
}
