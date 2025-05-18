const std = @import("std");
const fs = @import("fs.zig");
const unistd = @cImport({
    @cInclude("unistd.h");
});

const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();


fn set_user_name(f: *fs.fs) !void {
    const user_name = unistd.getlogin();
    var name_buf: [64]u8 = .{0} ** 64;
    if (user_name == 0x0) {
        var cwd_buf: [128]u8 = .{0} ** 128;
        const cwd = try std.posix.getcwd(&cwd_buf);
        var index = std.mem.indexOfScalar(u8, cwd[1..cwd.len], '/') orelse return;
        index += 2;
        for(0..128) |i| {
            if (cwd[index] == '/') {
                f.cfg.user_name = try f.allocator.dupe(u8, name_buf[0..i]);
                break;
            }
            name_buf[i] = cwd[index];
            index += 1;
        }
    } else {
        for(0..64) |i| {
            if (user_name[i] == 0) {
                f.cfg.user_name = try f.allocator.dupe(u8, name_buf[0..i]);
                break;
            }
            name_buf[i] = user_name[i];
        }
    }
}

fn main_menu(f: *fs.fs) !void {
    try stdout.print("Hello diar {s}, welcome to memorizeble!\n", .{f.cfg.user_name.?});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var f = fs.fs{.allocator = allocator, .cfg = .{}};
    try set_user_name(&f);
    try f.readCfg();
    try main_menu(&f);
    defer f.deinit() catch |err| {
        std.debug.print("fs deinit error {any}\n", .{err});
    };
}

pub fn cleanup(f: *fs.fs) void {
    f.deinit();
}

test "set_user_name_test" {
    var f = fs.fs{.allocator = std.testing.allocator, .cfg = .{}};
    try set_user_name(&f);
    defer f.deinit();
}

test "readCfgNullTest" {
    var f = fs.fs{.allocator = std.testing.allocator, .cfg = .{}};
    try set_user_name(&f);
    try f.readCfg();
    defer f.deinit();

}
