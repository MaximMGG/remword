const std = @import("std");
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

    libs: ?std.ArrayList([]u8) = null,
};


pub const fs = struct {
    cfg: config = .{},
    allocator: std.mem.Allocator,

    pub fn readCfg(self: *fs) !void {
        var path_buf: [128]u8 = .{0} ** 128;

        const path_buf_fin = try std.fmt.bufPrint(&path_buf, 
                        cfg_path, .{self.cfg.user_name.?});
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
        if (std.mem.eql(u8, cfg_buf[lib_index..(lib_index + 1)], "\"\"")) {
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
        self.cfg.libs = std.ArrayList([]u8).init(self.allocator);
        lib_index = std.mem.indexOf(u8, &cfg_buf, "LIBS: ") orelse return error.UncorrectCfg;
        lib_index = std.mem.indexOfScalar(u8, &cfg_buf, '{') orelse return error.UncorrectCfg;
        var i: usize = lib_index;
        while(i < cfg_len) : (i += 1) {
            if (cfg_buf[i] == '"') {
                var lib_name_buf = try self.allocator.alloc(u8, 128);
                i += 1;
                for(i+1..cfg_len, 0..) |j, k| {
                    if (cfg_buf[j] == '"') {
                        try self.cfg.libs.?.append(lib_name_buf);
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


    pub fn deinit(self: *fs) void {
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

