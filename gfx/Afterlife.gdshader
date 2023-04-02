shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform bool is_active = false;
void fragment() {
	vec4 color = texture(screen_texture, SCREEN_UV);
	if(is_active) {
		color.rgb = vec3(1.0-color.r, 1.0-color.g, 1.0-color.b);
	}
	COLOR.rgb = color.rgb;
}
