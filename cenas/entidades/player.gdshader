shader_type canvas_item;

uniform float grain_strength : hint_range(0.0, 0.2) = 0.05;

uniform sampler2D screen_texture : hint_screen_texture,
    repeat_disable,
    filter_nearest;

float random(vec2 uv) {
    return fract(
        sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453
    );
}

void fragment() {
    vec4 screen = texture(screen_texture, SCREEN_UV);

    float noise = random(
        SCREEN_UV * vec2(1920.0, 1080.0) + TIME
    );

    noise = (noise - 0.5) * grain_strength;

    COLOR = vec4(screen.rgb + noise, 1.0);
}
