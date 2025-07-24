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
pub fn determinant3(m: @Vector(9, f32)) f32 {
    const t1 = m[0] * m[4] * m[8];
    const t2 = m[1] * m[5] * m[6];
    const t3 = m[2] * m[3] * m[7];
    const t4 = m[1] * m[3] * m[8];
    const t5 = m[0] * m[5] * m[7];
    const t6 = m[2] * m[4] * m[6];
    return (t1 + t2 + t3 - t4 - t5 - t6);
}

/// evaluate determinant of 2x2 matrix
pub fn determinant2(m: @Vector(4, f32)) f32 {
    return ((m[0] * m[3]) - (m[1] * m[2]));
}

/// evaluate transpose of 3x3 matrix
pub fn transpose(m: @Vector(9, f32)) @Vector(9, f32) {
    return .{
        m[0], m[3], m[6],
        m[1], m[4], m[7],
        m[2], m[5], m[8],
    };
}

pub fn adjoint(m: @Vector(9, f32)) @Vector(9, f32) {
    const minors = [9]@Vector(4, f32){
        .{ m[4], m[5], m[7], m[8] },
        .{ m[3], m[5], m[6], m[8] },
        .{ m[3], m[4], m[6], m[7] },
        .{ m[1], m[2], m[7], m[8] },
        .{ m[0], m[2], m[6], m[8] },
        .{ m[0], m[1], m[6], m[7] },
        .{ m[1], m[2], m[4], m[5] },
        .{ m[0], m[2], m[3], m[5] },
        .{ m[0], m[1], m[3], m[4] },
    };
    var cofactors: @Vector(9, f32) = undefined;
    for (0..9) |i| {
        cofactors[i] = determinant2(minors[i]);
        if (i % 2 == 1) cofactors[i] *= -1;
    }
    return transpose(cofactors);
}

pub fn invert(m: @Vector(9, f32)) @Vector(9, f32) {
    const one_over_det = 1.0 / determinant3(m);
    return @as(@Vector(9, f32), @splat(one_over_det)) * adjoint(m);
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
    for (matrices, [_]f32{
        1.0,
        24.0,
        2.0,
    }) |mat, det| {
        try std.testing.expectEqual(det, determinant3(mat));
    }

    // adj(A)
    for (matrices, [_]@Vector(9, f32){
        .{ -24, 18, 5, 20, -15, -4, -5, 4, 1 },
        .{ 12, 0, 0, 0, 8, 0, 0, 0, 6 },
        .{ 4, -5, -1, 0, 2, 0, -2, 1, 1 },
    }) |mat, adj| {
        try std.testing.expectEqual(adj, adjoint(mat));
    }

    // A^T
    for (matrices, [_]@Vector(9, f32){
        .{ 1, 0, 5, 2, 1, 6, 3, 4, 0 },
        .{ 2, 0, 0, 0, 3, 0, 0, 0, 4 },
        .{ 1, 0, 2, 2, 1, 3, 1, 0, 4 },
    }) |mat, transp| {
        try std.testing.expectEqual(transp, transpose(mat));
    }

    // A^-1
    for (matrices, [_]@Vector(9, f32){
        .{ -24, 18, 5, 20, -15, -4, -5, 4, 1 },
        .{ (1.0 / 2.0), 0, 0, 0, (1.0 / 3.0), 0, 0, 0, (1.0 / 4.0) },
        .{ 2, -(5.0 / 2.0), -(1.0 / 2.0), 0, 1, 0, -1, (1.0 / 2.0), (1.0 / 2.0) },
    }) |mat, inv| {
        try std.testing.expectEqual(inv, invert(mat));
    }
}
