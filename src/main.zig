const std = @import("std");
const fs = @import("fs.zig");
const unistd = @cImport({
    @cInclude("unistd.h");
    @cInclude("locale.h");
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

fn lib_menu_process(s: *screen.Screen, f: *fs.fs) !void {
    var lib_menu = screen.Menu{.name = "Lib options", 
                    .content = &[_][]const u8 {
                        "ADD WORD",
                        "DELETE WORD",
                        "SHOW LIB CONTENT",
                        "CHANGE TRANSLATION",
                        "BAK TO MAIN MENU"
                    }, .pos = 0};

    while (true) {
        s.menu(&lib_menu);
        switch(lib_menu.pos) {
            0 => {
                try s.readPair();
                try f.cur_lib.?.addPair(&s.word, &s.translation, 0, false, false);
            },
            1 => {

            },
            2 => {

            },
            3 => {

            },
            4 => {
                if (f.cur_lib.?.changed) {
                    if (try s.askQuestion("Do you want to save lib changes?")) {
                        try f.writeLib();
                    } 
                }
                return;
            },
            else => {}
        }
    }
}

fn menu_process(f: *fs.fs, s: *screen.Screen) !void {
    var main_menu = screen.Menu{.name = "Main options", 
                    .content = &[_][]const u8 {
                        "SELECT LIB",
                        "DELETE LIB",
                        "CREATE LIB",
                        "CREATE LIB FROM FILE",
                        "CHANGE LIB PATH",
                        "EXIT"
                    }, .pos = 0};

    while(true) {
        s.menu(&main_menu);
        switch(main_menu.pos) {
            0 => {
                const lib_select = s.showLibs(&f.cfg.libs.?);
                try f.selectLib(lib_select);
                try lib_menu_process(s, f);
            },
            1 => {

            },
            2 => {

            },
            3 => {

            },
            4 => {

            },
            5 => {
                if (f.cur_lib.?.changed) {
                    if (try s.askQuestion("Do you want to save lib changes?")) {
                        try f.writeLib();
                    } 
                }
                return;
            },
            else => {}
        }

    }

    // while(true) {
    // }
}


pub fn main() !void {
    _ = unistd.setlocale(unistd.LC_CTYPE, "");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var f = fs.fs{ .allocator = allocator, .cfg = .{} };
    try set_user_name(&f);
    try f.readCfg();
    var main_screen = screen.Screen{};
    try main_screen.init();
    try menu_process(&f, &main_screen);
    main_screen.deinit();
}

pub fn cleanup(f: *fs.fs) void {
    f.deinit();
}

