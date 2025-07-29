const std = @import("std");
const assert = std.debug.assert;

const glfw = @cImport(@cInclude("GLFW/glfw3.h"));

pub const HelloTriangleApplication = struct {
    window: ?*glfw.GLFWwindow = null,

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
       self.window = glfw.glfwCreateWindow(width, height, "Vulkan", null, null);
    } 
    fn initVulkan() void {
        //TODO
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
};
