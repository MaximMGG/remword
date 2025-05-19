const std = @import("std");

const stdout = std.io.getStdOut().writer();

const Lib = struct {
    lib_len: u32 = 0,
    cur_lib: std.HashMap([]const u8, []const u8),

    pub fn showContent(self: *Lib) !void {
        var it = self.cur_lib.iterator();
        var index: u32 = 1;
        while(it.next()) |pair| {
            try stdout.print("{d}. {s} - {s}\n", .{index, pair.key_ptr, pair.value_ptr});
            index += 1;
        }
    }

    pub fn addPair(self: *Lib, word: []const u8, tranlation: []const u8) !void {
        try self.cur_lib.put(word, tranlation);
    }

    pub fn chaneTranlation(self: *Lib, word: []const u8, new_tranlation: []const u8) !void {
        const old_translation = self.cur_lib.getEntry(word) orelse return error.KeyDoestExists;

    }
};
