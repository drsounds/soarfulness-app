shader_type spatial;

render_mode cull_disabled;

uniform float time = 0;
uniform float x = 0;
uniform float z = 0;
uniform float height = 1;
uniform sampler2D text;

void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX.y =  VERTEX.y + sin(VERTEX.z + z) * height;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 modified_uv = UV;
	modified_uv.y -= (time + z) * 0.001;
	modified_uv *= 28.5;
	ALBEDO = texture(text, modified_uv).rgb;
	ALPHA = 0.9;
	METALLIC = 0.5;
	ROUGHNESS = 0.2;
	
}
 
//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
