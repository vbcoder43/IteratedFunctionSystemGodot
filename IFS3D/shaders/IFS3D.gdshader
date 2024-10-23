shader_type particles;
render_mode disable_velocity, keep_data;

uniform bool compute = true;
uniform float red : hint_range(0.0, 1.0, 0.001) = 1.0;
uniform float green : hint_range(0.0, 1.0, 0.001) = 1.0;
uniform float blue : hint_range(0.0, 1.0, 0.001) = 1.0;
group_uniforms affine_transformations;
uniform uint function_count = 5;
uniform float decay_rate : hint_range(0.01, 20.0, 0.01) = 4.0;
uniform mat4 affine_0;
uniform mat4 affine_1;
uniform mat4 affine_2;
uniform mat4 affine_3;
uniform mat4 affine_4;
uniform float acc_time = 0.0;

group_uniforms randomness;
uniform float hash_time_constant;

group_uniforms occlusion;
uniform float occlusion_value;
uniform float occlusion_exponent;

// Godot's own random number generator converted from particleprocessmaterial
float rand_from_seed(inout uint seed) {
	int k;
	int s = int(seed);
	if (s == 0) {
		s = 305420679;
	}
	k = s / 127773;
	s = 16807 * (s - k * 127773) - 2836 * k;
	if (s < 0) {
		s += 2147483647;
	}
	seed = uint(s);
	return float(seed % uint(65536)) / 65535.0;
}
uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}
float rand_normal(float x, float sigma, float mu) {
	return exp(-0.5*((((x-mu)/sigma)*(x-mu)/sigma)))/(sigma*sqrt(2.0*PI));
}

void start() {
	// Called when a particle is spawned.
}

void process() { if(compute){
	// Called every frame on existing particles (according to the Fixed FPS property).
	uint alt_seed = hash(NUMBER + uint(TIME*hash_time_constant) + uint(1) + RANDOM_SEED);
	// needs Use as Albedo set in particle texture
	// ALBEDO = COLOR.rgb
	// setting to unshaded alongside transparency=alpha gives massive boost to performance
	// depth draw mode always big performance boost
	//COLOR before transform for cool effect
	COLOR = vec4(
		1.0-smoothstep(0.0,1.0,abs(TRANSFORM[3].x*red/10.0)),
		1.0-smoothstep(0.0,1.0,abs(TRANSFORM[3].z*green/10.0)),
		1.0-smoothstep(0.0,1.0,abs(TRANSFORM[3].y*blue/10.0)),
		1.0
	);
	int affine_index = 0;
	mat4 affine_arr[] = {affine_0, affine_1, affine_2, affine_3, affine_4};

	affine_index = int(rand_from_seed(alt_seed)*float(function_count)-0.00001);
	vec3 dest = (affine_arr[affine_index] * TRANSFORM[3]).xyz;
	TRANSFORM[3].xyz = dest + (TRANSFORM[3].xyz - dest) * exp(-decay_rate*(acc_time));
	TRANSFORM[3].xyz = clamp(TRANSFORM[3].xyz,-15.0,15.0);
	// apply occlusion

}}
