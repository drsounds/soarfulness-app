shader_type fog;

uniform float time = 0;
uniform float x = 0;
uniform float z = 0;
uniform float height = 1;
uniform sampler2D text;

void fog() {
	// Called for every vertex the material is visible on.
	ALBEDO = vec3(1, 1, 1);
	DENSITY = 1.0;
	EMISSION = vec3(1, 1, 1);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
