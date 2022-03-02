#ifndef CUSTOM_NORMALS_PASS_INCLUDED
#define CUSTOM_NORMALS_PASS_INCLUDED

#include "../Auxiliary/Common.hlsl"

TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);

// Input struct for the vertex shader.
struct vertexInput
{
    float3 positionObjectSpace : POSITION;
    float3 normalObjectSpace : NORMAL;
    float2 coordsUV : TEXCOORD0;
    float4 tangentObjectSpace : TANGENT;
};

// Output struct for the vertex shader.
struct vertexOutput
{
    float4 positionClipSpace : SV_POSITION;
    float3 normalWorldSpace : VAR_NORMAL;
    float2 coordsUV : TEXCOORD0;
    float4 tangentWorldSpace : VAR_TANGENT;
};

struct fragmentOutput
{
    float4 normalBuffer : SV_TARGET0;
    //float4 albedoBuffer : SV_TARGET1;
};

float3 GetNormalTS(float2 coordsUV)
{
    float4 map = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, coordsUV);
    //float scale = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _NormalScale);
    float3 normal = DecodeNormal(map, 1.0);
    
    return normal;
}

vertexOutput NormalsPassVertex(vertexInput input)
{
    vertexOutput output;
   
	// Transform from object space to world space.
    float3 positionWorldSpace = TransformObjectToWorld(input.positionObjectSpace);

	// Transform from world space to clip space.
    output.positionClipSpace = TransformWorldToHClip(positionWorldSpace);
    output.normalWorldSpace = TransformObjectToWorldNormal(input.normalObjectSpace);
    output.coordsUV = input.coordsUV;
    
    output.tangentWorldSpace = float4(TransformObjectToWorldDir(input.tangentObjectSpace.xyz), input.tangentObjectSpace.w);
    
    return output;
}

float4 NormalsPassFragment(vertexOutput input) : SV_TARGET
{
    fragmentOutput output;
    
    float3 normal = NormalTangentToWorld(GetNormalTS(input.coordsUV), input.normalWorldSpace, input.tangentWorldSpace);
    
    output.normalBuffer = float4(normal, 1.0);
    //output.albedoBuffer = 
    
    
    return float4(normal, 1.0);
}

#endif