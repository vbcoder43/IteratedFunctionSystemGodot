shader_type canvas_item;

uniform sampler2D screen : hint_screen_texture;

vec3 filt_box_blur() {
	return vec3(0.0,0.0,0.0);
}

vec3 filt_kuwahara() {
	return vec3(0.0,0.0,0.0);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = texture(screen, SCREEN_UV);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
