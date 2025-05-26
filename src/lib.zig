const std = @import("std");
const c = @cImport({
    @cInclude("stdlib.h");
    @cInclude("unistd.h");
});

const stdout = std.io.getStdOut().writer();

pub const Word = struct { key: []u8, val: []u8, well_known: f32 = 0.0, know_tranlation: bool = false, know_how_write: bool = false };

pub const Lib = struct {
    lib_content: std.StringHashMap([]const u8),
    allocator: std.mem.Allocator,
    lib_name: []const u8,
    changed: bool = false,

    pub fn showContent(self: *Lib) !void {
        var it = self.lib_content.iterator();
        var index: u32 = 1;
        while (it.next()) |pair| {
            try stdout.print("{d}. {s} - {s}\n", .{ index, pair.key_ptr.*, pair.value_ptr.* });
            index += 1;
        }
    }

    pub fn addPair(self: *Lib, word: []const u8, tranlation: []const u8) !void {
        try self.lib_content.put(word, tranlation);
        self.changed = true;
    }

    pub fn changeTranlation(self: *Lib, word: []const u8, new_tranlation: []const u8) !void {
        const old_translation = self.lib_content.getEntry(word) orelse return error.KeyDoestExists;
        self.allocator.free(old_translation.value_ptr.*);
        old_translation.value_ptr.* = try self.allocator.dupe(u8, new_tranlation);
        self.changed = true;
    }

    pub fn deletePair(self: *Lib, word: []const u8) !void {
        const for_delete = self.lib_content.fetchRemove(word) orelse return error.KeyDoestExists;
        self.allocator.free(for_delete.key);
        self.allocator.free(for_delete.value);
        self.changed = true;
    }

    pub fn freeLib(self: *Lib) void {
        var it = self.lib_content.iterator();
        while (it.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
            self.allocator.free(entry.value_ptr.*);
        }
        self.lib_content.deinit();
    }
    pub fn goToReversoContext(self: *Lib, word: []u8) !void {
        _ = self;
        const pid = c.fork();
        if (pid == 0) {
            var buf: [256]u8 = .{0} ** 256;
            const to_execute = try std.fmt.bufPrint(&buf, "google-chrome https://context.reverso.net/translation/english-russian/{s} > /dev/null", .{word});
            _ = c.system(to_execute.ptr);
            c._exit(0);
        }
    }
};
