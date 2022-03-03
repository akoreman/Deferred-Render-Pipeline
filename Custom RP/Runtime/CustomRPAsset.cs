using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[CreateAssetMenu(menuName = "Rendering/Custom Render Pipeline")]


public class CustomRPAsset : RenderPipelineAsset 
{
    [SerializeField]

    protected override RenderPipeline CreatePipeline()
    {
        return new CustomRP();
    }

}
