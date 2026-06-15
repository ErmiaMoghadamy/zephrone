const std = @import("std");
const GameScene = @import("scene.zig").GameScene;

pub const Game = struct {
    io: std.Io,
    allocator: std.mem.Allocator,
    current_scene: GameScene,

    pub fn init(io: std.Io, allocator: std.mem.Allocator, initial_aspect: f32) !Game {
        return Game{
            .io = io,
            .allocator = allocator,
            .current_scene = try GameScene.init(io, allocator, initial_aspect),
        };
    }

    pub fn deinit(self: *Game) void {
        self.current_scene.deinit();
    }

    pub fn update(self: *Game, dt: f32, aspect: f32) !void {
        self.current_scene.update(dt, aspect);
    }

    pub fn render(self: *Game) !void {
        self.current_scene.draw();
    }
};
