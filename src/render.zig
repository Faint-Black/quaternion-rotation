const std = @import("std");
const builtin = @import("builtin");
const vec = @import("vector.zig");

const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
});
const gl = @cImport({
    @cInclude("GL/gl.h");
});
const glu = @cImport({
    @cInclude("GL/glu.h");
});

pub const cube_vertices_base = [24]@Vector(3, f32){
    @Vector(3, f32){ 1.0, 1.0, 1.0 },
    @Vector(3, f32){ -1.0, 1.0, 1.0 },
    @Vector(3, f32){ -1.0, 1.0, -1.0 },
    @Vector(3, f32){ 1.0, 1.0, -1.0 },
    @Vector(3, f32){ 1.0, -1.0, 1.0 },
    @Vector(3, f32){ -1.0, -1.0, 1.0 },
    @Vector(3, f32){ -1.0, -1.0, -1.0 },
    @Vector(3, f32){ 1.0, -1.0, -1.0 },
    @Vector(3, f32){ 1.0, 1.0, 1.0 },
    @Vector(3, f32){ 1.0, -1.0, 1.0 },
    @Vector(3, f32){ 1.0, -1.0, -1.0 },
    @Vector(3, f32){ 1.0, 1.0, -1.0 },
    @Vector(3, f32){ -1.0, 1.0, 1.0 },
    @Vector(3, f32){ -1.0, -1.0, 1.0 },
    @Vector(3, f32){ -1.0, -1.0, -1.0 },
    @Vector(3, f32){ -1.0, 1.0, -1.0 },
    @Vector(3, f32){ 1.0, 1.0, 1.0 },
    @Vector(3, f32){ -1.0, 1.0, 1.0 },
    @Vector(3, f32){ -1.0, -1.0, 1.0 },
    @Vector(3, f32){ 1.0, -1.0, 1.0 },
    @Vector(3, f32){ 1.0, 1.0, -1.0 },
    @Vector(3, f32){ -1.0, 1.0, -1.0 },
    @Vector(3, f32){ -1.0, -1.0, -1.0 },
    @Vector(3, f32){ 1.0, -1.0, -1.0 },
};

