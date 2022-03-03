#ifndef CUSTOM_BRDF_INCLUDED
#define CUSTOM_BRDF_INCLUDED

struct BRDF {
	float3 diffuse;
	float3 specular;
	float roughness;
    float perceptualRoughness;
};

#define MIN_REFLECTIVITY 0.04

float OneMinusReflectivity(float metallic) 
{
	float range = 1.0 - MIN_REFLECTIVITY;
	return range - metallic * range;
}

float SpecularStrength(Surface surface, BRDF brdf, Light light)
{
	float3 h = SafeNormalize(light.direction + surface.viewDirection);
	float nh2 = Square(saturate(dot(surface.normal, h)));
	float lh2 = Square(saturate(dot(light.direction, h)));
	float r2 = Square(brdf.roughness);
	float d2 = Square(nh2 * (r2 - 1.0) + 1.00001);
	float normalization = brdf.roughness * 4.0 + 2.0;
	return r2 / (d2 * max(0.1, lh2) * normalization);
}

float3 DirectBRDF(Surface surface, BRDF brdf, Light light) 
{
	return SpecularStrength(surface, brdf, light) * brdf.specular + brdf.diffuse;
}

float3 IndirectBRDF(Surface surface, BRDF brdf, float3 diffuse, float3 specular)
{
    float3 reflection = specular * brdf.specular;
    reflection /= brdf.roughness * brdf.roughness + 1;
	
    return diffuse * brdf.diffuse + reflection;
}

BRDF GetBRDF(Surface surface, bool applyAlphaToDiffuse = false)
{
	float oneMinusReflectivity = OneMinusReflectivity(surface.metallic);
	float perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(surface.smoothness);

	BRDF brdf;
	brdf.specular = lerp(MIN_REFLECTIVITY, surface.color, surface.metallic);
	
    brdf.perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(surface.smoothness);
	brdf.roughness = PerceptualRoughnessToRoughness(brdf.perceptualRoughness);

    
	
	brdf.diffuse = surface.color * oneMinusReflectivity;

	if (applyAlphaToDiffuse) {
		brdf.diffuse *= surface.alpha;
	}

	return brdf;
}

#endif