const std = @import("std");
const lib = @import("lib.zig");
const c = @cImport({
    @cInclude("unistd.h");
});

const cfg_path = "/home/{s}/.local/share/remword/remword.cfg";
const cfg_dir_path = "/home/{s}/.local/share/remword";
const cfg_template = 
\\LIB_PATH: ""
\\LIBS: {
\\}
;

pub const config = struct {
    user_name: ?[]const u8 = null,
    lib_path: ?[]const u8 = null,

    libs: ?std.ArrayList([]const u8) = null,
};


pub const fs = struct {
    cfg: config = .{},
    allocator: std.mem.Allocator,
    cur_lib: ?lib.Lib = null,

    pub fn readCfg(self: *fs) !void {
        var path_buf: [128]u8 = .{0} ** 128;

        const path_buf_fin = try std.fmt.bufPrint(&path_buf, cfg_path, .{self.cfg.user_name.?});
        if (c.access(path_buf_fin.ptr, c.F_OK) == 0) {
            const cfg_file = std.fs.openFileAbsolute(path_buf_fin, .{.mode = .read_only}) catch |err| {
                std.debug.print("Error while open cfg file - {any}, try to create new config\n", .{err});
                try self.createNewCfg();
                try self.readCfg();
                return;
            };
            defer cfg_file.close();
            self.parseCfgFile(cfg_file) catch |err| {
                std.debug.print("Error while parse cfg file - {any}, try to create new config\n", .{err});
                try self.createNewCfg();
                try self.readCfg();
                return;
            };
        } else {
            try self.createNewCfg();
        }
    }


    fn parseCfgFile(self: *fs, cfg_file: std.fs.File) !void {
        var cfg_buf: [4096]u8 = .{0} ** 4096;

        const cfg_reader = cfg_file.reader();
        const cfg_len = try cfg_reader.read(&cfg_buf);

        var lib_index = std.mem.indexOf(u8, &cfg_buf, "LIB_PATH: ") orelse return error.UncorrectCfg;
        lib_index = std.mem.indexOfScalar(u8, &cfg_buf, '\"') orelse return error.UncorrectCfg;
        if (std.mem.eql(u8, cfg_buf[lib_index..(lib_index + 2)], "\"\"")) {
            self.cfg.lib_path = null;
            self.cfg.libs = null;
            return;
        } else {
            var lib_path_buf: [256]u8 = .{0} ** 256;
            for(cfg_buf[lib_index+1..cfg_len], 0..) |char, i| {
                if (char == '\"') {
                    self.cfg.lib_path = try self.allocator.dupe(u8, lib_path_buf[0..i]);
                    break;
                }
                lib_path_buf[i] = char;
            }
        }
        self.cfg.libs = std.ArrayList([]const u8).init(self.allocator);
        lib_index = std.mem.indexOf(u8, &cfg_buf, "LIBS: ") orelse return error.UncorrectCfg;
        lib_index = std.mem.indexOfScalar(u8, &cfg_buf, '{') orelse return error.UncorrectCfg;
        var i: usize = lib_index;
        while(i < cfg_len) : (i += 1) {
            if (cfg_buf[i] == '"') {
                var lib_name_buf: [128]u8 = .{0} ** 128;
                i += 1;
                for(i..cfg_len, 0..) |j, k| {
                    if (cfg_buf[j] == '"') {
                        try self.cfg.libs.?.append(try self.allocator.dupe(u8, lib_name_buf[0..k]));
                        i += 1;
                        break;
                    }
                    lib_name_buf[k] = cfg_buf[j];
                    i += 1;
                }
            }
        }
    }

    fn createNewCfg(self: *fs) !void {
        var cfg_dirpath_buf: [128]u8 = .{0} ** 128;
        var cfg_path_buf: [128]u8 = .{0} ** 128;
        const cfg_path_fin = try std.fmt.bufPrint(&cfg_path_buf, cfg_path, .{self.cfg.user_name.?});
        const cfg_dirpath_fin = try std.fmt.bufPrint(&cfg_dirpath_buf, cfg_dir_path, .{self.cfg.user_name.?});

        try std.fs.makeDirAbsolute(cfg_dirpath_fin);
        const cfg_file = try std.fs.createFileAbsolute(cfg_path_fin, .{});
        _ = try cfg_file.write(cfg_template);
        defer cfg_file.close();
    }

    pub fn writeConfig(self: *fs) !void {
        var buf: [256]u8 = .{0} ** 256;
        const cfg_path_fin = try std.fmt.bufPrint(&buf, cfg_path, .{self.cfg.user_name.?});
        const cfg_file = try std.fs.openFileAbsolute(cfg_path_fin, .{.mode = .write_only});
        try cfg_file.setEndPos(0);
        defer cfg_file.close();
        @memset(&buf, 0);
        const lib_path = try std.fmt.bufPrint(&buf, "LIB_PATH: \"{s}\"\n", .{self.cfg.lib_path orelse ""});
        _ = try cfg_file.write(lib_path);
        _ = try cfg_file.write("LIBS: {\n");
        if (self.cfg.libs) |l_libs| {
            for(l_libs.items) |item| {
                @memset(&buf, 0);
                const lib_name = try std.fmt.bufPrint(&buf, "\"{s}\"\n", .{item});
                _ = try cfg_file.write(lib_name);
            }
        } 
        _ = try cfg_file.write("}\n");
     }
    pub fn createLib(self: *fs, lib_name: []const u8) !void {
        var buf: [256]u8 = .{0} ** 256;
        const path_to_dir = try std.fmt.bufPrint(&buf, cfg_dir_path, .{self.cfg.user_name.?});
        std.debug.print("paht to dir - {s}\n", .{path_to_dir});
        const path_to_lib = try std.mem.concat(self.allocator, u8, &[_][]const u8{self.cfg.lib_path.?, "/", lib_name});
        std.debug.print("new lib path - {s}\n", .{path_to_lib});
        defer self.allocator.free(path_to_lib);
        const new_lib_file = try std.fs.createFileAbsolute(path_to_lib, .{});
        defer new_lib_file.close();
        if (self.cfg.libs) |*l_libs| {
            try l_libs.append(try self.allocator.dupe(u8, lib_name));
        } else {
            self.cfg.libs = std.ArrayList([]const u8).init(self.allocator);
            try self.cfg.libs.?.append(try self.allocator.dupe(u8, lib_name));
        }
    }

    pub fn createLibFromFile(f: *fs, path_to_file: []const u8, file_name: []u8) !void {
        const file_path = try std.mem.concat(f.allocator, u8, &[_][]const u8{path_to_file, "/", file_name});
        const file = try std.fs.openFileAbsolute(file_path, .{.mode = .read_only});
        const buf_file = try file.reader().readAllAlloc(f.allocator, 40960);

    }

    fn parseLib(self: *fs, lib_buf: []u8) !void {
        var i: usize = 0;
        var key_buf: [128]u8 = .{0} ** 128;
        var k_i: usize = 0;
        var val_buf: [256]u8 = .{0} ** 256;
        var v_i: usize = 0;
        var known_level: [16]u8 = .{0} ** 16;
        var level_i: usize = 0;
        var known_translation: bool = false;
        var known_write: bool = false;
        while(i < lib_buf.len) : (i += 1){
            if (lib_buf[i] == '\"') {
                i += 1;
                while(lib_buf[i] != '\"') : (i += 1) {
                    key_buf[k_i] = lib_buf[i];
                    k_i += 1;
                }
                i += 1;
                while(lib_buf[i] != '\"') : (i += 1){}
                i += 1;
                while(lib_buf[i] != '\"') : (i += 1) {
                    val_buf[v_i] = lib_buf[i];
                    v_i += 1;
                }
                i += 2;
                while(lib_buf[i] != ' ') : (i += 1) {
                    known_level[level_i] = lib_buf[i];
                    level_i += 1;
                }
                i += 1;
                if (lib_buf[i] == 't') {
                    known_translation = true;
                } else if (lib_buf[i] == 'f') {
                    known_translation = false;
                }
                i += 1;
                if (lib_buf[i] == 't') {
                    known_write = true;
                } else if (lib_buf[i] == 'f') {
                    known_write = false;
                }

                const level: f32 = try std.fmt.parseFloat(f32, known_level[0..level_i]);
                try self.cur_lib.?.addPair(key_buf[0..k_i], val_buf[0..v_i], level, known_translation, known_write);
                //while(key_buf[i] != '\"' and i < lib_buf.len) : (i += 1) {}
                @memset(&key_buf, 0);
                @memset(&val_buf, 0);
                @memset(&known_level, 0);
                k_i = 0;
                v_i = 0;
                level_i = 0;
            }
        }
        self.cur_lib.?.changed = false;
    }

    pub fn selectLib(self: *fs, lib_index: u32) !void {
        if (self.cur_lib == null) {
            self.cur_lib = lib.Lib{
                .lib_name = self.cfg.libs.?.items[lib_index], 
                .allocator = self.allocator, 
                .lib_content = std.ArrayList(*lib.Word).init(self.allocator),
                .changed = false
            };
        } else {
            self.cur_lib.?.freeLib();
            self.cur_lib.?.lib_content = std.ArrayList(*lib.Word).init(self.allocator);
            self.cur_lib.?.lib_name = self.cfg.libs.?.items[lib_index];
            self.cur_lib.?.changed = false;
        }
        const lib_path = try std.mem.concat(self.allocator, u8, 
            &[_][]const u8{self.cfg.lib_path.?, "/", self.cfg.libs.?.items[lib_index]});
        defer self.allocator.free(lib_path);

        const lib_file = try std.fs.openFileAbsolute(lib_path, .{.mode = .read_only});
        const lib_buf = try lib_file.reader().readAllAlloc(self.allocator, 40960);
        defer self.allocator.free(lib_buf);
        try self.parseLib(lib_buf);
    }

    pub fn deleteLib(self: *fs, lib_name: []const u8) !void {
        const path_to_lib = try std.mem.concat(self.allocator, u8, &[_][]const u8{self.cfg.lib_path.?, "/", lib_name});
        try std.fs.deleteFileAbsolute(path_to_lib);
        self.allocator.free(path_to_lib);
    }

    pub fn writeLib(self: *fs) !void {
        var index: usize = 1;
        const lib_path = try std.mem.concat(self.allocator, u8, 
                    &[_][]const u8{self.cfg.lib_path.?, "/", self.cur_lib.?.lib_name});
        defer self.allocator.free(lib_path);
        const lib_file = try std.fs.openFileAbsolute(lib_path, .{.mode = .write_only});
        try lib_file.setEndPos(0);
        defer lib_file.close();
        var buf: [256]u8 = .{0} ** 256;
        for(self.cur_lib.?.lib_content.items) |word| {
            // var kt: u8 = undefined;
            // if (word.known_translation) {
            //     kt = 't';
            // } else {
            //     kt = 'f';
            // }
            // var kw: u8 = undefined;
            // if (word.known_how_write) {
            //     kw = 't';
            // } else {
            //     kw = 'f';
            // }
            const buf_to_write = try std.fmt.bufPrint(&buf, "{d}. \"{s}\" - \"{s}\" {d} {c} {c}\n", 
                .{index, word.key, word.val, word.well_known, //kt, kw});
                    if (word.known_translation == true) @as(u8, 't') else @as(u8, 'f'),
                    if (word.known_how_write == true) @as(u8, 't') else @as(u8, 'f')});
            index += 1;
            _ = try lib_file.write(buf_to_write);
        }

        self.cur_lib.?.changed = false;
    }

    pub fn deinit(self: *fs) !void {
        try self.writeConfig();
        if (self.cfg.lib_path) |lp| {
            self.allocator.free(lp);
        }
        if (self.cfg.user_name) |un| {
            self.allocator.free(un);
        }

        if (self.cfg.libs) |l| {
            for(l.items) |it| {
                self.allocator.free(it);
            }

            l.deinit();
        }
    }
};

