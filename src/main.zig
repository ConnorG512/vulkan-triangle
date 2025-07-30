const vk = @cImport(@cInclude("vulkan/vulkan.h"));

const app = @import("hello-triangle-application.zig").HelloTriangleApplication;
const std = @import("std");
const log = std.log;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    
    var instance = app {
        .arena_alloc = &arena,
    };
    
    try instance.run();
}
