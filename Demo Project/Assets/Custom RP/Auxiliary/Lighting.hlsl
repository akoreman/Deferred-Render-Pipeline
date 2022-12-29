#ifndef CUSTOM_LIGHT_INCLUDED
#define CUSTOM_LIGHT_INCLUDED

#define MAX_DIRECTIONAL_LIGHT_COUNT 50

CBUFFER_START(_CustomLight)
	int _DirectionalLightCount;
	float4 _DirectionalLightColors[MAX_DIRECTIONAL_LIGHT_COUNT];
	float4 _DirectionalLightDirections[MAX_DIRECTIONAL_LIGHT_COUNT];
CBUFFER_END

struct Light
{
	float3 color;
	float3 direction;
};

int GetDirectionalLightCount()
{
	return _DirectionalLightCount;
}

Light GetDirectionalLight(int index)
{
	Light light;
	light.color = _DirectionalLightColors[index].rgb;

	light.direction = _DirectionalLightDirections[index].xyz;

	return light;
}

float3 IncomingLight(float3 normal, Light light)
{
	return saturate(dot(normal, light.direction) * light.color);
}

float3 GetLighting(float3 normal)
{
    float3 color = {0.0f, 0.0f, 0.0f};

	for (int i = 0; i < GetDirectionalLightCount(); i++) 
	{
		Light light = GetDirectionalLight(i);
		color += IncomingLight(normal, light);
	}
		
	return color;
}


#endif