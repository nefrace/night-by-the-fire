shader_type spatial;

uniform sampler2D DitherMap : filter_nearest;
uniform float DitherStrength = 1.1;
uniform float ColorDepth = 5.0;

void fragment() {
	ALBEDO.rgb = vec3(0.19, 0.17, 0.26).rgb;
}

void light() {
	float light = max(0.0, dot(NORMAL, LIGHT)) * ATTENUATION;
	vec2 ts = vec2(textureSize(DitherMap, 0)) * 3.0;
	vec2 uv = mod(floor(FRAGCOORD.xy), ts) / ts;
	light += (texture(DitherMap, uv).r - 0.5) * DitherStrength;
	light = round(light * ColorDepth) / ColorDepth;
	DIFFUSE_LIGHT += light * ALBEDO * LIGHT_COLOR;
}