const std = @import("std");

pub const Card = [5][5]u8;
pub const Input = struct {
    draws: []u8,
    cards: []Card,
    alloc: *std.mem.Allocator,

    const Self = @This();

    pub fn deinit(self: Self) void {
        self.alloc.free(self.draws);
        self.alloc.free(self.cards);
    }
};

fn load_draws(alloc: *std.mem.Allocator, stream: anytype) !std.ArrayList(u8) {
    var draws = std.ArrayList(u8).init(alloc);
    errdefer draws.deinit();

    var buffer: [1024]u8 = undefined;
    if (try stream.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        var accumulator: u8 = 0;
        for (line) |char| {
            if (char == ',') {
                try draws.append(accumulator);
                accumulator = 0;
                continue;
            }
            accumulator *= 10;
            accumulator += char - '0';
        }
        try draws.append(accumulator);
    }

    return draws;
}

fn load_card(stream: anytype) !?Card {
    var buffer: [256]u8 = undefined;

    if ((try stream.read(buffer[0..1])) == 1 and buffer[0] == '\n') {
        var card = [_][5]u8{[_]u8{0} ** 5} ** 5;

        var row: u3 = 0;
        while (row < 5) {
            var col: u8 = 0;
            if (try stream.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
                var accumulator: ?u8 = null;
                for (line) |char| {
                    if (char >= '0' and char <= '9') {
                        if (accumulator) |acc| {
                            accumulator = acc * 10 + (char - '0');
                        } else {
                            accumulator = char - '0';
                        }
                    } else if (accumulator) |acc| {
                        card[row][col] = acc;
                        accumulator = null;
                        col += 1;
                    }
                }
                if (accumulator) |acc| {
                    card[row][col] = acc;
                }
            }
            if (col != 4) {
                return error.IncompleteCard;
            }
            row += 1;
        }
        return card;
    } else {
        return null;
    }
}

pub fn load(alloc: *std.mem.Allocator, path: []const u8) !Input {
    var file = try std.fs.cwd().openFile(path, .{ .read = true, .write = false });
    defer file.close();

    var reader = std.io.bufferedReader(file.reader());
    var stream = reader.reader();

    var draws = try load_draws(alloc, stream);
    errdefer draws.deinit();

    var cards = std.ArrayList(Card).init(alloc);
    errdefer cards.deinit();

    while ((try load_card(stream))) |card| {
        try cards.append(card);
    }

    return Input{ .draws = draws.toOwnedSlice(), .cards = cards.toOwnedSlice(), .alloc = alloc };
}
