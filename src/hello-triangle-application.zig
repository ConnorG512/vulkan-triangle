const std = @import("std");
const assert = std.debug.assert;
const log = std.log;

const vkParseResult = @import("vulkan-result-parse.zig").VkResultParse.parseResult;

const glfw = @cImport(@cInclude("GLFW/glfw3.h"));
const vk = @cImport(@cInclude("vulkan/vulkan.h"));

const validation_layers = [_][*c]const u8 {
    "VK_LAYER_KHRONOS_validation",
};

const VulkanError = error {
    no_validation_layers,
    could_not_create_instance,
};

const Allocation_Error = error {
    failed_to_allocate_layer,
};

var enable_validation_layers: bool = true;
fn enableValidationMode() void {
    if (std.builtin.OptimizeMode == .Debug) {
        return;
    }
    enable_validation_layers = false;
}

pub const HelloTriangleApplication = struct {
    window: ?*glfw.GLFWwindow = null,
    instance: vk.VkInstance = undefined, 
    arena_alloc: *std.heap.ArenaAllocator,

    pub fn run(self: *HelloTriangleApplication) !void {
        defer self.cleanup();

        self.initWindow();
        self.initVulkan() catch |err| {
            switch (err) {
                error.could_not_create_instance => {
                    log.err("Vulkan Error: {}", .{err});
                    return error.could_not_create_instance;
                },
                error.no_validation_layers => {
                    log.debug("Vulkan Warning: No validation layers", .{});
                },
                error.OutOfMemory => {
                    log.err("Out of memory error!", .{});
                    return error.OutOfMemory;
                }
            }
        };
        self.mainLoop();
    }
    fn initWindow(self: *HelloTriangleApplication) void {
       _ = glfw.glfwInit();
       glfw.glfwWindowHint(glfw.GLFW_CLIENT_API, glfw.GLFW_NO_API);
       glfw.glfwWindowHint(glfw.GLFW_RESIZABLE, glfw.GLFW_FALSE);

       const width: c_int = comptime 800;
       const height: c_int = comptime 600;
       self.window = glfw.glfwCreateWindow(width, height, "Vulkan Triangle", null, null);
       const error_code: c_int = glfw.glfwGetError(null);
       if (error_code != 0) {
           log.err("GLFW ERROR: {d}", .{error_code});
       }
    } 
    fn initVulkan(self: *HelloTriangleApplication) !void {
        try self.createInstance();
    }
    fn mainLoop(self: *HelloTriangleApplication) void {
        assert(self.window != null);
        while (glfw.glfwWindowShouldClose(self.window) == 0) {
            glfw.glfwPollEvents();
        }
    }
    fn cleanup(self: *HelloTriangleApplication) void {
        vk.vkDestroyInstance(self.instance, null);
        glfw.glfwDestroyWindow(self.window);
        glfw.glfwTerminate();
    }
    fn createInstance(self: *HelloTriangleApplication) !void {
        if (enable_validation_layers and !try self.checkValidationLayerSupport()) {
            return error.no_validation_layers;
        }

        const appinfo = vk.VkApplicationInfo {
            .sType = vk.VK_STRUCTURE_TYPE_APPLICATION_INFO,
            .pApplicationName = "Vulkan Triangle",
            .applicationVersion = vk.VK_MAKE_VERSION(1, 0, 0),
            .pEngineName = "No Engine",
            .engineVersion = vk.VK_MAKE_VERSION(1, 0, 0),
            .apiVersion = vk.VK_API_VERSION_1_0,
        };

        var glfw_extension_count: u32 = 0;
        var glfw_extentions: [*c][*c]const u8 = undefined;
        glfw_extentions = glfw.glfwGetRequiredInstanceExtensions(&glfw_extension_count);

        var extension_count: u32 = 0;
        const extension_count_result: vk.VkResult = vk.vkEnumerateInstanceExtensionProperties(null, &extension_count, null);
        if (extension_count_result != vk.VK_SUCCESS) {
            log.err("Cannot get instance extension properties! {s}", .{vkParseResult(extension_count_result)});
        }
        log.debug("Extention Count: {d}", .{extension_count});

        var extension_properties: [64]vk.VkExtensionProperties = undefined;
        const extension_properties_result = vk.vkEnumerateInstanceExtensionProperties(null, &extension_count, &extension_properties);
        if (extension_properties_result != vk.VK_SUCCESS) {
            log.err("Cannot get instance extension properties! {s}", .{vkParseResult(extension_properties_result)});
        }

        var createInfo = vk.VkInstanceCreateInfo {
            .sType = vk.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
            .pApplicationInfo = &appinfo,
            .enabledExtensionCount = glfw_extension_count,
            .ppEnabledExtensionNames = glfw_extentions,
        };
        if (enable_validation_layers) {
            createInfo.enabledLayerCount = @intCast(validation_layers.len);
            createInfo.ppEnabledLayerNames = &validation_layers;
        } else {
            createInfo.enabledLayerCount = 0;
        }

        const create_instance_result: vk.VkResult = vk.vkCreateInstance(&createInfo, null, &self.instance); 
        if(create_instance_result != vk.VK_SUCCESS) {
            log.err("Could not create Vulkan instance! {s}", .{vkParseResult(create_instance_result)});
            return error.could_not_create_instance;
        }
    }
    fn checkValidationLayerSupport(self: *HelloTriangleApplication) !bool {
        var layer_count: u32 = 0;
        {
            const result: vk.VkResult = vk.vkEnumerateInstanceLayerProperties(&layer_count, null); 
            if (result != vk.VK_SUCCESS) {
                log.err("Could not Enumerate Instance! {s}", .{vkParseResult(result)});
                return false;
            }
        }
        assert(layer_count != 0);
        log.debug("Layer Count: {d}", .{layer_count});
        
        const available_layers = try self.arena_alloc.allocator().alloc(vk.VkLayerProperties, layer_count); 
        const result: vk.VkResult = vk.vkEnumerateInstanceLayerProperties(&layer_count, available_layers.ptr); 
        if (result != vk.VK_SUCCESS) {
            log.err("Could not Enumerate Instance! {s}", .{vkParseResult(result)});
            return false;
        }
        
        for (validation_layers) |current_layer| {
            var layer_found: bool = false;
            
            for (available_layers) |layer_properties| {
                if (std.mem.eql(u8, std.mem.sliceTo(current_layer, 0), std.mem.sliceTo(&layer_properties.layerName, 0))) {
                    layer_found = true;
                    break;
                }
            }

            if (!layer_found) {
                log.debug("No Vulkan validation layers found", .{});
                return false;
            }
        }

        return true;
    }
    fn getRequiredExtensions() void {
        // PARTIAL
        var glfw_extension_count: u32 = 0;
        var glfw_extentions: [*][*:0]const u8 = undefined;
        glfw_extentions = glfw.glfwGetRequiredInstanceExtensions(&glfw_extension_count);

        std.ArrayList([:0]const u8);

        if (enable_validation_layers) {

        }

        return;
    } 
};

test "comparing a c style array of strings to slice" {
    // Array of C style strings 
    // :0 denotes null terminated string
    const strings = [_][:0]const u8 {
        "One",
        "Two",
        "Three",
    };
    // Convert all bytes to a slice not including the null terminator and comparing it to the original value
    try std.testing.expect(std.mem.eql(u8, std.mem.sliceTo(strings[0].ptr, 0), "One"));
    try std.testing.expect(std.mem.eql(u8, std.mem.sliceTo(strings[1].ptr, 0), "Two"));
    try std.testing.expect(std.mem.eql(u8, std.mem.sliceTo(strings[2].ptr, 0), "Three"));
}

