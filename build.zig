const std = @import("std");

pub fn build(b: *std.Build) void {
    const run_sandbox_step = b.step("run-sandbox", "Run sandbox");
    const sandbox_build = b.addSystemCommand(&.{ b.graph.zig_exe, "build", "run" });
    sandbox_build.setCwd(b.path("sandbox"));
    run_sandbox_step.dependOn(&sandbox_build.step);

    const test_sandbox_step = b.step("test-sandbox", "Test sandbox");
    const sandbox_test = b.addSystemCommand(&.{ b.graph.zig_exe, "build", "test", "--summary", "all" });
    sandbox_test.setCwd(b.path("sandbox"));
    test_sandbox_step.dependOn(&sandbox_test.step);

    const test_engine_step = b.step("test-engine", "Test engine");
    const engine_test = b.addSystemCommand(&.{ b.graph.zig_exe, "build", "test", "--summary", "all" });
    engine_test.setCwd(b.path("engine"));
    test_engine_step.dependOn(&sandbox_test.step);
}
