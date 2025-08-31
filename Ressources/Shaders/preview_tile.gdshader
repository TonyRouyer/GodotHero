shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 0.5);

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    
    // on remplace la couleur par un "mix" entre la couleur originale et la teinte
    COLOR = mix(tex, tint_color, 0.5); // 70% blanc, 30% texture originale
    COLOR.a *= tint_color.a; // appliquer la transparence
}