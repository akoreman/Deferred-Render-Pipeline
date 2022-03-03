#ifndef CUSTOM_WORLDPOSITION_PASS_INCLUDED
#define CUSTOM_WORLDPOSITION_PASS_INCLUDED

#include "../Auxiliary/Common.hlsl"


struct vertexInput
{
    float3 positionObjectSpace : POSITION;
};

struct vertexOutput
{
    float3 positionWorldSpace : VAR_POSITION;
    float4 positionClipSpace : SV_POSITION;
};

vertexOutput WorldPositionPassVertex(vertexInput input) 
{
    vertexOutput output;
     
    output.positionWorldSpace = TransformObjectToWorld(input.positionObjectSpace);
    output.positionClipSpace = TransformWorldToHClip(output.positionWorldSpace);
    
    return output;
}

float4 WorldPositionPassFragment(vertexOutput input) : SV_TARGET
{
    return float4(input.positionWorldSpace, 1.0);
}

#endif