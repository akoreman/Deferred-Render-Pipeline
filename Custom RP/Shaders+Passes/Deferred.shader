Shader "Custom RP/Deferred"
{
	Properties{
		_BaseColor("Color", Color) = (0.5, 0.5, 0.5, 1.0)
		_Texture("Texture", 2D) = "white" {}

		_Metallic("Metallic", Range(0, 1)) = 0
		_Smoothness("Smoothness", Range(0, 1)) = 0.5

		[NoScaleOffset] _EmissionMap("Emission", 2D) = "white" {}
		[HDR] _EmissionColor("Emission", Color) = (0.0, 0.0, 0.0, 0.0)

		[Toggle(_RECEIVE_SHADOWS)] _ReceiveShadows("Receive Shadows", Float) = 1

		[NoScaleOffset] _NormalMap("Normals", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range(0, 1)) = 1
	}
		SubShader{

			Pass {
				Tags {
					"LightMode" = "Albedo"
				}

				HLSLPROGRAM
				#pragma target 3.5
				#pragma multi_compile_instancing
				#pragma vertex AlbedoPassVertex
				#pragma fragment AlbedoPassFragment
				#include "AlbedoPass.hlsl"
				ENDHLSL
			}
			
			Pass {
				Tags {
					"LightMode" = "Geometry"
				}

				HLSLPROGRAM
				#pragma target 3.5
				#pragma multi_compile_instancing
				#pragma vertex NormalsPassVertex
				#pragma fragment NormalsPassFragment
				#include "NormalsPass.hlsl"
				ENDHLSL
			}
			
			Pass {
				Tags {
					"LightMode" = "World Position"
				}

				HLSLPROGRAM
				#pragma target 3.5
				#pragma multi_compile_instancing
				#pragma vertex WorldPositionPassVertex
				#pragma fragment WorldPositionPassFragment
				#include "WorldPositionPass.hlsl"
				ENDHLSL
			}

			Pass {
				Tags {
					"LightMode" = "Lit"
				}

				HLSLPROGRAM
				#pragma target 3.5
				#pragma multi_compile_instancing
				#pragma vertex LitPassVertex
				#pragma fragment LitPassFragment
				#pragma shader_feature _RECEIVE_SHADOWS
				#include "LitPass.hlsl"
				ENDHLSL
			}
			
		}
}