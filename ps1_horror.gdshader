shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float resolution_scale = 4.0; // The amount of pixelation. Higher = blockier.
uniform float color_depth = 16.0; // Color crunch: e.g. 16/32/64 to crush palette.
uniform float chromatic_amount = 0.005; // Offset for red/blue split.
uniform float scanline_intensity = 0.2;
uniform float noise_intensity = 0.05;
uniform float darkness_factor = 0.85; // Multiplier to dim the atmosphere.

// Bayer matrix function for 4x4 Dithering
float bayer_dither(vec2 _uv) {
	int x = int(mod(_uv.x, 4.0));
	int y = int(mod(_uv.y, 4.0));
	
	const mat4 bayer = mat4(
		vec4( 0.0,  8.0,  2.0, 10.0),
		vec4(12.0,  4.0, 14.0,  6.0),
		vec4( 3.0, 11.0,  1.0,  9.0),
		vec4(15.0,  7.0, 13.0,  5.0)
	);
	
	return bayer[x][y] / 16.0 - 0.5;
}

// Random noise generator for Film Grain
float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
	vec2 base_uv = SCREEN_UV;
	
	// 1. Pixelation (Low Resolution)
	// We snap the UV coordinates to a lower resolution grid.
	vec2 res = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 scaled_res = res / resolution_scale;
	vec2 pixel_uv = floor(base_uv * scaled_res) / scaled_res;
	
	// 2. Chromatic Aberration
	vec2 offset_r = vec2(chromatic_amount, 0.0);
	vec2 offset_b = vec2(-chromatic_amount, 0.0);
	
	float r = texture(screen_texture, pixel_uv + offset_r).r;
	float g = texture(screen_texture, pixel_uv).g;
	float b = texture(screen_texture, pixel_uv + offset_b).b;
	vec3 color = vec3(r, g, b);
	
	// 3. Atmosphere Darkness
	color *= darkness_factor;
	
	// 4. Color Reduction (Banding/Crunching)
	color = floor(color * color_depth) / color_depth;
	
	// 5. Dithering Mechanism (Adds noise to shadows to simulate retro shading)
	float dither = bayer_dither(FRAGCOORD.xy);
	color += dither * (1.0 / color_depth) * 2.0;
	
	// Ensures colors don't exceed boundaries after dithering
	color = clamp(color, 0.0, 1.0);
	
	// 6. Scanlines (CRT TV lines)
	// Darken every alternate pixel row.
	float scanline = sin(base_uv.y * res.y * 3.14159);
	color -= mix(0.0, scanline_intensity, clamp(scanline, 0.0, 1.0));
	
	// 7. Film Grain Noise
	float noise = (rand(pixel_uv * TIME) - 0.5) * noise_intensity;
	color += noise;
	
	COLOR = vec4(color, 1.0);
}
