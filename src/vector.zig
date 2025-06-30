const std = @import("std");

pub const identity_matrix = @Vector(9, f32){
    1, 0, 0,
    0, 1, 0,
    0, 0, 1,
};

/// turns a scalar into a 3x3 scaling matrix of the same
pub fn getScaleMatrix(scalar: f32) @Vector(9, f32) {
    return @Vector(9, f32){
        scalar, 0,      0,
        0,      scalar, 0,
        0,      0,      scalar,
    };
}

/// evaluate [T]v
pub fn transformVector(t: @Vector(9, f32), v: @Vector(3, f32)) @Vector(3, f32) {
    const row1 = @Vector(3, f32){ t[0], t[1], t[2] };
    const row2 = @Vector(3, f32){ t[3], t[4], t[5] };
    const row3 = @Vector(3, f32){ t[6], t[7], t[8] };
    return @Vector(3, f32){
        (row1[0] * v[0]) + (row1[1] * v[1]) + (row1[2] * v[2]),
        (row2[0] * v[0]) + (row2[1] * v[1]) + (row2[2] * v[2]),
        (row3[0] * v[0]) + (row3[1] * v[1]) + (row3[2] * v[2]),
    };
}

test "vector scaling" {
    const v = @Vector(3, f32){ 1, 2, 3 };
    const s = getScaleMatrix(5);
    const cmp = @Vector(3, f32){ 5, 10, 15 };

    try std.testing.expectEqual(cmp, transformVector(s, v));
}
