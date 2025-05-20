const std = @import("std");
const fs = @import("fs.zig");
const unistd = @cImport({
    @cInclude("unistd.h");
});

const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();

const MAIN_MENU_OPT = enum {
    CREATE_LIB,
    DELETE_LIB,
    CHANGE_LIB_PATH,
    SELECT_LIB,
    EXIT
};

const LIB_MENU_OPT = enum {
    ADD_WORD,
    DELETE_WORD,
    SHOW_LIB_CONTENT
};

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

fn lib_menu_opt() !LIB_MENU_OPT {

}

fn main_menu_opt() !MAIN_MENU_OPT {
    try stdout.print("Select options:\n", .{});
    try stdout.print("1 - SELECT LIB\n", .{});
    try stdout.print("2 - DELETE LIB\n", .{});
    try stdout.print("3 - CREATE LIB\n", .{});
    try stdout.print("3 - CHANGE LIB PATH\n", .{});
    try stdout.print("5 - EXIT\n", .{});
    var input_buf: [16]u8 = .{0} ** 16;
    const read_bytes = try stdin.read(&input_buf);
    const input = try std.fmt.parseInt(u32, input_buf[0..read_bytes - 1], 10);
    switch(input) {
        1 => {
            return .SELECT_LIB;
        },
        2 => {
            return .DELETE_LIB;
        },
        3 => {
            return .CREATE_LIB;
        },
        4 => {
            return .CHANGE_LIB_PATH;
        },
        5 => {
            return .EXIT;
        },
        else => {
            try stdout.print("Incorect options - {d}\nTry agane", .{input});
            return main_menu_opt();
        }
    }
}

fn lib_menu() !void {

}

fn main_menu(f: *fs.fs) !void {
    try stdout.print("Hello diar {s}, welcome to memorizeble!\n", .{f.cfg.user_name.?});
    if (f.cfg.lib_path == null) {
        try stdout.print("Please, set path to your lib: ", .{});
        var path_buf: [128]u8 = .{0} ** 128;
        const read_bytes = try stdin.read(&path_buf);
        if (read_bytes > 0) {
            f.cfg.lib_path = try f.allocator.dupe(u8, path_buf[0..read_bytes - 1]);
        }
    }

    while(true) {
        switch(try main_menu_opt()) {
            .SELECT_LIB => {
                try stdout.print("Enter lib number: \n", .{});
                for(f.cfg.libs.?.items, 0..) |lib, lib_number| {
                    try stdout.print("{d} - {s}\n", .{lib_number + 1, lib});
                }
                var num_buf: [16]u8 = .{0} ** 16;
                var read_bytes = try stdin.read(&num_buf);
                const num = try std.fmt.parseInt(u32, num_buf[0..read_bytes - 1], 10);
                if ((num - 1) >= f.cfg.libs.?.items.len) {
                    try stdout.print("Lib with number {d} not existes\n", .{num});
                    continue;
                } else {
                    try stdout.print("You select lib - {s}\n", .{f.cfg.libs.?.items[num - 1]});
                }
                if (f.cur_lib == null) {
                    try f.selectLib(num - 1);
                } else if (f.cur_lib.?.changed == true) {
                    try stdout.print("Do you want save changes in lib {s}\n", .{f.cur_lib.?.lib_name});
                    try stdout.print("Enter y (yes) / n (no) : ", .{});
                    var buf: [16]u8 = .{0} ** 16;
                    read_bytes = try stdin.read(&buf);
                    if (read_bytes > 0) {
                        if (buf[0] == 'y') {
                            f.writeLib();
                            try f.selectLib(num - 1);
                        }
                    } else if (buf[0] == 'n') {
                        try f.selectLib(num - 1);
                    } else {
                        try stdout.print("Wrong option {s}\n", .{buf});
                        continue;
                    }

                }
            },
            .DELETE_LIB => {
                for(f.cfg.libs.?.items, 0..) |it, lib_index| {
                    try stdout.print("{d} - {s}\n", .{lib_index + 1, it});
                }
                try stdout.print("Enter lib number: \n", .{});
                var buf: [16]u8 = .{0} ** 16;
                var read_bytes = try stdin.read(&buf);
                const num = try std.fmt.parseInt(u32, buf[0..read_bytes - 1], 10);
                if (num <= 0 and num >= f.cfg.libs.?.items.len) {
                    try stdout.print("Incorrect lib number {d}\n", .{num});
                    continue;
                }
                try stdout.print("Are you shure the you whant to delete lib {s} with all content?\n", .{f.cfg.libs.?.items[num - 1]});
                try stdout.print("Enter y (yes) / n (no) : ", .{});
                @memset(&buf, 0);
                read_bytes = try stdin.read(&buf);
                if (buf[0] == 'y') {
                    const rem_item = f.cfg.libs.?.orderedRemove(num - 1);
                    try stdout.print("Removing lib - {s}\n", .{rem_item});
                    try f.deleteLib(rem_item);
                    f.allocator.free(rem_item);
                } else if (buf[0] == 'n') {
                    continue;
                } else {
                    try stdout.print("Wrong option {s}\n", .{buf});
                    continue;
                }
            },
            .CREATE_LIB => {
                try stdout.print("Enter new lib name: ", .{});
                var buf: [128]u8 = .{0} ** 128;
                const read_bytes = try stdin.read(&buf);
                try f.createLib(buf[0..read_bytes - 1]);
                try stdout.print("Created lib: {s}\n", .{buf[0..read_bytes - 1]});
            },
            .CHANGE_LIB_PATH => {
                try stdout.print("Your current path to word dir - {s}\n", .{f.cfg.lib_path.?});
                try stdout.print("Do you want to change it? y (yes) / n (no): ", .{});
                var buf: [128]u8 = .{0} ** 128;
                _ = try stdin.read(&buf);
                if (buf[0] == 'y') {
                    @memset(&buf, 0);
                    try stdout.print("Enter new word dir path: ", .{});
                    const read_bytes = try stdin.read(&buf);
                    if (read_bytes > 1) {
                        f.allocator.free(f.cfg.lib_path.?);
                        f.cfg.lib_path = try f.allocator.dupe(u8, buf[0..read_bytes - 1]);
                        try stdout.print("You new work dir path: {s}\n", .{f.cfg.lib_path.?});
                    } else {
                        try stdout.print("You do not enter path\n", .{});
                    }
                } else if (buf[0] == 'n') {
                    continue;
                } else {
                    try stdout.print("Wrong option\n", .{});
                }
            },
            .EXIT => {
                break;
            }
        }
    }
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
