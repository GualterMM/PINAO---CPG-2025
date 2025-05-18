shader_type spatial;

/*–‑ Parameters you can edit in the Inspector –‑*/
uniform sampler2D water_texture : source_color;
uniform float wave_speed  = 0.15;   // how quickly the wave oscillates
uniform float wave_amplitude = 0.03; // how far the UV is displaced (try 0.01‑0.05)
uniform vec2  uv_scale    = vec2(2.0, 2.0); // tiling amount

void fragment() {
	/* base UV, scaled for tiling */
	vec2 uv = UV * uv_scale;

	/* gentle vertical bobbing with a sine wave
	   – TIME grows continuously,      ─────────────┐
	   – sin() maps it to ‑1 … 1, and ──────────────┘
	   – amplitude keeps the motion small.          */
	uv.y += sin(TIME * wave_speed) * wave_amplitude;

	/* sample the texture and output a slightly glossy surface */
	vec4 tex_color = texture(water_texture, uv);
	ALBEDO    = tex_color.rgb;
	ALPHA     = tex_color.a;
	SPECULAR  = 0.8;
	ROUGHNESS = 0.1;
}
