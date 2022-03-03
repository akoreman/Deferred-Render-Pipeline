#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED

float3 IncomingLight(Surface surface, Light light)
{
	return saturate(dot(surface.normal, light.direction) * light.color * light.attenuation);
}

float3 GetLighting(Surface surface, BRDF brdf, Light light) 
{
	return IncomingLight(surface, light) * DirectBRDF(surface, brdf, light);
}

float3 GetLighting(Surface surfaceWorldSpace, BRDF brdf, GI gi)
{
	ShadowData shadowData = GetShadowData(surfaceWorldSpace);
	//float3 color = 0.0;
	//float3 color = gi.diffuse * brdf.diffuse;;
    float3 color = IndirectBRDF(surfaceWorldSpace, brdf, gi.diffuse, gi.specular);
	
	for (int i = 0; i < GetDirectionalLightCount(); i++) 
	{
		Light light = GetDirectionalLight(i, surfaceWorldSpace, shadowData);
		color += GetLighting(surfaceWorldSpace, brdf, light);
	}

	return color;
}

#endif