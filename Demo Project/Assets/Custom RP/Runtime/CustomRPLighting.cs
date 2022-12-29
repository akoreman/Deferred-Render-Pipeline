using UnityEngine;
using UnityEngine.Rendering;
using Unity.Collections;

public class Lighting
{
    const string bufferName = "Lighting";
    const int maxDirLightCount = 4;
    const int maxOtherLightCount = 64;

    CullingResults cullingResults;

    CommandBuffer buffer = new CommandBuffer { name = bufferName };

    static int dirLightCountId = Shader.PropertyToID("_DirectionalLightCount");
    static int dirLightColoursId = Shader.PropertyToID("_DirectionalLightColors");
    static int dirLightDirectionsId = Shader.PropertyToID("_DirectionalLightDirections");

    static Vector4[] dirLightColours = new Vector4[maxDirLightCount];
    static Vector4[] dirLightDirections = new Vector4[maxDirLightCount];

    public void Setup(ScriptableRenderContext context, CullingResults cullingResults)
    {
        this.cullingResults = cullingResults;

        SetupLights();
        context.ExecuteCommandBuffer(buffer);
        buffer.Clear();
    }

    void SetupDirectionalLight(int index, int visibleIndex, ref VisibleLight visibleLight)
    {
        dirLightColours[index] = visibleLight.finalColor;
        dirLightDirections[index] = -visibleLight.localToWorldMatrix.GetColumn(2);
    }

    void SetupLights()
    {
        NativeArray<VisibleLight> visibleLights = cullingResults.visibleLights;

        int dirLightCount = 0;

        for (int i = 0; i < visibleLights.Length; i++)
        {
            VisibleLight visibleLight = visibleLights[i];

            switch (visibleLight.lightType)
            {
                case LightType.Directional:
                    if (dirLightCount < maxDirLightCount)
                    {
                        SetupDirectionalLight(dirLightCount++, i, ref visibleLight);
                    }
                    break;
            }
        }

        buffer.SetGlobalInt(dirLightCountId, dirLightCount);

        if (dirLightCount > 0)
        {
            buffer.SetGlobalVectorArray(dirLightColoursId, dirLightColours);
            buffer.SetGlobalVectorArray(dirLightDirectionsId, dirLightDirections);
        }
    }
}