const std = @import("std");
const loader = @import("loader.zig");
const bingo = @import("bingo.zig");
const Card = loader.Card;

const alloc = std.heap.page_allocator;

fn first_card(cards: []Card, order: []u8) !bingo.Bingo {
    var round: u8 = 255;
    var index: ?usize = 0;

    for (cards) |card, i| {
        const curr = bingo.bingo_round(card, order);
        if (curr <= round) {
            round = curr;
            index = i;
        }
    }

    if (index) |i| {
        return bingo.Bingo{ .card = cards[i], .round = round };
    } else {
        return error.NoCardsSupplied;
    }
}

pub fn main() anyerror!void {
    const input = try loader.load(alloc, "input.txt");
    defer input.deinit();

    const winner = try first_card(input.cards, input.order);
    const sum = bingo.sum_unmarked(winner, input.order);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("{}\n", .{input.draws[winner.round] * sum});
}
