const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("zephrone_runtime", .{
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

    const lib_unit_test = b.addTest(.{
        .root_module = mod,
    });

    lib_unit_test.root_module.linkLibrary(zglfw.artifact("glfw"));
    lib_unit_test.root_module.linkLibrary(zopengl.artifact("zopengl"));
    lib_unit_test.root_module.linkLibrary(zgui.artifact("imgui"));

    const run_lib_unit_test = b.addRunArtifact(lib_unit_test);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_test.step);
}
