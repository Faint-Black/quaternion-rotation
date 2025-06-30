const std = @import("std");
const Renderer = @import("render.zig").Renderer;
const cube_vert_base = @import("render.zig").cube_vertices_base;
const vec = @import("vector.zig");

pub fn main() void {
    var renderer = Renderer.init("Quaternion", 720, 480);
    defer renderer.deinit();

    var cube_vertices: [24]@Vector(3, f32) = undefined;
    std.mem.copyForwards(@Vector(3, f32), &cube_vertices, &cube_vert_base);

    // transform vertices here
    for (&cube_vertices) |*v| {
        const transform = @Vector(9, f32){
            1, 1, 0,
            0, 1, 0,
            0, 0, 1,
        };
        v.* = vec.transformVector(transform, v.*);
    }

    while (renderer.is_running) {
        renderer.handleEvents();
        renderer.renderFrame(cube_vertices);
    }
}
