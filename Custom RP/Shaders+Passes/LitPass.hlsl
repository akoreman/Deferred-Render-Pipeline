#ifndef CUSTOM_LIT_PASS_INCLUDED
#define CUSTOM_LIT_PASS_INCLUDED

#include "../Auxiliary/Common.hlsl"
#include "../Auxiliary/Surface.hlsl"
#include "../Auxiliary/Shadows.hlsl"
#include "../Auxiliary/Light.hlsl"
#include "../Auxiliary/BRDF.hlsl"
#include "../Auxiliary/GlobalIllumination.hlsl"
#include "../Auxiliary/Lighting.hlsl"

#if defined(LIGHTMAP_ON)
	#define GI_ATTRIBUTE_DATA float2 lightMapUV : TEXCOORD1;
	#define GI_VARYINGS_DATA float2 lightMapUV : VAR_LIGHT_MAP_UV;
	#define TRANSFER_GI_DATA(input, output) output.lightMapUV = input.lightMapUV * unity_LightmapST.xy + unity_LightmapST.zw;
	#define GI_FRAGMENT_DATA(input) input.lightMapUV
#else
	#define GI_ATTRIBUTE_DATA
	#define GI_VARYINGS_DATA
	#define TRANSFER_GI_DATA(input, output)
	#define GI_FRAGMENT_DATA(input) 0.0
#endif

TEXTURE2D(_Texture);
SAMPLER(sampler_Texture);

TEXTURE2D(_NormalBuffer);
SAMPLER(sampler_NormalBuffer);

TEXTURE2D(_AlbedoBuffer);
SAMPLER(sampler_AlbedoBuffer);


UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
	UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)
	UNITY_DEFINE_INSTANCED_PROP(float, _Cutoff)
	UNITY_DEFINE_INSTANCED_PROP(float4, _EmissionColor)
	UNITY_DEFINE_INSTANCED_PROP(float, _Metallic)
	UNITY_DEFINE_INSTANCED_PROP(float, _Smoothness)
	UNITY_DEFINE_INSTANCED_PROP(float, _NormalScale)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)


struct vertexInput
{
	float3 positionObjectSpace : POSITION;

	GI_ATTRIBUTE_DATA
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct vertexOutput 
{
	float4 positionClipSpace : SV_POSITION;

	GI_VARYINGS_DATA
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct fragmentOutput
{
	float4 normalBuffer : SV_TARGET0;
	float4 albedoBuffer : SV_TARGET1;
};


vertexOutput LitPassVertex(vertexInput input)
{
	//Setup output struct and transfer the instance IDs.
    vertexOutput output;
	UNITY_SETUP_INSTANCE_ID(input);
	UNITY_TRANSFER_INSTANCE_ID(input, output);
	TRANSFER_GI_DATA(input, output);

	float3 positionWorldSpace = TransformObjectToWorld(input.positionObjectSpace);
	output.positionClipSpace = TransformWorldToHClip(positionWorldSpace);

	return output;
}

float4 LitPassFragment(vertexOutput input) : SV_TARGET
{
	UNITY_SETUP_INSTANCE_ID(input);

    float2 screenSpaceVector = input.positionClipSpace.xy;

    screenSpaceVector.x /= _ScreenParams.x;
    screenSpaceVector.y /= _ScreenParams.y;
	
    screenSpaceVector.y = 1 - screenSpaceVector.y;
		
    float4 albedo = SAMPLE_TEXTURE2D(_AlbedoBuffer, sampler_AlbedoBuffer, screenSpaceVector);
	
    float4 color = dot(float4(1.0, 0.0, 0.7, 1.0), SAMPLE_TEXTURE2D(_NormalBuffer, sampler_NormalBuffer, screenSpaceVector));
	
    return color * albedo;
}

#endif