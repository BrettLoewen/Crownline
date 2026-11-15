shader_type spatial;
render_mode unshaded;

uniform vec3 fillColour : source_color = vec3(1.0);
uniform vec3 outlineColour : source_color = vec3(1.0);
uniform float outlineCutoffInside = 0.6;
uniform float outlineCutoffOutside = 0.7;

// Called for every vertex the material is visible on.
void vertex() {
}

// Called for every pixel the material is visible on.
void fragment() {
	float smoothDistFromCenter = smoothstep(outlineCutoffInside, outlineCutoffOutside, UV.y);
	vec3 outputColour = mix(fillColour, outlineColour, smoothDistFromCenter);
	ALBEDO = outputColour;
}
