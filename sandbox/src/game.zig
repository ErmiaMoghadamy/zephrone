const std = @import("std");
const zm = @import("zephrone_runtime").zmath;
const event = @import("zephrone_runtime").platform.event;
const FrameContext = @import("zephrone_runtime").platform.FrameContext;
const Renderer = @import("zephrone_runtime").graphics.Renderer;
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

    pub fn deinit(self: *Game, allocator: std.mem.Allocator) void {
        self.current_scene.deinit(allocator);
    }

    pub fn bootstrap(self: *Game, allocator: std.mem.Allocator) !void {
        try self.current_scene.bootstrap(allocator);
    }

    pub fn update(self: *Game, frame_ctx: FrameContext) !void {
        self.current_scene.update(frame_ctx.dt, frame_ctx.aspect);
    }

    pub fn render(self: *Game, renderer: *Renderer) !void {
        self.current_scene.draw(renderer);
    }
};
