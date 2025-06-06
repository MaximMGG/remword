const std = @import("std");
const c = @cImport({
    @cInclude("ncurses.h");
});
const lib = @import("lib.zig");

const HIGHLIGHTED = c.COLOR_PAIR(2);
const REGULAR = c.COLOR_PAIR(1);

pub const Screen = struct {
    stdscr: *c.WINDOW = undefined,
    max_y: c_int = 0,
    max_x: c_int = 0,
    y: c_int = 0,
    x: c_int = 0,
    cur_pos: c_int = 0,

    pub fn init(self: *Screen) !*Screen {
        self.stdscr = c.initscr() orelse return error.InitScrError;
        self.max_y = c.getmaxy(self.stdscr);
        self.max_x = c.getmaxx(self.stdscr);
        _ = c.noecho();
        _ = c.raw();
        _ = c.keypad(self.stdscr, true);
        _ = c.start_color();
    }

    pub fn deinit(self: *Screen) void {
        _ = self;
        _ = c.endwin();
    }

    pub fn readInput(self: *Screen) !void {

    }

};
