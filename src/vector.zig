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
    // Zig SIMD floating point reduction and multiplication not implemented yet
    return .{
        (t[0] * v[0]) + (t[1] * v[1]) + (t[2] * v[2]),
        (t[3] * v[0]) + (t[4] * v[1]) + (t[5] * v[2]),
        (t[6] * v[0]) + (t[7] * v[1]) + (t[8] * v[2]),
    };
}

/// evaluate determinant of 3x3 matrix
pub fn determinant(m: @Vector(9, f32)) f32 {
    const t1 = m[0] * m[4] * m[8];
    const t2 = m[1] * m[5] * m[6];
    const t3 = m[2] * m[3] * m[7];
    const t4 = m[1] * m[3] * m[8];
    const t5 = m[0] * m[5] * m[7];
    const t6 = m[2] * m[4] * m[6];
    return (t1 + t2 + t3 - t4 - t5 - t6);
}

/// evaluate transpose of 3x3 matrix
pub fn transpose(m: @Vector(9, f32)) @Vector(9, f32) {
    return .{
        m[0], m[3], m[6],
        m[1], m[4], m[7],
        m[2], m[5], m[8],
    };
}

test "vector scaling" {
    const v = @Vector(3, f32){ 1, 2, 3 };
    const s = scaleMatrix(.{ 5, 3, 5 });

    try std.testing.expectEqual(.{ 5, 6, 15 }, transformVector(s, v));
}

test "matrix operations" {
    const matrices = [3]@Vector(9, f32){
        .{
            1, 2, 3,
            0, 1, 4,
            5, 6, 0,
        },
        .{
            2, 0, 0,
            0, 3, 0,
            0, 0, 4,
        },
        .{
            1, 2, 1,
            0, 1, 0,
            2, 3, 4,
        },
    };

    // det(A)
    for (matrices, [_]f32{ 1.0, 24.0, 2.0 }) |mat, det| {
        try std.testing.expectEqual(det, determinant(mat));
    }

    // A^T
    for (matrices, [_]@Vector(9, f32){
        .{ 1, 0, 5, 2, 1, 6, 3, 4, 0 },
        .{ 2, 0, 0, 0, 3, 0, 0, 0, 4 },
        .{ 1, 0, 2, 2, 1, 3, 1, 0, 4 },
    }) |mat, transp| {
        try std.testing.expectEqual(transp, transpose(mat));
    }
}
