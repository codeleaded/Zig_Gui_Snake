const std = @import("std");

pub const Direction = enum { Up, Down, Left, Right };

pub const Game = struct {
    width: usize,
    height: usize,
    snake_x: []usize = &[_]usize{},
    snake_y: []usize = &[_]usize{},
    snake_len: usize = 1,
    dir: Direction = .Right,
    food_x: usize,
    food_y: usize,
    game_over: bool = false,
    score: usize = 0,

    pub fn init(w: usize, h: usize) Game {
        var g = Game{
            .width = w,
            .height = h,
            .snake_len = 1,
            .dir = .Right,
            .game_over = false,
            .score = 0,
        };
        g.snake_x = [_]usize{ w / 2 };
        g.snake_y = [_]usize{ h / 2 };
        g.food_x = 3;
        g.food_y = 3;
        return g;
    }
};

pub fn update(g: *Game) void {
    // TODO: Bewegung & Kollisionen
}

pub fn is_snake(g: *Game, x: usize, y: usize) bool {
    for (g.snake_len) |i| {
        if (g.snake_x[i] == x and g.snake_y[i] == y) return true;
    }
    return false;
}
