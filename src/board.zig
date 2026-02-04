const std = @import("std");
const snake = @import("snake.zig");

pub fn draw(game: *snake.Game, writer: anytype) void {
    _ = writer.print("\x1b[2J\x1b[H", .{}); // Terminal clear
    for (game.y in 0..game.height) {
        for (game.x in 0..game.width) {
            if (snake.is_snake(game, game.x, game.y)) {
                _ = writer.print("O", .{});
            } else if (game.food_x == game.x and game.food_y == game.y) {
                _ = writer.print("*", .{});
            } else {
                _ = writer.print(" ", .{});
            }
        }
        _ = writer.print("\n", .{});
    }
}
