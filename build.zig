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

    k.addIncludePath(b.path("."));
    k.setLinkerScript(b.path("linker.ld"));
    k.addAssemblyFile(b.path("entry.S"));

    k.addCSourceFiles(.{
        .flags = &.{ "-mcmodel=medany", "-ffreestanding" },
        .files = &.{ "crt0.c", "tty.c", "kernel.c" },
    });

    b.installArtifact(k);

    const r = b.addSystemCommand(&.{
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

    r.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        r.addArgs(args);
    }

    const run_step = b.step("run", "Run the kernel with qemu virt machine");
    run_step.dependOn(&r.step);
}
