pub const RenderContext = struct {
    current_shader_id: u32 = 0,

    pub fn init() RenderContext {
        return RenderContext{};
    }

    pub fn deinit(self: *RenderContext) void {
        _ = self;
    }
};
