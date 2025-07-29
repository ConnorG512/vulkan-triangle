const vk = @cImport(@cInclude("vulkan/vulkan.h"));

const app = @import("hello-triangle-application.zig").HelloTriangleApplication;
const std = @import("std");
const log = std.log;

pub fn main() !void {
    var instance = app {};

    try instance.run();
}
