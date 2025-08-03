shader_type spatial;

uniform sampler2D texture_to_scroll;
uniform sampler2D noise_tex;
uniform sampler2D alpha_noise;
uniform float blend_amount : hint_range(-0.1, 1.0, 0.01) = 0.25;
uniform float scroll_speed = 0.5;
uniform float angle_degrees : hint_range(0, 360) = 45.0;

void fragment() {
	// Called for every pixel the material is visible on.
	float angle_rad = radians(angle_degrees);
	vec2 direction = vec2(cos(angle_rad), sin(angle_rad));
	
	vec2 offset_uv = UV - (TIME * scroll_speed * direction);
	//float offset = fract(floor(offset_uv.y * repeat_y) * 0.5) > 0.0 ? (row_offset * 0.324) : 0.0;
	//offset_uv.x += offset;
	
	//vec2 scaled_uv = vec2(fract(offset_uv.x * repeat_x), fract(offset_uv.y * repeat_y));
	
	vec2 texelSize = vec2(1.0) / vec2(textureSize(texture_to_scroll, 0));
	//vec2 snappedUV = round(scaled_uv / texelSize) * texelSize;
	
	float depth = texture(alpha_noise, offset_uv).r;
	float blend = clamp((depth - blend_amount) * 10.0, 0.0, 1.0);
	vec4 blended_color = mix(texture(texture_to_scroll, offset_uv), texture(noise_tex,offset_uv), blend_amount);
	ALBEDO = texture(texture_to_scroll, offset_uv).rgb;
	ALPHA = depth / 3.0;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
