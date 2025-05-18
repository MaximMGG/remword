const std = @import("std");
const fs = @import("fs.zig");
const unistd = @cImport({
    @cInclude("unistd.h");
});

const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();

var user_name_global: [64]u8 = .{0} ** 64;


fn set_user_name() !void {

    const user_name = unistd.getlogin();
    var u: []u8 = undefined;
    u.ptr = @ptrCast(user_name);
    u.len = std.mem.len(user_name);

    @memcpy(user_name_global[0..u.len], u[0..u.len]);

}

fn main_menu() !void {
    try stdout.print("Hello diar {s}, welcome to memorizeble!\n", .{user_name_global});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    try set_user_name();
    var f = fs.fs{.allocator = allocator, .cfg = .{.user_name = user_name_global}};
    f.readCfg();
    try main_menu();
}

pub fn cleanup(f: *fs.fs) void {
    f.deinit();
}

test "set_user_name_test" {
    try set_user_name();
    
    try std.testing.expectEqualStrings(&user_name_global, "maxim");
}

test "readCfgNullTest" {
    try set_user_name();
    var f = fs.fs{.allocator = std.testing.allocator, .cfg = .{.user_name = user_name_global}};
    f.readCfg();

    defer f.deinit();

}
