const std = @import("std");

/// returns the 3x3 identity matrix where:
/// f() = | 1, 0, 0 |
///       | 0, 1, 0 |
///       | 0, 0, 1 |
pub fn identityMatrix() @Vector(9, f32) {
    return .{
        1, 0, 0,
        0, 1, 0,
        0, 0, 1,
    };
}

/// returns the 3x3 scaling matrix where:
/// f(a,b,c) = | a, 0, 0 |
///            | 0, b, 0 |
///            | 0, 0, c |
pub fn scaleMatrix(v: @Vector(3, f32)) @Vector(9, f32) {
    return .{
        v[0], 0,    0,
        0,    v[1], 0,
        0,    0,    v[2],
    };
}

/// evaluate [T]v
pub fn transformVector(t: @Vector(9, f32), v: @Vector(3, f32)) @Vector(3, f32) {
    return .{
        (t[0] * v[0]) + (t[1] * v[1]) + (t[2] * v[2]),
        (t[3] * v[0]) + (t[4] * v[1]) + (t[5] * v[2]),
        (t[6] * v[0]) + (t[7] * v[1]) + (t[8] * v[2]),
    };
}

test "vector scaling" {
    const v = @Vector(3, f32){ 1, 2, 3 };
    const s = scaleMatrix(.{ 5, 3, 5 });
    try std.testing.expectEqual(.{ 5, 6, 15 }, transformVector(s, v));
}
