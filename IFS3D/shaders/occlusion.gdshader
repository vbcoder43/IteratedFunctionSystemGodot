shader_type spatial;
// Prevent the quad from being affected by lighting and fog. This also improves performance.
render_mode unshaded, fog_disabled;


// https://theorangeduck.com/page/pure-depth-ssao
uniform sampler2D noise_tex;
uniform sampler2D screen_tex : hint_screen_texture;
uniform sampler2D depth_texture : hint_depth_texture;
uniform int samples = 16;
uniform float area = 0.0075;
uniform float radius = 0.0002;
uniform float falloff = 0.000001;
uniform vec3 col_bright : source_color;
uniform vec3 col_dark : source_color;
uniform bool tint = true;
const vec3 sample_sphere[] = {
		vec3( 0.5381, 0.1856,-0.4319), vec3( 0.1379, 0.2486, 0.4430),
		vec3( 0.3371, 0.5679,-0.0057), vec3(-0.6999,-0.0451,-0.0019),
		vec3( 0.0689,-0.1598,-0.8547), vec3( 0.0560, 0.0069,-0.1843),
		vec3(-0.0146, 0.1402, 0.0762), vec3( 0.0100,-0.1924,-0.0344),
		vec3(-0.3577,-0.5301,-0.4358), vec3(-0.3169, 0.1063, 0.0158),
		vec3( 0.0103,-0.5869, 0.0046), vec3(-0.0897,-0.4940, 0.3287),
		vec3( 0.7119,-0.0154,-0.0918), vec3(-0.0533, 0.0596,-0.5411),
		vec3( 0.0352,-0.0631, 0.5460), vec3(-0.4776, 0.2847,-0.0271)};
// for visualization
//uniform float range : hint_range(0.01, 25.0, 0.001) = 20.0;

vec3 normal_from_depth(float depth, vec2 uv) {
	vec2 offset_1 = vec2(0.0, 0.001);
	vec2 offset_2 = vec2(0.001, 0.0);
	float depth_1 = texture(depth_texture, uv + offset_1).x;
	float depth_2 = texture(depth_texture, uv + offset_2).x;
	vec3 p1 = vec3(offset_1, depth_1-depth);
	vec3 p2 = vec3(offset_2, depth_2-depth);
	vec3 normal = cross(p1, p2);
	normal.z = -normal.z;
	return normalize(normal);
}

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec3 random = normalize(texture(noise_tex, SCREEN_UV).rgb);
	vec4 screen = texture(screen_tex, SCREEN_UV);
	float depth = texture(depth_texture, SCREEN_UV).x;
	// for visualization of depth
	//vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	//vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	//view.xyz /= view.w;
	//float depth_blend = smoothstep(view.z + range, view.z, VERTEX.z);
	
	vec3 pos = vec3(SCREEN_UV, depth);
	vec3 normal = normal_from_depth(depth, SCREEN_UV);
	float radius_depth = radius / depth;
	float occlusion = 0.0;
	for(int i=0; i<samples; ++i) {
		vec3 ray = radius_depth * reflect(sample_sphere[i], random);
		vec3 hemi_ray = pos + sign(dot(ray,normal)) * ray;
		vec2 hemi_ray_clamped = clamp(hemi_ray.xy, 0.0, 1.0);
		float occ_depth = texture(depth_texture, hemi_ray_clamped).x;
		float diff = depth - occ_depth;
		occlusion += step(falloff, diff) * (1.0 - smoothstep(falloff, area, diff));
	}
	float str = 1.3;
	float ao = 1.0 - str * occlusion * (1.0/float(samples));
	ao = exp(-2.0*ao);
	vec3 ao_rgb = clamp(ao*screen.rgb, 0.0, 1.0);
	if(tint) ALBEDO = mix(col_dark, col_bright, ao);
	else ALBEDO = clamp(ao*screen.rgb, 0.0, 1.0);
	// needs alpha
	ALPHA = screen.a;
}