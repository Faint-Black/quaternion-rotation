const std = @import("std");
const Renderer = @import("render.zig").Renderer;
const vec = @import("vector.zig");

pub fn main() void {
    var renderer = Renderer.init("Quaternion rotation demo", 720, 480);
    defer renderer.deinit();

    // init vertices with cube base
    const base = @import("render.zig").center_cube_vertices_base;
    var cube_vertices: [24]@Vector(3, f32) = undefined;
    std.mem.copyForwards(@Vector(3, f32), &cube_vertices, &base);

    // transform vertices here
    const transform = @Vector(9, f32){
        1, 1, 1,
        0, 1, 0,
        0, 0, 1,
    };
    for (&cube_vertices) |*v| {
        v.* = vec.transformVector(transform, v.*);
    }

    // render the cube
    while (renderer.is_running) {
        renderer.handleEvents();
        renderer.renderFrame(cube_vertices);
    }
}
