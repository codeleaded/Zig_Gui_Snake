const std = @import("std");
const snake = @import("snake.zig");
const board = @import("board.zig");
const utils = @import("utils.zig");

pub fn main() !void {
    var stdout = std.io.getStdOut().writer();
    defer stdout.flush() catch {};

    var game = snake.Game.init(20, 10); // Board 20x10
    while (!game.game_over) {
        board.draw(&game, &stdout);
        snake.update(&game);
        utils.sleep_ms(200);
    }

    try stdout.print("Game Over! Score: {}\n", .{game.score});
}
