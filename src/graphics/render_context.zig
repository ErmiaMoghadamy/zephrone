const zm = @import("zmath");
const utils = @import("../utils.zig");
const Camera = @import("../camera.zig").Camera;
const Shader = @import("shader.zig").Shader;

pub const RenderContext = struct {
    view: [16]f32,
    projection: [16]f32,

    pub fn fromCamera(camera: *const Camera) RenderContext {
        return .{
            .view = utils.mat2arr(camera.view),
            .projection = utils.mat2arr(camera.projection),
        };
    }

    pub fn applyTransform(self: RenderContext, shader: *Shader, model: zm.Mat) void {
        shader.setu_mat("uModel", utils.mat2arr(model));
        shader.setu_mat("uView", self.view);
        shader.setu_mat("uProjection", self.projection);
    }
};
