const vk = @cImport(@cInclude("vulkan/vulkan.h"));

pub const VkResultParse = struct {
    pub fn parseResult(error_code: vk.VkResult) []const u8 {
        switch (error_code) {
            vk.VK_SUCCESS => {
                return "VK_SUCCESS";
            },
            vk.VK_NOT_READY => {
                return "VK_NOT_READY";
            },
            vk.VK_TIMEOUT => {
                return "VK_TIMEOUT";
            },
            vk.VK_EVENT_SET => {
                return "VK_EVENT_SET";
            },
            vk.VK_EVENT_RESET => {
                return "VK_EVENT_RESET";
            },
            vk.VK_INCOMPLETE => {
                return "VK_INCOMPLETE";
            },
            vk.VK_ERROR_OUT_OF_DEVICE_MEMORY => {
                return "VK_ERROR_OUT_OF_DEVICE_MEMORY";
            },
            vk.VK_ERROR_OUT_OF_HOST_MEMORY => {
                return "VK_ERROR_OUT_OF_HOST_MEMORY";
            },
            vk.VK_ERROR_VALIDATION_FAILED_EXT => {
                return "VK_ERROR_VALIDATION_FAILED_EXT";
            },
            vk.VK_ERROR_EXTENSION_NOT_PRESENT => {
                return "VK_ERROR_EXTENSION_NOT_PRESENT";
            },
            vk.VK_ERROR_INCOMPATIBLE_DRIVER => {
                return "VK_ERROR_INCOMPATIBLE_DRIVER";
            },
            vk.VK_ERROR_INITIALIZATION_FAILED => {
                return "VK_ERROR_INITIALIZATION_FAILED";
            },
            vk.VK_ERROR_LAYER_NOT_PRESENT => {
                return "VK_ERROR_LAYER_NOT_PRESENT";
            },
            else => {
                return "NO_KNOWN_ERROR";
            },
        }
    }
};
