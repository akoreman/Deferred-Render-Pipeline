#ifndef CUSTOM_LIT_PASS_INCLUDED
#define CUSTOM_LIT_PASS_INCLUDED

#include "../Auxiliary/Common.hlsl"




TEXTURE2D(_Texture);
SAMPLER(sampler_Texture);

TEXTURE2D(_NormalBuffer);
SAMPLER(sampler_NormalBuffer);

TEXTURE2D(_AlbedoBuffer);
SAMPLER(sampler_AlbedoBuffer);


struct vertexInput
{
	float3 positionObjectSpace : POSITION;
};

struct vertexOutput 
{
	float4 positionClipSpace : SV_POSITION;
};


vertexOutput LitPassVertex(vertexInput input)
{
    vertexOutput output;

	float3 positionWorldSpace = TransformObjectToWorld(input.positionObjectSpace);
	output.positionClipSpace = TransformWorldToHClip(positionWorldSpace);

	return output;
}

float4 LitPassFragment(vertexOutput input) : SV_TARGET
{

    float2 screenSpaceVector = input.positionClipSpace.xy;

    screenSpaceVector.x /= _ScreenParams.x;
    screenSpaceVector.y /= _ScreenParams.y;
	
    screenSpaceVector.y = 1 - screenSpaceVector.y;
		
    float4 albedo = SAMPLE_TEXTURE2D(_AlbedoBuffer, sampler_AlbedoBuffer, screenSpaceVector);
	
    float4 color = dot(float3(-1.0, 0.3, -0.3), SAMPLE_TEXTURE2D(_NormalBuffer, sampler_NormalBuffer, screenSpaceVector).xyz);

    return saturate(color * albedo);
}

#endif