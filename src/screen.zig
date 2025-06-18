const std = @import("std");
const c = @cImport({
    @cInclude("ncurses.h");
    @cInclude("locale.h");
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
    word: [128]u8 = .{0} ** 128,
    translation: [256]u8 = .{0} ** 256,

    pub fn init(self: *Screen) !void {
        self.screen = c.initscr() orelse return error.InitScrError;
        self.max_y = c.getmaxy(self.screen);
        self.max_x = c.getmaxx(self.screen);
        _ = c.setlocale(c.LC_CTYPE, "");
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
                '\n',
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

    pub fn showLibs(self: *Screen, l: *std.ArrayList([]const u8)) u32 {
        var libs_menu = Menu{.name = "Lib select", .content = l.items, .pos = 0};
        self.menu(&libs_menu);
        return libs_menu.pos;
    }

    pub fn readInput(self: *Screen, header: []const u8) !void {
        const y_pos = self.max_y - 10;
        const x_pos = @divTrunc(self.max_x, 4);
        const y_size = 3;
        const x_size = @divTrunc(self.max_x, 2);
        const read_win = c.newwin(y_size, x_size, y_pos, x_pos) orelse return error.NewwinError;
        _ = c.box(read_win, 0, 0);
        _ = c.mvwprintw(read_win, 0, 1, "%s", header.ptr);
        _ = c.wmove(read_win, 1, 1);
        _ = c.wrefresh(read_win);
        _ = c.echo();
        _ = c.keypad(read_win, true);

        @memset(&self.read_buffer, 0);
        self.read_buffer_len = 0;

        _ = c.wprintw(read_win, ">: ");
        var ch: c_int = c.wgetch(read_win);
        while(ch != c.KEY_ENTER or ch != @as(u8, '\n')) {
            if (ch == 0o407) {
                self.read_buffer[self.read_buffer_len] = @as(u8, 0);
                self.read_buffer_len -= 1;
                const read_y = c.getcury(read_win);
                const read_x = c.getcurx(read_win);
                _ = c.wmove(read_win, read_y, read_x - 1);
            }
            self.read_buffer[self.read_buffer_len] = @as(u8, @intCast(ch));
            self.read_buffer_len += 1;
            ch = c.wgetch(read_win);
        }

        _ = c.wclear(read_win);

        _ = c.wborder(read_win,
                    @as(c.chtype, ' '),
                    @as(c.chtype, ' '),
                    @as(c.chtype, ' '),
                    @as(c.chtype, ' '),
                    @as(c.chtype, ' '),
                    @as(c.chtype, ' '),
                    @as(c.chtype, ' '),
                    @as(c.chtype, ' '));
        _ = c.wrefresh(read_win);
        _ = c.delwin(read_win);
        _ = c.noecho();
    }


    pub fn askQuestion(self: *Screen, question: []const u8) !bool {
        const y_pos = self.max_y - 10;
        const x_pos = @divTrunc(self.max_x, 4);
        const y_size = 3;
        const x_size = @divTrunc(self.max_x, 2);
        const question_screen = c.newwin(y_pos, x_pos, y_size, x_size) orelse return error.NewWinError;
        _ = c.wprintw(question_screen, "%s y(yes)/n(no):> ", question.ptr);
        var ch: c_int = 0;
        while(ch != @as(u8, 'y') or ch != @as(u8, 'n')) : (ch = c.getch()){

        }
        if (ch == @as(u8, 'y')) {
            return true;
        } else {
            return false;
        }
    }

    pub fn readPair(self: *Screen) !void{
        @memset(&self.word, 0);
        @memset(&self.translation, 0);
        try self.readInput("Enter word");
        @memcpy(self.word[0..self.read_buffer_len], self.read_buffer[0..self.read_buffer_len]);
        try self.readInput("Enter tranlation or '.' for going to reversoContext");
        @memcpy(self.translation[0..self.read_buffer_len], 
            self.read_buffer[0..self.read_buffer_len]);
    }
};
