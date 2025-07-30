const std = @import("std");
const assert = std.debug.assert;
const log = std.log;

const glfw = @cImport(@cInclude("GLFW/glfw3.h"));
const vk = @cImport(@cInclude("vulkan/vulkan.h"));

const validation_layers = [_][]const u8 {
    "VK_LAYER_KHRONOS_validation",
};

const VulkanError = error {
    no_validation_layers,
    error1,
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

    pub fn run(self: *HelloTriangleApplication) !void {
        defer self.cleanup();

        self.initWindow();
        self.initVulkan() catch |err| {
            std.log.err("Vulkan Error: {}\n", .{err});
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
           std.log.err("GLFW ERROR: {d}\n", .{error_code});
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
    fn createInstance(self: *HelloTriangleApplication) VulkanError!void {
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
        if (vk.vkEnumerateInstanceExtensionProperties(null, &extension_count, null) != vk.VK_SUCCESS) {
            log.err("Cannot get instance extension properties!\n", .{});
        }
        log.debug("Extention Count: {d}", .{extension_count});
        var extension_properties: [64]vk.VkExtensionProperties = undefined;
        if (vk.vkEnumerateInstanceExtensionProperties(null, &extension_count, &extension_properties) != vk.VK_SUCCESS) {
            log.err("Cannot get instance extension properties!\n", .{});
        }

        const createInfo = vk.VkInstanceCreateInfo {
            .sType = vk.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
            .pApplicationInfo = &appinfo,
            .enabledExtensionCount = glfw_extension_count,
            .ppEnabledExtensionNames = glfw_extentions,
            .enabledLayerCount = 0,
        };
        if(vk.vkCreateInstance(&createInfo, null, &self.instance) != vk.VK_SUCCESS) {
            log.err("Could not create Vulkan instance!\n", .{});
        }
        if (enable_validation_layers and !checkValidationLayerSupport()) {
            return error.no_validation_layers;
        }
    }
    fn checkValidationLayerSupport() bool {
        var layer_count: u32 = 0;
        var available_layers: [64]vk.VkLayerProperties = undefined;
        _ = vk.vkEnumerateInstanceLayerProperties(&layer_count, &available_layers);
        
        var layer_found: bool = false;
        for (available_layers) |current_layer| {

            if (std.mem.eql(u8, &current_layer.layerName, "VK_LAYER_KHRONOS_validation")) {
                layer_found = true;
                log.debug("Validation layer found!\n", .{});
                break;
            }
        }

        if (!layer_found) {
            return false;
        }

        return true;
    }
};
