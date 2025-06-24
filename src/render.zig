const std = @import("std");
const builtin = @import("builtin");
const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
});
const gl = @cImport({
    @cInclude("GL/gl.h");
});
const glu = @cImport({
    @cInclude("GL/glu.h");
});

pub const Renderer = struct {
    /// core variables
    window_title: [*:0]const u8,
    window_width: i32,
    window_height: i32,
    is_running: bool,

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
        const aspect_ratio = (@as(f32, @floatFromInt(self.window_width)) / @as(f32, @floatFromInt(self.window_height)));
        gl.glViewport(0, 0, self.window_width, self.window_height);
        gl.glEnable(gl.GL_DEPTH_TEST);
        gl.glMatrixMode(gl.GL_PROJECTION);
        gl.glLoadIdentity();
        glu.gluPerspective(60.0, aspect_ratio, 1.0, 100.0);
        gl.glMatrixMode(gl.GL_MODELVIEW);
        glu.gluLookAt( //
            0.0, 0.0, 5.0, // eye pos
            0.0, 0.0, 0.0, // look at pos
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

    /// Renders the frame
    pub fn renderFrame(self: *Renderer) void {
        gl.glClear(gl.GL_COLOR_BUFFER_BIT | gl.GL_DEPTH_BUFFER_BIT);

        // Draw a colored triangle
        gl.glBegin(gl.GL_TRIANGLES);
        gl.glColor3f(1.0, 0.0, 0.0);
        gl.glVertex3f(-1.0, -1.0, 0.0);
        gl.glColor3f(0.0, 1.0, 0.0);
        gl.glVertex3f(1.0, -1.0, 0.0);
        gl.glColor3f(0.0, 0.0, 1.0);
        gl.glVertex3f(0.0, 1.0, 0.0);
        gl.glEnd();

        if (sdl.SDL_GL_SwapWindow(self.window) == false) {
            logErrorAndQuit("failed to swap buffer!");
        }
    }

    /// Automatically handles error logging
    fn logErrorAndQuit(msg: []const u8) void {
        std.log.err("SDL error: {s}\nError code: \"{s}\"", .{ msg, sdl.SDL_GetError() });
        sdl.SDL_Quit();
    }
};
