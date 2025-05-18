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

    libs: ?std.ArrayList([]u8),
};


pub const fs = struct {
    cfg: config = .{},
    allocator: std.mem.Allocator,

    pub fn readCfg(self: *fs) !void {
        var path_buf: [128]u8 = .{0} ** 128;

        try std.fmt.bufPrint(&path_buf, cfg_path, .{self.cfg.user_name.?});
        if (c.access(path_buf, c.F_OK) == 0) {
            const cfg_file = std.fs.openFileAbsolute(path_buf, .{.mode = .read_only}) catch |err| {
                std.debug.print("Error while open cfg file - {!}, try to create new config\n", .{err});
                self.createNewCfg();
                self.readCfg();
                return;
            };
            defer cfg_file.close();
            self.parseCfgFile(cfg_file) catch |err| {
                std.debug.print("Error while parse cfg file - {!}, try to create new config\n", .{err});
                self.createNewCfg();
                self.readCfg();
                return;
            };
        } else {
            self.createNewCfg();
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
            var lib_path_buf = try self.allocator.alloc(u8, 256);
            @memset(lib_path_buf, 0);
            for(cfg_buf[lib_index+1..cfg_len], 0..) |char, i| {
                if (char == '\"') {
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

    fn createNewCfg(self: *fs) void {
        var cfg_dirpath_buf: [128]u8 = .{0} ** 128;
        var cfg_path_buf: [128]u8 = .{0} ** 128;
        std.fmt.bufPrint(&cfg_path_buf, cfg_path, .{self.cfg.user_name});
        std.fmt.bufPrint(&cfg_dirpath_buf, cfg_dir_path, .{self.cfg.user_name});

        try std.fs.makeDirAbsolute(&cfg_dirpath_buf);
        const cfg_file = try std.fs.createFileAbsolute(&cfg_path_buf, .{});
        _ = try cfg_file.write(cfg_template);
        defer cfg_file.close();
    }


    pub fn deinit(self: *fs) void {
        self.allocator.free(self.cfg.lib_path);
        for(self.cfg.libs.?.items) |i| {
            self.allocator.free(i);
        }
        self.cfg.libs.?.deinit();
    }
};

