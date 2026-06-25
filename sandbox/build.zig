const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const runtime_dep = b.dependency("zephrone_runtime", .{
        .target = target,
        .optimize = optimize
    });

    const runtime_mod = runtime_dep.module("zephrone_runtime");

    const exe = b.addExecutable(.{
        .name = "sandbox_app",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "zephrone_runtime", .module = runtime_mod },
            },
        }),
    });

    exe.root_module.addImport("zephrone_runtime", runtime_mod);
    exe.use_lld = false;

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // const mod_tests = b.addTest(.{
    //     .root_module = runtime,
    // });

    // const run_mod_tests = b.addRunArtifact(mod_tests);

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    // test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);

}
