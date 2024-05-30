const std = @import("std");

pub fn build(b: *std.Build) !void {
    const k = b.addExecutable(.{
        .name = "kernel.elf",
        .optimize = b.standardOptimizeOption(.{}),
        .target = b.resolveTargetQuery(.{
            .cpu_arch = .riscv64,
            .os_tag = .freestanding,
            .abi = .none,
            .ofmt = .elf,
        }),
    });

    k.root_module.code_model = .medium;
    k.root_module.root_source_file = b.path("main.zig");
    k.setLinkerScript(b.path("linker.ld"));
    b.installArtifact(k);

    const qemu = b.addSystemCommand(&.{
        "qemu-system-riscv64",
        "-machine",
        "virt",
        "-display",
        "none",
        "-serial",
        "stdio",
        "-bios",
        "none",
        "-kernel",
        "zig-out/bin/kernel.elf",
    });

    qemu.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        qemu.addArgs(args);
    }

    const qemu_run = b.step("run", "Run the kernel with qemu virt machine");
    qemu_run.dependOn(&qemu.step);
}
