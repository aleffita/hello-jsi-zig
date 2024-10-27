const std = @import("std");

pub fn build(b: *std.Build) void {
    const hermes_build_path = b.option([]const u8, "HERMES_BUILD_DIR", "Hermes build directory") orelse {
        std.log.err("Error: HERMES_BUILD_DIR option not set", .{});
        std.process.exit(1);
    };

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{ .name = "hello", .target = target, .optimize = optimize });
    exe.addCSourceFile(.{ .file = b.path("src/main.cpp"), .flags = &.{"-std=c++14"} });

    exe.addIncludePath(.{ .cwd_relative = "./include" });

    const lib_path = b.fmt("{s}/lib", .{hermes_build_path});
    const jsi_path = b.fmt("{s}/jsi", .{hermes_build_path});

    exe.addLibraryPath(.{ .cwd_relative = lib_path });
    exe.addLibraryPath(.{ .cwd_relative = jsi_path });

    exe.linkLibCpp();

    exe.linkSystemLibrary("hermesvm");
    exe.linkSystemLibrary("jsi");

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
