#ifndef CUSTOM_SHADOWS_INCLUDED
#define CUSTOM_SHADOWS_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Shadow/ShadowSamplingTent.hlsl"

#if defined(_DIRECTIONAL_PCF3)
	#define DIRECTIONAL_FILTER_SAMPLES 4
	#define DIRECTIONAL_FILTER_SETUP SampleShadow_ComputeSamples_Tent_3x3
#elif defined(_DIRECTIONAL_PCF5)
	#define DIRECTIONAL_FILTER_SAMPLES 9
	#define DIRECTIONAL_FILTER_SETUP SampleShadow_ComputeSamples_Tent_5x5
#elif defined(_DIRECTIONAL_PCF7)
	#define DIRECTIONAL_FILTER_SAMPLES 16
	#define DIRECTIONAL_FILTER_SETUP SampleShadow_ComputeSamples_Tent_7x7
#endif

#define MAX_SHADOWED_DIRECTIONAL_LIGHT_COUNT 4
#define MAX_CASCADE_COUNT 4

TEXTURE2D_SHADOW(_DirectionalShadowAtlas);
#define SHADOW_SAMPLER sampler_linear_clamp_compare
SAMPLER_CMP(SHADOW_SAMPLER);

CBUFFER_START(_CustomShadows)
	int _CascadeCount;
	float4 _CascadeCullingSpheres[MAX_CASCADE_COUNT];
	float4x4 _DirectionalShadowMatrices[MAX_SHADOWED_DIRECTIONAL_LIGHT_COUNT * MAX_CASCADE_COUNT];
	//float _ShadowDistance;
	float4 _ShadowAtlasSize;
	float4 _ShadowDistanceFade;
	float4 _CascadeData[MAX_CASCADE_COUNT];
CBUFFER_END

struct DirectionalShadowData
{
	float strength;
	int tileIndex;
};

struct ShadowData
{
	int cascadeIndex;
	float strength;
};

float FadedShadowStrength(float distance, float scale, float fade)
{
	return saturate((1.0 - distance * scale) * fade);
}

ShadowData GetShadowData(Surface surfaceWorldSpace) 
{
	ShadowData data;
	//data.strength = surfaceWorldSpace.depth < _ShadowDistance ? 1.0 : 0.0;

	data.strength = FadedShadowStrength(surfaceWorldSpace.depth, _ShadowDistanceFade.x, _ShadowDistanceFade.y);

	int i;
	for (i = 0; i < _CascadeCount; i++) 
	{

		float4 sphere = _CascadeCullingSpheres[i];
		float distanceSqr = DistanceSquared(surfaceWorldSpace.position, sphere.xyz);

		if (distanceSqr < sphere.w) 
		{
			if (i == _CascadeCount - 1) {
				data.strength *= FadedShadowStrength(distanceSqr, _CascadeData[i].x, _ShadowDistanceFade.z);
			}
			break;
		}
	}

	if (i == _CascadeCount)
	{
		data.strength = 0.0;
	}

	data.cascadeIndex = i;

	return data;
}

float SampleDirectionalShadowAtlas(float3 positionSTS)
{
	return SAMPLE_TEXTURE2D_SHADOW(_DirectionalShadowAtlas, SHADOW_SAMPLER, positionSTS);
}

float FilterDirectionalShadow(float3 positionSTS)
{
#if defined(DIRECTIONAL_FILTER_SETUP)
	float weights[DIRECTIONAL_FILTER_SAMPLES];
	float2 positions[DIRECTIONAL_FILTER_SAMPLES];
	float4 size = _ShadowAtlasSize.yyxx;
	DIRECTIONAL_FILTER_SETUP(size, positionSTS.xy, weights, positions);
	float shadow = 0;
	for (int i = 0; i < DIRECTIONAL_FILTER_SAMPLES; i++) {
		shadow += weights[i] * SampleDirectionalShadowAtlas(
			float3(positions[i].xy, positionSTS.z)
		);
	}
	return shadow;
#else
	return SampleDirectionalShadowAtlas(positionSTS);
#endif
}

float GetDirectionalShadowAttenuation(DirectionalShadowData directional, ShadowData global, Surface surfaceWS)
{
	#if !defined(_RECEIVE_SHADOWS)
		return 1.0;
	#endif

	if (directional.strength <= 0.0) {
		return 1.0;
	}
	float3 normalBias = surfaceWS.normal * _CascadeData[global.cascadeIndex].y;
	float3 positionSTS = mul(_DirectionalShadowMatrices[directional.tileIndex],float4(surfaceWS.position + normalBias, 1.0)).xyz;

	float shadow = FilterDirectionalShadow(positionSTS);

	return lerp(1.0, shadow, directional.strength);
}

#endif