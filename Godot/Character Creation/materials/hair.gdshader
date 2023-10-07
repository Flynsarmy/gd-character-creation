//Anisotropic Rendering (2) Kajiya Kay Hair Rendering https://zhuanlan.zhihu.com/p/363829203
shader_type spatial;
render_mode cull_disabled;

uniform bool _UseOpacityMask;
uniform sampler2D _HairTex : source_color;
uniform sampler2D _HairNormal : hint_roughness_normal;
uniform sampler2D _HairAO : hint_default_white;
uniform sampler2D _SpecularShift : hint_default_white;
uniform sampler2D _OpacityMask;
uniform sampler2D _GradientColor : source_color;
uniform vec4 _DiffuseColor : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 _PrimaryColor : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float _PrimaryShift : hint_range(-4, 4) = 0.0;
uniform vec4 _SecondaryColor : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float _SecondaryShift : hint_range(-4, 4) = 0.5;
        
uniform float _specPower : hint_range(0, 50) = 20;
uniform float _SpecularWidth : hint_range(0, 1) = 0.5;
uniform float _SpecularScale : hint_range(0, 1) = 0.3;

varying vec3 tangent;
varying vec3 binormal;

float saturate(float a){
	float s = min(max(a, 0.0), 1.0);
	return s;
}

//From https://gamedev.stackexchange.com/questions/53258/rgb-to-xyy-color-space-conversion-and-luminance
float luminance(vec3 rgb){
	return (0.2126 * rgb.x) + (0.7152 * rgb.y) + (0.0722 * rgb.z);
}

vec3 shiftTangent(vec3 T, vec3 N, float shift)
{
	return normalize(T + shift * N);
}

float hairStrand(vec3 T, vec3 V, vec3 L, float specPower)
{
	vec3 H = normalize(V + L);

	float HdotT = dot(T, H);
	float sinTH = sqrt(1.0 - HdotT * HdotT);
	float dirAtten = smoothstep(-_SpecularWidth, 0, HdotT);

	return dirAtten * saturate(pow(sinTH, specPower)) * _SpecularScale;
}

// From https://github.com/maajor/Marschner-Hair-Unity/blob/master/Assets/Art/Shader/HairBxDF.cginc
float square(float x) {
	return x * x;
}

// From https://github.com/maajor/Marschner-Hair-Unity/blob/master/Assets/Art/Shader/HairBxDF.cginc
vec3 getAmbientAndDiffuse(vec4 lightColor, vec4 diffuseColor, vec3 N, vec3 L, vec3 V, float ambientOcc)
{
	vec3 albedo = lightColor.xyz * diffuseColor.xyz;
	float KajiyaDiffuse = 1.0 - abs(dot(N, L));
	
	vec3 FakeNormal = normalize(V - N * dot(V, N));
	N = FakeNormal;
	
	// Hack approximation for multiple scattering.
	float Wrap = 1.0;
	float NoL = saturate((dot(N, L) + Wrap) / square(1.0 + Wrap));
	float DiffuseScatter = (1.0 / PI) * mix(NoL, KajiyaDiffuse, 0.33);
	float Luma = luminance(albedo);
	vec3 ScatterTint = pow(albedo / Luma, vec3(1.0));
	vec3 ambientDiffuse = sqrt(albedo) * DiffuseScatter * ScatterTint;
	//vec3 ambientDiffuse = (albedo * saturate(dot(N, L)) + vec3(0.2, 0.2, 0.2));
	return ambientDiffuse * ambientOcc;
}

vec4 getSpecular(vec4 primaryColor, float primaryShift,
    vec4 secondaryColor, float secondaryShift,
    vec3 N, vec3 T, vec3 V, vec3 L, float specPower, vec2 uv, float ambientOcc)
{
	float shiftTex = texture(_SpecularShift, uv).r - 0.5;

	vec3 t1 = shiftTangent(T, N, primaryShift + shiftTex);
	vec3 t2 = shiftTangent(T, N, secondaryShift + shiftTex);

	vec4 specular = vec4(0.0, 0.0, 0.0, 0.0);
	specular += primaryColor * hairStrand(t1, V, L, specPower) * _SpecularScale;
	specular += secondaryColor * hairStrand(t2, V, L, specPower) * _SpecularScale;
	// From https://www.youtube.com/watch?v=TCz-fKJS3wI
	specular *= pow(saturate(dot(L, N)), 0.5); // Make the specular reflection only visible in direct light.
	specular *= ambientOcc;
    return specular;
}

void light()
{
	vec3 N = normalize(NORMAL);
	vec3 T = normalize(tangent);
	vec3 B = normalize(binormal);
	vec3 V = normalize(VIEW);
	vec3 L = normalize(LIGHT);
	vec3 H = normalize(L + V);
	vec4 _LightColor0 = vec4(LIGHT_COLOR.x, LIGHT_COLOR.y, LIGHT_COLOR.z, 1.0);
	vec4 ao = texture(_HairAO, UV);

	vec3 ambientdiffuse = getAmbientAndDiffuse(_LightColor0, _DiffuseColor, N, L, V, ao.r);
	vec4 specular = getSpecular(_PrimaryColor, _PrimaryShift, _SecondaryColor, _SecondaryShift, N, B, V, L, _specPower, UV, ao.r);

	DIFFUSE_LIGHT += ambientdiffuse;
	SPECULAR_LIGHT += specular.xyz * ATTENUATION;
}

void fragment(){
	tangent = TANGENT;
	binormal = BINORMAL;
	if(_UseOpacityMask){
		vec4 opacity_mask = texture(_OpacityMask, UV);
		ALBEDO = texture(_GradientColor, UV).rgb;
		ALPHA = opacity_mask.r;
	} else {
		vec4 base_hair = texture(_HairTex, UV);
		ALBEDO = base_hair.rgb;
		ALPHA = base_hair.a;
	}
	NORMAL_MAP = texture(_HairNormal, UV).rgb;
	ALPHA_HASH_SCALE = 0.1;
}