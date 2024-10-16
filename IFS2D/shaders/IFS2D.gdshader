shader_type particles;
render_mode disable_velocity;

uniform bool compute = true;
group_uniforms affine_transformations;
uniform uint function_count = 3;
uniform mat3 affine_0;
uniform mat3 affine_1;
uniform mat3 affine_2;
uniform mat3 affine_3;
uniform mat3 affine_4;
uniform mat3 affine_5;
uniform mat3 affine_6;
uniform mat3 affine_7;

group_uniforms randomness;
uniform float hash_time_constant = 10000;

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
	// color change before transform for cooler effect, move to bottom for uniform change
	COLOR = vec4(abs(sin(TIME*2.0))*(TRANSFORM[3].x+800.0)/1600.0,
				abs(cos(TIME*2.0))*(TRANSFORM[3].y+500.0)/1000.0,
				abs(sin(TIME*0.5)), 1.0);
	int affine_index = 0;
	mat3 affine_arr[] = {affine_0, affine_1, affine_2, affine_3,
						affine_4, affine_5, affine_6, affine_7};
	
	affine_index = int(rand_from_seed(alt_seed)*float(function_count)-0.00001);
	
	TRANSFORM[3].xy = (affine_arr[affine_index] * TRANSFORM[3].xyw).xy;
}}




