const std = @import("std");

pub fn build(b: *std.Build) void {
    const run_sandbox_step = b.step("sandbox", "Run sandbox");

    const sandbox_build = b.addSystemCommand(&.{ b.graph.zig_exe, "build", "run" });
    sandbox_build.setCwd(b.path("sandbox-app"));

    run_sandbox_step.dependOn(&sandbox_build.step);


    const test_step = b.step("runtime-test", "Run runtime tests");
    _ = test_step;
}
