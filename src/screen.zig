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
    read_buffer: [4096]u8 = .{0} ** 4096,
    read_buffer_len: u32 = 0,

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
        const y_pos = self.max_y - @as(c_int, 10);
        const x_pos: i32 = @intFromFloat(@as(f32, @floatFromInt(self.max_y)) * 0.25);
        const y_size = 3;
        const x_size = @divTrunc(self.max_x, 2);
        const read_win = c.newwin(y_pos, x_pos, y_size, x_size) orelse return error.NewwinError;
        _ = c.box(read_win, 0, 0);
        _ = c.wrefresh(read_win);
        _ = c.keypad(read_win, true);

        @memset(&self.read_buffer, 0);
        self.read_buffer_len = 0;

        c = c.wprintw(read_win, ">: ");
        var ch: c_int = c.getch();
        while(ch != c.KEY_ENTER) {
            self.read_buffer[self.read_buffer_len] = @as(u8, @intCast(ch));
            self.read_buffer_len += 1;
            ch = c.getch();
        }

        _ = c.delwin(read_win);
    }
};
