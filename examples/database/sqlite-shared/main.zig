//--------------------------------------------------------------------------------
// sudo apt install -y libsqlite3-dev
//--------------------------------------------------------------------------------
const std = @import("std");
//--------------------------------------------------------------------------------
const DATABASE_FILEPATH = "test1.db";
//--------------------------------------------------------------------------------
const Context = struct { count: usize = 0 };
//--------------------------------------------------------------------------------
pub fn main() !u8 {
    //--------------------------------------------------------------------------------
    // optionl context - if not used then null can be passed
    var context = Context{}; // passed by reference if used
    //--------------------------------------------------------------------------------
    var db_handle: ?*anyopaque = null;
    //------------------------------------------------------------
    defer _ = sqlite3_close(db_handle);
    //------------------------------------------------------------
    std.debug.print("{s}\n", .{"-" ** 80});
    //------------------------------------------------------------
    {
        //----------------------------------------
        const rc = sqlite3_open(DATABASE_FILEPATH, &db_handle);
        if (rc != SQLITE_OK) {
            std.debug.print("sqlite3_open: {s}\n", .{sqlite3_errmsg(db_handle)});
            return SQLITE_ERROR;
        }
        //----------------------------------------
    }
    //--------------------------------------------------------------------------------
    {
        //----------------------------------------
        const sql = "PRAGMA journal_mode=WAL;";
        //----------------------------------------
        var errmsg: [*c]u8 = null;
        const rc = sqlite3_exec(db_handle, sql, execCallback, &context, &errmsg);
        if (rc != SQLITE_OK) {
            defer sqlite3_free(errmsg);
            std.debug.print("sqlite3_exec: {s}\n", .{errmsg});
            return SQLITE_ERROR;
        }
        //----------------------------------------
    }
    //--------------------------------------------------------------------------------
    {
        //----------------------------------------
        const sql = "DROP TABLE IF EXISTS test;";
        //----------------------------------------
        var errmsg: [*c]u8 = null;
        const rc = sqlite3_exec(db_handle, sql, execCallback, &context, &errmsg);
        if (rc != SQLITE_OK) {
            defer sqlite3_free(errmsg);
            std.debug.print("sqlite3_exec: {s}\n", .{errmsg});
            return SQLITE_ERROR;
        }
        //----------------------------------------
    }
    //--------------------------------------------------------------------------------
    {
        //----------------------------------------
        const sql = "CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR(255));";
        //----------------------------------------
        var errmsg: [*c]u8 = null;
        const rc = sqlite3_exec(db_handle, sql, execCallback, &context, &errmsg);
        if (rc != SQLITE_OK) {
            defer sqlite3_free(errmsg);
            std.debug.print("sqlite3_exec: {s}\n", .{errmsg});
            return SQLITE_ERROR;
        }
        //----------------------------------------
    }
    //--------------------------------------------------------------------------------
    {
        //----------------------------------------
        const sql =
            \\INSERT INTO test (name) VALUES ('name1');
            \\INSERT INTO test (name) VALUES ('name2');
        ;
        //----------------------------------------
        var errmsg: [*c]u8 = null;
        const rc = sqlite3_exec(db_handle, sql, execCallback, &context, &errmsg);
        if (rc != SQLITE_OK) {
            defer sqlite3_free(errmsg);
            std.debug.print("sqlite3_exec: {s}\n", .{errmsg});
            return SQLITE_ERROR;
        }
        //----------------------------------------
    }
    //--------------------------------------------------------------------------------
    {
        //----------------------------------------
        const sql = "SELECT * FROM test;";
        //----------------------------------------
        var errmsg: [*c]u8 = null;
        const rc = sqlite3_exec(db_handle, sql, execCallback, &context, &errmsg);
        if (rc != SQLITE_OK) {
            defer sqlite3_free(errmsg);
            std.debug.print("sqlite3_exec: {s}\n", .{errmsg});
            return SQLITE_ERROR;
        }
        //----------------------------------------
    }
    //--------------------------------------------------------------------------------
    std.debug.print("counter = {d}\n", .{context.count});
    std.debug.print("{s}\n", .{"-" ** 80});
    //--------------------------------------------------------------------------------
    return SQLITE_OK;
    //--------------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
fn execCallback(
    ctx: ?*anyopaque,
    argc: c_int,
    argv: [*c][*c]u8,
    azColName: [*c][*c]u8,
) callconv(.c) c_int {
    //--------------------------------------------------------------------------------
    // optional context pointer - null if not used
    if (ctx) |ctx_ptr| {
        const context: *Context = @ptrCast(@alignCast(ctx_ptr));
        context.count += 1;
    }
    //--------------------------------------------------------------------------------
    for (0..@intCast(argc)) |i| {
        //----------------------------------------
        if (argv[i] == null) {
            std.debug.print("{s} = NULL\n", .{azColName[i]});
        } else {
            std.debug.print("{s} = {s}\n", .{ azColName[i], argv[i] });
        }
        //----------------------------------------
    }
    std.debug.print("{s}\n", .{"-" ** 80});
    //--------------------------------------------------------------------------------
    return SQLITE_OK;
    //--------------------------------------------------------------------------------
}
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
pub const SQLITE_INTEGER = @as(i32, 1);
pub const SQLITE_FLOAT = @as(i32, 2);
pub const SQLITE_TEXT = @as(i32, 3);
pub const SQLITE_BLOB = @as(i32, 4);
pub const SQLITE_NULL = @as(i32, 5);
//--------------------------------------------------------------------------------
pub const SQLITE_OK = @as(i32, 0);
pub const SQLITE_ERROR = @as(i32, 1);
pub const SQLITE_INTERNAL = @as(i32, 2);
pub const SQLITE_PERM = @as(i32, 3);
pub const SQLITE_ABORT = @as(i32, 4);
pub const SQLITE_BUSY = @as(i32, 5);
pub const SQLITE_LOCKED = @as(i32, 6);
pub const SQLITE_NOMEM = @as(i32, 7);
pub const SQLITE_READONLY = @as(i32, 8);
pub const SQLITE_INTERRUPT = @as(i32, 9);
pub const SQLITE_IOERR = @as(i32, 10);
pub const SQLITE_CORRUPT = @as(i32, 11);
pub const SQLITE_NOTFOUND = @as(i32, 12);
pub const SQLITE_FULL = @as(i32, 13);
pub const SQLITE_CANTOPEN = @as(i32, 14);
pub const SQLITE_PROTOCOL = @as(i32, 15);
pub const SQLITE_EMPTY = @as(i32, 16);
pub const SQLITE_SCHEMA = @as(i32, 17);
pub const SQLITE_TOOBIG = @as(i32, 18);
pub const SQLITE_CONSTRAINT = @as(i32, 19);
pub const SQLITE_MISMATCH = @as(i32, 20);
pub const SQLITE_MISUSE = @as(i32, 21);
pub const SQLITE_NOLFS = @as(i32, 22);
pub const SQLITE_AUTH = @as(i32, 23);
pub const SQLITE_FORMAT = @as(i32, 24);
pub const SQLITE_RANGE = @as(i32, 25);
pub const SQLITE_NOTADB = @as(i32, 26);
pub const SQLITE_NOTICE = @as(i32, 27);
pub const SQLITE_WARNING = @as(i32, 28);
pub const SQLITE_ROW = @as(i32, 100);
pub const SQLITE_DONE = @as(i32, 101);
//--------------------------------------------------------------------------------
pub const sqlite3 = anyopaque;
pub const sqlite3_stmt = anyopaque;
//--------------------------------------------------------------------------------
pub extern fn sqlite3_bind_blob(stmt_handle: ?*anyopaque, iCol: c_int, ptr: [*c]const u8, len: usize, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) callconv(.c) c_int;
pub extern fn sqlite3_bind_double(stmt_handle: ?*anyopaque, iCol: c_int, float: f64) callconv(.c) c_int;
pub extern fn sqlite3_bind_int64(stmt_handle: ?*anyopaque, iCol: c_int, integer: i64) callconv(.c) c_int;
pub extern fn sqlite3_bind_null(stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) c_int;
pub extern fn sqlite3_bind_text(stmt_handle: ?*anyopaque, iCol: c_int, ptr: [*c]const u8, len: usize, destructor_function: ?*const fn (?*anyopaque) callconv(.c) void) callconv(.c) c_int;
pub extern fn sqlite3_clear_bindings(stmt_handle: ?*anyopaque) callconv(.c) c_int;
pub extern fn sqlite3_close(db_handle: ?*anyopaque) callconv(.c) c_int;
pub extern fn sqlite3_column_blob(stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) [*c]const u8;
pub extern fn sqlite3_column_bytes(stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) c_int;
pub extern fn sqlite3_column_count(stmt_handle: ?*anyopaque) callconv(.c) c_int;
pub extern fn sqlite3_column_double(stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) f64;
pub extern fn sqlite3_column_int64(stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) i64;
pub extern fn sqlite3_column_name(stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) [*c]const u8;
pub extern fn sqlite3_column_text(stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) [*c]const u8;
pub extern fn sqlite3_column_type(stmt_handle: ?*anyopaque, iCol: c_int) callconv(.c) c_int;
pub extern fn sqlite3_data_count(stmt_handle: ?*anyopaque) callconv(.c) c_int;
pub extern fn sqlite3_errmsg(db_handle: ?*anyopaque) callconv(.c) [*c]const u8;
pub extern fn sqlite3_exec(db_handle: ?*anyopaque, sql: [*c]const u8, callback: ?*const fn (ctx: ?*anyopaque, argc: i32, argv: [*c][*c]u8, azColName: [*c][*c]u8) callconv(.c) c_int, ctx: ?*anyopaque, errmsg: [*c][*c]u8) callconv(.c) c_int;
pub extern fn sqlite3_finalize(stmt_handle: ?*anyopaque) callconv(.c) c_int;
pub extern fn sqlite3_free(ptr: ?*anyopaque) callconv(.c) void;
pub extern fn sqlite3_free_table(results: [*c][*c]u8) callconv(.c) void;
pub extern fn sqlite3_get_table(db_handle: ?*anyopaque, sql: [*c]const u8, results: [*c][*c][*c]u8, row_count: [*c]c_int, column_count: [*c]c_int, errmsg: [*c][*c]u8) callconv(.c) c_int;
pub extern fn sqlite3_malloc64(len: c_ulonglong) callconv(.c) ?*anyopaque;
pub extern fn sqlite3_mprintf([*c]const u8, ...) callconv(.c) [*c]u8;
pub extern fn sqlite3_open(filepath: [*:0]const u8, db_handle: *?*anyopaque) callconv(.c) c_int;
pub extern fn sqlite3_prepare_v2(db_handle: ?*anyopaque, sql: [*c]const u8, nByte: c_int, ppStmt: *?*anyopaque, pzTail: [*c][*c]const u8) callconv(.c) c_int;
pub extern fn sqlite3_realloc64(ptr: ?*anyopaque, len: c_ulonglong) callconv(.c) ?*anyopaque;
pub extern fn sqlite3_reset(stmt_handle: ?*anyopaque) callconv(.c) c_int;
pub extern fn sqlite3_snprintf(c_int, [*c]u8, [*c]const u8, ...) callconv(.c) [*c]u8;
pub extern fn sqlite3_step(stmt_handle: ?*anyopaque) callconv(.c) c_int;
//--------------------------------------------------------------------------------
//################################################################################
//--------------------------------------------------------------------------------
