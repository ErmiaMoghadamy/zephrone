const gl = @import("zopengl").bindings;
const InstanceBuffer = @import("./buffer.zig").InstanceBuffer;

pub const RenderContext = struct {
    current_shader_id: u32 = 0, // TODO: make this bastard work
    instance_buffer: InstanceBuffer,
    const MAX_INSTANCES = 100000;


    pub fn init() RenderContext {
        return RenderContext{
            .instance_buffer = RenderContext.new_instanceBuffer()
        };
    }

    pub fn new_instanceBuffer() InstanceBuffer {
        var rb = InstanceBuffer.init();
        rb.bind();

        const max_instances = MAX_INSTANCES;
        gl.bufferData(gl.ARRAY_BUFFER, @sizeOf([16]f32) * max_instances, null, gl.DYNAMIC_DRAW);

        return rb;
    }

    pub fn deinit(self: *RenderContext) void {
        _ = self;
    }
};
