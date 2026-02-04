const std = @import("std");
const rl = @import("raylib");

const CELL_SIZE: i32 = 20;
const COLS: i32 = 40;
const ROWS: i32 = 30;
const SCREEN_W = COLS * CELL_SIZE;
const SCREEN_H = ROWS * CELL_SIZE;

const Position = struct { x: i32, y: i32 };

const Snake = struct {
    body: std.ArrayList(Position),
    dir: Position,
    allocator: std.mem.Allocator,

    fn init(allocator: std.mem.Allocator) !Snake {
        var body = std.ArrayList(Position).empty;          // ← .empty statt .init()
        try body.append(allocator, .{ .x = COLS / 2, .y = ROWS / 2 });
        return .{
            .body = body,
            .dir = .{ .x = 1, .y = 0 },
            .allocator = allocator,
        };
    }

    fn deinit(self: *Snake) void {
        self.body.deinit(self.allocator);                  // ← allocator mitgeben
    }

    fn changeDirection(self: *Snake, new_dir: Position) void {
        // Verhindert 180°-Drehung
        if (new_dir.x == -self.dir.x and new_dir.y == -self.dir.y) return;
        self.dir = new_dir;
    }

    fn update(self: *Snake, food: *Position) !bool {
        var head = self.body.items[0];
        head.x += self.dir.x;
        head.y += self.dir.y;

        // Wand-Kollision → Game Over
        if (head.x < 0 or head.x >= COLS or head.y < 0 or head.y >= ROWS) {
            return false;
        }

        // Selbst-Kollision
        for (self.body.items[1..]) |seg| {
            if (head.x == seg.x and head.y == seg.y) return false;
        }

        try self.body.insert(self.allocator, 0, head);     // ← allocator!

        // Essen gefressen?
        if (head.x == food.x and head.y == food.y) {
            food.* = .{
                .x = rl.getRandomValue(0, COLS - 1),
                .y = rl.getRandomValue(0, ROWS - 1),
            };
            // Kein pop() → wächst
        } else {
            _ = self.body.pop();                               // pop() ohne allocator
        }

        return true;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    rl.initWindow(SCREEN_W, SCREEN_H, "Snake in Zig + Raylib");
    defer rl.closeWindow();

    rl.setTargetFPS(10);

    var snake = try Snake.init(allocator);
    defer snake.deinit();

    var food = Position{
        .x = rl.getRandomValue(0, COLS - 1),
        .y = rl.getRandomValue(0, ROWS - 1),
    };

    var game_over = false;

    while (!rl.windowShouldClose()) {
        // Richtung ändern (nur eine pro Frame, um schnelles Wenden zu vermeiden)
        if (rl.isKeyPressed(.up))    snake.changeDirection(.{ .x = 0, .y = -1 });
        if (rl.isKeyPressed(.down))  snake.changeDirection(.{ .x = 0, .y = 1  });
        if (rl.isKeyPressed(.left))  snake.changeDirection(.{ .x = -1, .y = 0 });
        if (rl.isKeyPressed(.right)) snake.changeDirection(.{ .x = 1, .y = 0  });

        if (!game_over) {
            if (!try snake.update(&food)) {
                game_over = true;
            }
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        // Schlange zeichnen
        for (snake.body.items) |p| {
            rl.drawRectangle(
                p.x * CELL_SIZE,
                p.y * CELL_SIZE,
                CELL_SIZE,
                CELL_SIZE,
                rl.Color.lime,
            );
        }

        // Essen zeichnen
        rl.drawRectangle(
            food.x * CELL_SIZE,
            food.y * CELL_SIZE,
            CELL_SIZE,
            CELL_SIZE,
            rl.Color.red,
        );

        if (game_over) {
            const text = "GAME OVER - SPACE zum Neustart";
            const text_width = rl.measureText(text, 30);
            rl.drawText(text, @divTrunc(SCREEN_W, 2) - @divTrunc(text_width, 2), @divTrunc(SCREEN_H, 2) - 15, 30, rl.Color.red);

            if (rl.isKeyPressed(.space)) {
                snake.deinit();
                snake = try Snake.init(allocator);
                food = .{ .x = rl.getRandomValue(0, COLS - 1), .y = rl.getRandomValue(0, ROWS - 1) };
                game_over = false;
            }
        }
    }
}