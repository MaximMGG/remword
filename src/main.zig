const std = @import("std");

const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();

var user_name_global: [64]u8 = .{0} ** 64;


fn set_user_name() !void {
    var user_name_buf: [64]u8 = undefined;
    const user_name = try std.posix.getcwd(&user_name_buf);
    @memcpy(user_name_global[0..user_name.len], user_name[0..user_name.len]);
}

fn main_menu() !void {
    try stdout.print("Hello diar {s}, welcome to memorizeble!\n", .{user_name_global});

}


pub fn main() !void {
    try set_user_name();
    try main_menu();
}


test "set_user_name_test" {
    try set_user_name();
    
    try std.testing.expectEqualStrings(&user_name_global, "maxim");

}
