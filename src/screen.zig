const std = @import("std");
const c = @cImport({
    @cInclude("ncurses.h");
});
const lib = @import("lib.zig");


pub const Menu = struct {
    name: []const u8 = undefined,
    content: []const []const u8 = undefined,
    pos: u32 = 0,
};

pub const Screen = struct {
    screen: *c.WINDOW = undefined,
    max_y: c_int = 0,
    max_x: c_int = 0,
    y: c_int = 0,
    x: c_int = 0,
    read_buffer: [4096]u8 = .{0} ** 4096,
    read_buffer_len: u32 = 0,

    pub fn init(self: *Screen) !void {
        self.screen = c.initscr() orelse return error.InitScrError;
        self.max_y = c.getmaxy(self.screen);
        self.max_x = c.getmaxx(self.screen);
        _ = c.noecho();
        _ = c.raw();
        _ = c.keypad(self.screen, true);
        _ = c.start_color();
        _ = c.init_pair(1, c.COLOR_WHITE, c.COLOR_BLACK);
        _ = c.init_pair(2, c.COLOR_BLACK, c.COLOR_WHITE);
        _ = c.refresh();
    }

    pub fn deinit(self: *Screen) void {
        _ = self;
        _ = c.endwin();
    }

    pub fn menu(self: *Screen, m: *Menu) void {
        self.y = 0;
        self.x = 0;
        var l: u32 = 1;
        var ch: c_int = 0;
        while(true) {
            _ = c.clear();
            switch(ch) {
                c.KEY_DOWN,
                'j' => {
                    if (m.content.len - 1 > m.pos) {
                        m.pos += 1;
                    }
                },
                c.KEY_UP,
                'k' => {
                    if (m.pos > 0) {
                        m.pos -= 1;
                    }
                },
                c.KEY_F(1),
                c.KEY_ENTER => {
                    return;
                },
                else => {

                }
            }

            _ = c.printw("%s\n", m.name.ptr);
            self.y = 0;
            for(m.content) |line| {
                if (self.y == m.pos) {
                    _ = c.attron(c.COLOR_PAIR(2));
                    _ = c.printw("%d - %s\n", l, line.ptr);
                    _ = c.attroff(c.COLOR_PAIR(2));
                } else {
                    _ = c.attron(c.COLOR_PAIR(1));
                    _ = c.printw("%d - %s\n", l, line.ptr);
                    _ = c.attroff(c.COLOR_PAIR(1));
                }
                l += 1;
                self.y += 1;
            }
            l = 1;
            _ = c.refresh();
            ch = c.getch();
        }
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