pub const Renderer = struct {
    /// core variables
    window_title: [*:0]const u8,
    window_width: i32,
    window_height: i32,
    is_running: bool,
    frame_counter: usize,

    /// internal SDL and OpenGL variables
    window: ?*sdl.SDL_Window = null,
    context: sdl.SDL_GLContext = undefined,

    /// Initialize SDL3 and struct variables
    pub fn init(title: [*:0]const u8, width: i32, height: i32) Renderer {
        var result = Renderer{
            .window_title = title,
            .window_width = width,
            .window_height = height,
            .is_running = true,
            .frame_counter = 0,
        };
        result.initSDL();
        result.initGL();
        return result;
    }

    /// SDL3 initialization boilerplate
    fn initSDL(self: *Renderer) void {
        const window_flags = (sdl.SDL_WINDOW_RESIZABLE | sdl.SDL_WINDOW_OPENGL);
        const title = self.window_title;
        const width = self.window_width;
        const height = self.window_height;
        if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) == false)
            logErrorAndQuit("failed to init SDL3!");
        self.window = sdl.SDL_CreateWindow(title, width, height, window_flags);
        if (self.window == null)
            logErrorAndQuit("failed to create window!");
        self.context = sdl.SDL_GL_CreateContext(self.window);
        if (self.context == null)
            logErrorAndQuit("failed to create OpenGL context!");
        if (sdl.SDL_GL_SetSwapInterval(1) == false)
            logErrorAndQuit("failed to set swap interval!");
    }

    /// OpenGL initialization boilerplate
    fn initGL(self: *Renderer) void {
        // rendering settings
        gl.glViewport(0, 0, self.window_width, self.window_height);
        gl.glEnable(gl.GL_DEPTH_TEST);
        gl.glMatrixMode(gl.GL_PROJECTION);
        const aspect_ratio = (@as(f32, @floatFromInt(self.window_width)) / @as(f32, @floatFromInt(self.window_height)));
        glu.gluPerspective(60.0, aspect_ratio, 1.0, 100.0);
        // camera settings
        gl.glMatrixMode(gl.GL_MODELVIEW);
        gl.glLoadIdentity();
        glu.gluLookAt( //
            5.0, 5.0, 5.0, // camera position
            0.0, 0.0, 0.0, // target position
            0.0, 1.0, 0.0 //  up vector
        );
    }

    /// Deinits the struct then kills the program
    pub fn deinit(this: Renderer) void {
        std.debug.print("Gracefully exiting...\n", .{});
        _ = sdl.SDL_GL_DestroyContext(this.context);
        sdl.SDL_DestroyWindow(this.window);
        sdl.SDL_Quit();
    }

    /// Process polled queued events
    pub fn handleEvents(this: *Renderer) void {
        var event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&event)) {
            if (event.type == sdl.SDL_EVENT_QUIT) {
                this.is_running = false;
            }
            if (event.type == sdl.SDL_EVENT_KEY_DOWN) {
                switch (event.key.key) {
                    sdl.SDLK_W => {
                        std.debug.print("UP\n", .{});
                    },
                    sdl.SDLK_S => {
                        std.debug.print("DOWN\n", .{});
                    },
                    else => {},
                }
            }
        }
    }

    /// Renders the frame and input cube vertices
    pub fn renderFrame(self: *Renderer, cube_vertices: [24]@Vector(3, f32)) void {
        gl.glClear(gl.GL_COLOR_BUFFER_BIT | gl.GL_DEPTH_BUFFER_BIT);

        self.updateCamera();
        drawGrid();
        drawAxis();
        drawCube(cube_vertices);

        if (sdl.SDL_GL_SwapWindow(self.window) == false) {
            logErrorAndQuit("failed to swap buffer!");
        }
        self.frame_counter += 1;
    }

    /// updates rotating camera
    fn updateCamera(self: *Renderer) void {
        const deg: f32 = @floatFromInt(@as(usize, self.frame_counter % 360));
        const rad: f32 = std.math.degreesToRadians(deg);
        const distance = 10;
        const camera_x = @sin(rad) * distance;
        const camera_y = @sin(rad) * distance;
        const camera_z = @cos(rad) * distance;
        gl.glMatrixMode(gl.GL_MODELVIEW);
        gl.glLoadIdentity();
        glu.gluLookAt(
            camera_x,
            camera_y,
            camera_z,
            0,
            0,
            0,
            0.0,
            1.0,
            0.0,
        );
    }

    /// draw cube at the center
    fn drawCube(v: [24]@Vector(3, f32)) void {
        const dark = 0x44;
        const light = 0xFF;
        // top face
        gl.glBegin(gl.GL_TRIANGLE_FAN);
        gl.glColor3ub(dark, dark, 0x00);
        gl.glVertex3f(v[0][0], v[0][1], v[0][2]);
        gl.glVertex3f(v[1][0], v[1][1], v[1][2]);
        gl.glColor3ub(light, light, 0x00);
        gl.glVertex3f(v[2][0], v[2][1], v[2][2]);
        gl.glVertex3f(v[3][0], v[3][1], v[3][2]);
        gl.glEnd();
        // bottom face
        gl.glBegin(gl.GL_TRIANGLE_FAN);
        gl.glColor3ub(dark, dark, 0x00);
        gl.glVertex3f(v[4][0], v[4][1], v[4][2]);
        gl.glVertex3f(v[5][0], v[5][1], v[5][2]);
        gl.glVertex3f(v[6][0], v[6][1], v[6][2]);
        gl.glVertex3f(v[7][0], v[7][1], v[7][2]);
        gl.glEnd();
        // north face
        gl.glBegin(gl.GL_TRIANGLE_FAN);
        gl.glColor3ub(dark, 0x00, 0x00);
        gl.glVertex3f(v[8][0], v[8][1], v[8][2]);
        gl.glVertex3f(v[9][0], v[9][1], v[9][2]);
        gl.glColor3ub(light, 0x00, 0x00);
        gl.glVertex3f(v[10][0], v[10][1], v[10][2]);
        gl.glVertex3f(v[11][0], v[11][1], v[11][2]);
        gl.glEnd();
        // south face
        gl.glBegin(gl.GL_TRIANGLE_FAN);
        gl.glColor3ub(dark, 0x00, 0x00);
        gl.glVertex3f(v[12][0], v[12][1], v[12][2]);
        gl.glVertex3f(v[13][0], v[13][1], v[13][2]);
        gl.glColor3ub(light, 0x00, 0x00);
        gl.glVertex3f(v[14][0], v[14][1], v[14][2]);
        gl.glVertex3f(v[15][0], v[15][1], v[15][2]);
        gl.glEnd();
        // east face
        gl.glBegin(gl.GL_TRIANGLE_FAN);
        gl.glColor3ub(0x00, 0x00, dark);
        gl.glVertex3f(v[16][0], v[16][1], v[16][2]);
        gl.glVertex3f(v[17][0], v[17][1], v[17][2]);
        gl.glVertex3f(v[18][0], v[18][1], v[18][2]);
        gl.glVertex3f(v[19][0], v[19][1], v[19][2]);
        gl.glEnd();
        // west face
        gl.glBegin(gl.GL_TRIANGLE_FAN);
        gl.glColor3ub(0x00, 0x00, light);
        gl.glVertex3f(v[20][0], v[20][1], v[20][2]);
        gl.glVertex3f(v[21][0], v[21][1], v[21][2]);
        gl.glVertex3f(v[22][0], v[22][1], v[22][2]);
        gl.glVertex3f(v[23][0], v[23][1], v[23][2]);
        gl.glEnd();
    }

    /// draws axis lines
    fn drawAxis() void {
        gl.glBegin(gl.GL_LINES);
        // yellow Y axis
        gl.glColor3ub(0xFF, 0xFF, 0x00);
        gl.glVertex3d(0.0, 0.0, 0.0);
        gl.glVertex3d(0.0, 40.0, 0.0);
        // red X axis
        gl.glColor3ub(0xFF, 0x00, 0x00);
        gl.glVertex3d(0.0, 0.0, 0.0);
        gl.glVertex3d(40.0, 0.0, 0.0);
        // blue Z axis
        gl.glColor3ub(0x00, 0x00, 0xFF);
        gl.glVertex3d(0.0, 0.0, 0.0);
        gl.glVertex3d(0.0, 0.0, 40.0);
        gl.glEnd();
    }

    /// draws X-Z axis grid lines
    fn drawGrid() void {
        const linecount = 20;
        const spacing = 2;
        const length = (linecount * spacing) / 2;
        var i: i32 = (linecount / 2) * -1;
        gl.glBegin(gl.GL_LINES);
        gl.glColor3ub(0x33, 0x33, 0x33);
        while (i < (linecount / 2)) : (i += 1) {
            // x parallel lines
            gl.glVertex3i(length * -1, 0, i * spacing);
            gl.glVertex3i(length, 0, i * spacing);
            // z parallel lines
            gl.glVertex3i(i * spacing, 0, length * -1);
            gl.glVertex3i(i * spacing, 0, length);
        }
        gl.glEnd();
    }

    /// Automatically handles error logging
    fn logErrorAndQuit(msg: []const u8) void {
        std.log.err("SDL error: {s}\nError code: \"{s}\"", .{ msg, sdl.SDL_GetError() });
        sdl.SDL_Quit();
    }
};
