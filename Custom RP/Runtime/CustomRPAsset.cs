using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[CreateAssetMenu(menuName = "Rendering/Custom Render Pipeline")]


public class CustomRPAsset : RenderPipelineAsset 
{
    [SerializeField]
    Shader shader;

    protected override RenderPipeline CreatePipeline()
    {
        return new CustomRP(shader);
    }

}
