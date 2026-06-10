const std = @import("std");
const zephrone = @import("zephrone");

pub fn main(init: std.process.Init) !void {
    _ = init;
    try zephrone.run();
}
