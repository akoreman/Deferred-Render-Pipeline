#ifndef CUSTOM_GI_INCLUDED
#define CUSTOM_GI_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/EntityLighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ImageBasedLighting.hlsl"

TEXTURE2D(unity_Lightmap);
SAMPLER(samplerunity_Lightmap);

TEXTURE3D_FLOAT(unity_ProbeVolumeSH);
SAMPLER(samplerunity_ProbeVolumeSH);

TEXTURECUBE(unity_SpecCube0);
SAMPLER(samplerunity_SpecCube0);

struct GI
{
	float3 diffuse;
    float3 specular;
};

float3 SampleLightMap (float2 lightMapUV) 
{
	#if defined(LIGHTMAP_ON)
		return SampleSingleLightmap(
			TEXTURE2D_ARGS(unity_Lightmap, samplerunity_Lightmap), lightMapUV,
			float4(1.0, 1.0, 0.0, 0.0),
			#if defined(UNITY_LIGHTMAP_FULL_HDR)
				false,
			#else
				true,
			#endif
			float4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0.0, 0.0)
		);
	#else
		return 0.0;
	#endif
}

float3 SampleLightProbe (Surface surfaceWS) {
	#if defined(LIGHTMAP_ON)
		return 0.0;
	#else
	if (unity_ProbeVolumeParams.x)
	{
			return SampleProbeVolumeSH4(
				TEXTURE3D_ARGS(unity_ProbeVolumeSH, samplerunity_ProbeVolumeSH),
				surfaceWS.position, surfaceWS.normal,
				unity_ProbeVolumeWorldToObject,
				unity_ProbeVolumeParams.y, unity_ProbeVolumeParams.z,
				unity_ProbeVolumeMin.xyz, unity_ProbeVolumeSizeInv.xyz
			);
		}
		else 
		{
		float4 coefficients[7];
			coefficients[0] = unity_SHAr;
			coefficients[1] = unity_SHAg;
			coefficients[2] = unity_SHAb;
			coefficients[3] = unity_SHBr;
			coefficients[4] = unity_SHBg;
			coefficients[5] = unity_SHBb;
			coefficients[6] = unity_SHC;
			return max(0.0, SampleSH9(coefficients, surfaceWS.normal));
		}
	#endif
}

float3 SampleEnviroment(Surface surfacewordspace, BRDF brdf)
{
    float3 uvw = reflect(-surfacewordspace.viewDirection, surfacewordspace.normal);
    float mip = PerceptualRoughnessToMipmapLevel(brdf.perceptualRoughness);
    float4 environment = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0,samplerunity_SpecCube0, uvw, mip);
    return DecodeHDREnvironment(environment, unity_SpecCube0_HDR);
}

GI GetGI (float2 lightMapUV, Surface surfaceWS, BRDF brdf) 
{
	GI gi;
	gi.diffuse = SampleLightMap(lightMapUV) + SampleLightProbe(surfaceWS);
    gi.specular = SampleEnviroment(surfaceWS, brdf);
	return gi;
}

#endif