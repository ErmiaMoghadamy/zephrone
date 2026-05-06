const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("zypher", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    const zglfw = b.dependency("zglfw", .{
        .target = target,
        .optimize = optimize,
    });

    const zopengl = b.dependency("zopengl", .{});

    const zstbi = b.dependency("zstbi", .{
        .target = target,
        .optimize = optimize,
    });

    const zmath = b.dependency("zmath", .{
        .target = target,
        .optimize = optimize,
    });

    const zgui = b.dependency("zgui", .{
        .shared = false,
        .with_implot = true,
        .backend = .glfw_opengl3,
    });

    mod.linkLibrary(zglfw.artifact("glfw"));
    mod.addImport("zglfw", zglfw.module("root"));

    mod.linkLibrary(zopengl.artifact("zopengl"));
    mod.addImport("zopengl", zopengl.module("root"));

    mod.linkLibrary(zgui.artifact("imgui"));
    mod.addImport("zgui", zgui.module("root"));

    mod.addImport("zstbi", zstbi.module("root"));
    mod.addImport("zmath", zmath.module("root"));

    const exe = b.addExecutable(.{
        .name = "zypher",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "zypher", .module = mod },
            },
        }),
    });

    exe.root_module.addImport("zopengl", zopengl.module("root"));
    exe.root_module.addImport("zgui", zgui.module("root"));
    exe.root_module.addImport("zstbi", zstbi.module("root"));
    exe.root_module.addImport("zmath", zmath.module("root"));

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });

    const run_mod_tests = b.addRunArtifact(mod_tests);

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);
}
