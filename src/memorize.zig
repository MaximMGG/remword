const std = @import("std");
const lib = @import("lib.zig");

pub const Memorize = struct {
    words_per_choose_task: u32 = 4,

    pub fn choose_word_task(self: *Memorize, cur_lib: *lib.Lib) !void {
        const index = std.Random.int(u32) / cur_lib.lib_content.items.len;

    } 

};
