#ifndef CUSTOM_ALBEDO_PASS_INCLUDED
#define CUSTOM_ALBEDO_PASS_INCLUDED

#include "../Auxiliary/Common.hlsl"

TEXTURE2D(_Texture);
SAMPLER(sampler_Texture);

// Unity buffer to keep track of per material properties.
UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
	UNITY_DEFINE_INSTANCED_PROP(float4, _BaseColor)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

struct vertexInput
{
    float3 positionObjectSpace : POSITION;
    float2 coordsUV : TEXCOORD0;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct vertexOutput
{
    float4 positionClipSpace : SV_POSITION;
    float2 coordsUV : VAR_BASE_UV;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

vertexOutput AlbedoPassVertex(vertexInput input)
{
    vertexOutput output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
     
	// Transform from object space to world space.
    float3 positionWorldSpace = TransformObjectToWorld(input.positionObjectSpace);

	// Transform from world space to clip space.
    output.positionClipSpace = TransformWorldToHClip(positionWorldSpace);

    output.coordsUV = input.coordsUV;

    return output;
}

float4 AlbedoPassFragment(vertexOutput input) : SV_TARGET
{
    float4 textureSampleColor = SAMPLE_TEXTURE2D(_Texture, sampler_Texture, input.coordsUV);
    float4 baseColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BaseColor);
    
    return textureSampleColor * baseColor;
}

#endif