const std = @import("std");
const Renderer = @import("render.zig").Renderer;

pub fn main() void {
    var renderer = Renderer.init("Quaternion", 720, 480);
    defer renderer.deinit();

    while (renderer.is_running) {
        renderer.handleEvents();
        renderer.renderFrame();
    }
}
