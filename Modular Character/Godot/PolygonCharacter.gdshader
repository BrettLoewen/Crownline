// Godot port of Synty's "POLYGON_CustomCharacters" Unity shader (Amplify Shader Editor), for the Modular Character package.
// Each mask channel marks a region of the shared texture atlas; a value <= 0.5 means
// "this texel belongs to the region", and the region's colour replaces the base texture.
shader_type spatial;
render_mode cull_back;

group_uniforms Textures;
uniform sampler2D BaseTexture : source_color, filter_linear_mipmap, repeat_enable;
// Mask_01: R = primary, G = secondary, B = body art
uniform sampler2D Mask01 : hint_default_white, filter_linear, repeat_enable;
// Mask_02: R = metal primary, G = metal secondary, B = metal dark
uniform sampler2D Mask02 : hint_default_white, filter_linear, repeat_enable;
// Mask_03: R = skin, G = scar, B = stubble
uniform sampler2D Mask03 : hint_default_white, filter_linear, repeat_enable;
// Mask_04: R = leather primary, G = leather secondary, B = hair
uniform sampler2D Mask04 : hint_default_white, filter_linear, repeat_enable;
// Mask_05: R = eyes (black = eye)
uniform sampler2D Mask05 : hint_default_white, filter_linear, repeat_enable;

group_uniforms Colors;
uniform vec4 ColorPrimary : source_color = vec4(0.2431373, 0.4196079, 0.6196079, 1.0);
uniform vec4 ColorSecondary : source_color = vec4(0.8196079, 0.6431373, 0.2980392, 1.0);
uniform vec4 ColorLeatherPrimary : source_color = vec4(0.282353, 0.2078432, 0.1647059, 1.0);
uniform vec4 ColorLeatherSecondary : source_color = vec4(0.372549, 0.3294118, 0.2784314, 1.0);
uniform vec4 ColorMetalPrimary : source_color = vec4(0.5960785, 0.6117647, 0.627451, 1.0);
uniform vec4 ColorMetalSecondary : source_color = vec4(0.345098, 0.3764706, 0.3960785, 1.0);
uniform vec4 ColorMetalDark : source_color = vec4(0.1764706, 0.1960784, 0.2156863, 1.0);
uniform vec4 ColorHair : source_color = vec4(0.2627451, 0.2117647, 0.1333333, 1.0);
uniform vec4 ColorSkin : source_color = vec4(1.0, 0.8000001, 0.682353, 1.0);
uniform vec4 ColorStubble : source_color = vec4(0.8039216, 0.7019608, 0.6313726, 1.0);
uniform vec4 ColorScar : source_color = vec4(0.9294118, 0.6862745, 0.5921569, 1.0);
uniform vec4 ColorBodyArt : source_color = vec4(0.2283196, 0.5822246, 0.7573529, 1.0);
uniform vec4 ColorEyes : source_color = vec4(0.05, 0.05, 0.05, 1.0);

group_uniforms Surface;
uniform float BodyArtAmount : hint_range(0.0, 1.0) = 0.0;
uniform float Metallic : hint_range(0.0, 1.0) = 0.0;
uniform float Smoothness : hint_range(0.0, 1.0) = 0.2;
uniform float Emission : hint_range(0.0, 1.0) = 0.0;

float Region(float maskValue) {
	return step(maskValue, 0.5);
}

void fragment() {
	vec4 m1 = texture(Mask01, UV);
	vec4 m2 = texture(Mask02, UV);
	vec4 m3 = texture(Mask03, UV);
	vec4 m4 = texture(Mask04, UV);
	vec4 m5 = texture(Mask05, UV);

	// Same layering order as the original shader.
	vec3 c = texture(BaseTexture, UV).rgb;
	c = mix(c, ColorPrimary.rgb, Region(m1.r));
	c = mix(c, ColorSecondary.rgb, Region(m1.g));
	c = mix(c, ColorLeatherPrimary.rgb, Region(m4.r));
	c = mix(c, ColorLeatherSecondary.rgb, Region(m4.g));
	c = mix(c, ColorMetalPrimary.rgb, Region(m2.r));
	c = mix(c, ColorMetalSecondary.rgb, Region(m2.g));
	c = mix(c, ColorMetalDark.rgb, Region(m2.b));
	c = mix(c, ColorHair.rgb, Region(m4.b));
	c = mix(c, ColorSkin.rgb, Region(m3.r));
	c = mix(c, ColorStubble.rgb, Region(m3.b));
	c = mix(c, ColorScar.rgb, Region(m3.g));
	c = mix(ColorEyes.rgb, c, m5.r);

	float art = mix(m1.b, 1.0, 1.0 - BodyArtAmount);
	c = mix(ColorBodyArt.rgb, c, art);

	ALBEDO = c;
	METALLIC = Metallic;
	ROUGHNESS = 1.0 - Smoothness;
	// Original emits plain white from the eyes; tinting by eye colour reads better for glowing eyes.
	EMISSION = ColorEyes.rgb * (1.0 - m5.r) * Emission * 4.0;
}
