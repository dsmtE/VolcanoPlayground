shader_type canvas_item;

uniform float noise_strength = 0.0;
uniform float noise_scale = 50.0;
uniform float wind_speed = 1.0;

uniform vec4 rect_info;

varying vec2 world_position;

vec2 random(vec2 uv) {
    uv = vec2( dot(uv, vec2(127.1,311.7) ), dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) + 0.5;
}

// Not scoped uniform bug
vec2 uv_to_region_uv(vec2 uv, vec2 texture_pixel_size) {
	return (uv-(rect_info.xy*texture_pixel_size))/(rect_info.zw*texture_pixel_size);
}

vec2 region_uv_to_uv(vec2 region_uv, vec2 texture_pixel_size) {
	return (rect_info.xy*texture_pixel_size)+region_uv*(rect_info.zw*texture_pixel_size);
}

vec2 pixalate(vec2 uv, vec2 pixel_size) {
	return trunc(uv * pixel_size) / pixel_size;
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xy;
}
void fragment() {
	vec2 region_uv = uv_to_region_uv(UV, TEXTURE_PIXEL_SIZE);
	vec2 pixelated_region_uv = pixalate(region_uv, rect_info.zw);
	// vec2 pixelated_uv = ceil(UV / pixel_scale) * pixel_scale;
	float noise = (noise(world_position + pixelated_region_uv*noise_scale + TIME*wind_speed)*2.0-1.0);

	COLOR = texture(TEXTURE, region_uv_to_uv(pixelated_region_uv + noise * noise_strength, TEXTURE_PIXEL_SIZE)+TEXTURE_PIXEL_SIZE/2.);
	
}
