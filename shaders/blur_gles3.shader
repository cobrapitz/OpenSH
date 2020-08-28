shader_type canvas_item;

uniform float amount: hint_range(0.5, 3.0);

void fragment() {
	COLOR.rgb = textureLod(SCREEN_TEXTURE, SCREEN_UV, amount).rgb;
}
