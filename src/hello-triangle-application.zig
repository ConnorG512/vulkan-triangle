const std = @import("std");
const assert = std.debug.assert;

const glfw = @cImport(@cInclude("GLFW/glfw3.h"));
const vk = @cImport(@cInclude("vulkan/vulkan.h"));

pub const HelloTriangleApplication = struct {
    window: ?*glfw.GLFWwindow = null,
    instance: vk.VkInstance, 

    pub fn run(self: *HelloTriangleApplication) !void {
        self.initWindow();
        initVulkan();
        self.mainLoop();
        self.cleanup();
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
    fn initVulkan() void {
        createInstance();
    }
    fn mainLoop(self: *HelloTriangleApplication) void {
        assert(self.window != null);
        while (glfw.glfwWindowShouldClose(self.window) == 0) {
            glfw.glfwPollEvents();
        }
    }
    fn cleanup(self: *HelloTriangleApplication) void {
        glfw.glfwDestroyWindow(self.window);
        glfw.glfwTerminate();
    }
    fn createInstance(self: *HelloTriangleApplication) void {
        const appinfo = vk.VkApplicationInfo {
            .sType = vk.VK_STRUCTURE_TYPE_APPLICATION_INFO,
            .pApplicationName = "Vulkan Triangle",
            .applicationVersion = vk.VK_MAKE_VERSION(1, 0, 0),
            .pEngineName = "No Engine",
            .engineVersion = vk.VK_MAKE_VERSION(1, 0, 0),
            .apiVersion = vk.VK_API_VERSION_1_0,
        };

        const glfw_extension_count: c_int = 0;
        const glfw_extentions: [*c]u8 = undefined;
        glfw_extentions = glfw.glfwGetRequiredInstanceExtensions(&glfw_extension_count);

        const createInfo = vk.VkInstanceCreateInfo {
            .sType = vk.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
            .pApplicationInfo = &appinfo,
            .enabledExtensionCount = glfw_extension_count,
            .ppEnabledExtensionNames = glfw_extentions,
            .enabledLayerCount = 0,
        };
        vk.vkCreateInstance(&createInfo, null, self.instance);
    }
};
