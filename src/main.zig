const std = @import("std");
const fs = @import("fs.zig");
const unistd = @cImport({
    @cInclude("unistd.h");
});
const screen = @import("screen.zig");


fn set_user_name(f: *fs.fs) !void {
    const user_name = unistd.getlogin();
    var name_buf: [64]u8 = .{0} ** 64;
    if (user_name == 0x0) {
        var cwd_buf: [128]u8 = .{0} ** 128;
        const cwd = try std.posix.getcwd(&cwd_buf);
        var index = std.mem.indexOfScalar(u8, cwd[1..cwd.len], '/') orelse return;
        index += 2;
        for (0..128) |i| {
            if (cwd[index] == '/') {
                f.cfg.user_name = try f.allocator.dupe(u8, name_buf[0..i]);
                break;
            }
            name_buf[i] = cwd[index];
            index += 1;
        }
    } else {
        for (0..64) |i| {
            if (user_name[i] == 0) {
                f.cfg.user_name = try f.allocator.dupe(u8, name_buf[0..i]);
                break;
            }
            name_buf[i] = user_name[i];
        }
    }
}

// ADD_WORD,
// DELETE_WORD,
// SHOW_LIB_CONTENT,
// CHANGE_TRANSLATION,
fn lib_menu_opt() void {
    // try stdout.print("Select lib options\n", .{});
    // try stdout.print("1 - ADD WORD\n", .{});
    // try stdout.print("2 - DELETE WORD\n", .{});
    // try stdout.print("3 - SHOW LIB CONTENT\n", .{});
    // try stdout.print("4 - CHANGE TRANLATION\n", .{});
    // try stdout.print("5 - BACK TO MAIN MENU\n", .{});
}

fn main_menu_opt() void{
    // try stdout.print("Select options:\n", .{});
    // try stdout.print("1 - SELECT LIB\n", .{});
    // try stdout.print("2 - DELETE LIB\n", .{});
    // try stdout.print("3 - CREATE LIB\n", .{});
    // try stdout.print("4 - CREATE LIB FROM FILE\n", .{});
    // try stdout.print("5 - CHANGE LIB PATH\n", .{});
    // try stdout.print("6 - EXIT\n", .{});
}


fn menu_process(f: *fs.fs, s: *screen.Screen) void {
    _ = f;
    var main_menu = screen.Menu{.name = "Main options", 
                    .content = &[_][]const u8 {
                        "SELECT LIB",
                        "DELETE LIB",
                        "CREATE LIB",
                        "CREATE LIB FROM FILE",
                        "CHANGE LIB PATH",
                        "EXIT"
                    }, .pos = 0};

    s.menu(&main_menu);

    // while(true) {
    //
    // }
}


pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var f = fs.fs{ .allocator = allocator, .cfg = .{} };
    try set_user_name(&f);
    try f.readCfg();
    var main_screen = screen.Screen{};
    try main_screen.init();
    menu_process(&f, &main_screen);
    main_screen.deinit();
}

pub fn cleanup(f: *fs.fs) void {
    f.deinit();
}

