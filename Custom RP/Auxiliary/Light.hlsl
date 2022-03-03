#ifndef CUSTOM_LIGHT_INCLUDED
#define CUSTOM_LIGHT_INCLUDED

#define MAX_DIRECTIONAL_LIGHT_COUNT 4

CBUFFER_START(_CustomLight)
	int _DirectionalLightCount;
	float4 _DirectionalLightColors[MAX_DIRECTIONAL_LIGHT_COUNT];
	float4 _DirectionalLightDirections[MAX_DIRECTIONAL_LIGHT_COUNT];
	float4 _DirectionalLightShadowData[MAX_DIRECTIONAL_LIGHT_COUNT];
CBUFFER_END

struct Light
{
	float3 color;
	float3 direction;
	float attenuation;
};

int GetDirectionalLightCount()
{
	return _DirectionalLightCount;
}

DirectionalShadowData GetDirectionalShadowData(int lightIndex, ShadowData shadowData)
{
	DirectionalShadowData data;
	data.strength = _DirectionalLightShadowData[lightIndex].x * shadowData.strength;
	data.tileIndex = _DirectionalLightShadowData[lightIndex].y + shadowData.cascadeIndex;
	return data;
}


Light GetDirectionalLight(int index, Surface surfaceWorldSpace, ShadowData shadowData)
{
	Light light;
	light.color = _DirectionalLightColors[index].rgb;

	light.direction = _DirectionalLightDirections[index].xyz;

	DirectionalShadowData dirShadowData = GetDirectionalShadowData(index, shadowData);
	light.attenuation = GetDirectionalShadowAttenuation(dirShadowData, shadowData, surfaceWorldSpace);

	return light;
}


#endif